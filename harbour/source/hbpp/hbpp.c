/*
 * $Id$

   Harbour Project source code

   This file contains the main part of preprocessor implementation.

   Copyright 1999  Alexander S.Kresin <alex@belacy.belgorod.su>
   www - http://www.harbour-project.org

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version, with one exception:

   The exception is that if you link the Harbour Runtime Library (HRL)
   and/or the Harbour Virtual Machine (HVM) with other files to produce
   an executable, this does not by itself cause the resulting executable
   to be covered by the GNU General Public License. Your use of that
   executable is in no way restricted on account of linking the HRL
   and/or HVM code into it.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA (or visit
   their web site at http://www.gnu.org/).
 */

#include <stdlib.h>
#if defined(__GNUC__)
 #include <string.h>
 #include <unistd.h>
#else
 #if (defined(_MSC_VER) || defined(__IBMCPP__))
  #include <memory.h>
 #else
  #include <mem.h>
 #endif
#endif

#include <stdio.h>
#include <ctype.h>
#include "harb.h"
#include "hberrors.h"

int Hp_Parse( FILE*, FILE* );
int ParseDirective( char* );
int ParseDefine( char* );
DEFINES* AddDefine ( char*, char* );
int ParseUndef( char* );
int ParseIfdef( char*, int);
int ParseCommand( char*, int, int );
int ConvertPatterns ( char*, int, char*, int );
void AddCommand ( char * );
void AddTranslate ( char * );
COMMANDS* getCommand ( int );
int ParseExpression( char*, char* );
int WorkDefine ( char**, char**, DEFINES *, int );
void WorkPseudoF ( char**, char**, DEFINES*);
int WorkCommand ( char*, char*, char*, int);
int CommandStuff ( char *, char *, char *, int*, int );
int WorkTranslate ( char*, char*, char*, int, int* );
int WorkMarkers( char**, char**, char*, int*, int );
int getExpReal ( char *, char **, int, int );
int isExpres ( char* );
void SkipOptional( char**, char*, int*, int*);

DEFINES* DefSearch(char *);
int ComSearch(char *,int);
int TraSearch(char *,int);
void SearnRep( char*,char*,int,char*,int*);
int ReplacePattern ( char, char*, int, char*, int );
void pp_rQuotes( char *, char ** );
int pp_RdStr(FILE*,char *,int,int,char*,int*,int*);
int pp_WrStr(FILE*,char *);
int pp_strAt(char *, int, char*, int);
int md_strAt(char *, int, char*, int);
int IsInStr ( char, char*);
void pp_Stuff (char*, char*, int, int, int);
int strocpy (char*, char* );
int stroncpy (char*, char*, int);
int strincpy (char*, char*);
int strincmp (char*, char**);
int strolen ( char* );
void stroupper ( char* );
int strotrim ( char* );
char* strodup ( char * );
int NextWord ( char**, char*, int);
int NextName ( char**, char*, char**);
int NextParm ( char**, char* );
int Include( char *, PATHNAMES *, FILE** );
int OpenInclude( char *, PATHNAMES *, FILE** );

#define isname(c)  (isalnum(c) || (c)=='_' || (c) > 0x7e)
#define SKIPTABSPACES(sptr) while ( *sptr == ' ' || *sptr == '\t' ) (sptr)++
#define MAX_NAME 255
#define BUFF_SIZE 2048
#define STR_SIZE 8192
#define PATTERN_SIZE 2048
#define FALSE               0
#define TRUE                1

#define STATE_INIT 0
#define STATE_NORMAL 1
#define STATE_COMMENT 2
#define STATE_QUOTE1 3
#define STATE_QUOTE2 4
#define STATE_ID_END 5
#define STATE_ID 6
#define STATE_EXPRES 7
#define STATE_EXPRES_ID 8
#define STATE_BRACKET 9

#define IT_EXPR 1
#define IT_ID 2
#define IT_COMMA 3
#define IT_ID_OR_EXPR 4

int ParseState = 0;
int lInclude = 0;
int *aCondCompile, nCondCompile = 0, maxCondCompile = 5;
int nline=0;
int Repeate;
char groupchar;

extern PATHNAMES *_pIncludePath;

extern DEFINES *topDefine;

#define INITIAL_ACOM_SIZE 200
extern COMMANDS aCommands[] ;
extern int kolcomm;
COMMANDS *aCommnew ;
int kolcommands = 0, maxcommands = INITIAL_ACOM_SIZE;

TRANSLATES *aTranslates ;
int koltranslates = 0, maxtranslates = 50;

/* Table with parse errors */
char * _szPErrors[] = { "Can\'t open include file \"%s\"",
                       "#else does not match #if",
                       "#endif does not match #if",
                       "Error in include file name",
                       "#define without parameters",
                       "Absent \"=>\" in command definition",
                       "Error in pattern definition",
                       "Cycled #define",
                       "Wrong directive \"%s\""
                     };

int ParseDirective( char* sLine )
{
   char sDirective[MAX_NAME];
   int i;
   FILE* handl_i;

   i = NextWord( &sLine, sDirective, TRUE );
   SKIPTABSPACES(sLine);

   if ( i == 4 && memcmp ( sDirective, "else", 4 ) == 0 )
   {     /* ---  #else  --- */
     if ( nCondCompile == 0 )
       GenError( _szPErrors, 'P', ERR_DIRECTIVE_ELSE, NULL, NULL );
     else if ( nCondCompile == 1 || aCondCompile[nCondCompile-2] )
       aCondCompile[nCondCompile-1] = 1 - aCondCompile[nCondCompile-1];
   }

   else if ( i == 5 && memcmp ( sDirective, "endif", 5 ) == 0 )
   {     /* --- #endif  --- */
     if ( nCondCompile == 0 )
       GenError( _szPErrors, 'P', ERR_DIRECTIVE_ENDIF, NULL, NULL );
     else nCondCompile--;
   }

   else if ( i == 5 && memcmp ( sDirective, "ifdef", 5 ) == 0 )
     ParseIfdef ( sLine, TRUE ); /* --- #ifdef  --- */

   else if ( i == 6 && memcmp ( sDirective, "ifndef", 6 ) == 0 )
     ParseIfdef ( sLine, FALSE ); /* --- #ifndef  --- */

   else if ( nCondCompile==0 || aCondCompile[nCondCompile-1])
 {
  if ( i == 7 && memcmp ( sDirective, "include", 7 ) == 0 )
  {    /* --- #include --- */
   if ( *sLine != '\"' )
     GenError( _szPErrors, 'P', ERR_WRONG_NAME, NULL, NULL );
   sLine++; i = 0;
   while ( *(sLine+i) != '\0' && *(sLine+i) != '\"' ) i++;
   if ( *(sLine+i) != '\"' )
     GenError( _szPErrors, 'P', ERR_WRONG_NAME, NULL, NULL );
   *(sLine+i) = '\0';

   /*   if ((handl_i = fopen(sLine, "r")) == NULL) */
   if ( !OpenInclude( sLine, _pIncludePath, &handl_i ) )
     GenError( _szPErrors, 'P', ERR_CANNOT_OPEN, sLine, NULL );
   lInclude++;
   Hp_Parse(handl_i, 0 );
   lInclude--;
   fclose(handl_i);
  }

  else if ( i == 6 && memcmp ( sDirective, "define", 6 ) == 0 )
   ParseDefine ( sLine );   /* --- #define  --- */

  else if ( i == 5 && memcmp ( sDirective, "undef", 5 ) == 0 )
   ParseUndef ( sLine );    /* --- #undef  --- */

  else if ( (i == 7 && memcmp ( sDirective, "command", 7 ) == 0) ||
            (i == 8 && memcmp ( sDirective, "xcommand", 8 ) == 0) )
                                /* --- #command  --- */
   ParseCommand ( sLine, (i==7)? FALSE:TRUE, TRUE );

  else if ( (i == 9 && memcmp ( sDirective, "translate", 9 ) == 0) ||
            (i == 10 && memcmp ( sDirective, "xtranslate", 10 ) == 0) )
                                /* --- #translate  --- */
   ParseCommand ( sLine, (i==9)? FALSE:TRUE, FALSE );

  else if ( i == 6 && memcmp ( sDirective, "stdout", 6 ) == 0 )
   printf ( "%s", sLine ); /* --- #stdout  --- */

  else if ( i == 5 && memcmp ( sDirective, "error", 5 ) == 0 )
  {                        /* --- #error  --- */
   printf ( "\n#error: %s\n", sLine );
   exit(1);
  }
  else if ( i == 4 && memcmp ( sDirective, "line", 4 ) == 0 )
    return -1;
  else GenError( _szPErrors, 'P', ERR_WRONG_DIRECTIVE, sDirective, NULL );
 }
 return 0;
}

int ParseDefine( char* sLine)
{
 char defname[MAX_NAME], pars[MAX_NAME];
 int i, npars = -1;
 DEFINES *lastdef;

 NextName( &sLine, defname, NULL );
 if ( *sLine == '(' ) /* If pseudofunction was found */
 {
  sLine++; i = 0;
  npars = 0;
  while ( *sLine != '\0' && *sLine != ')')
  {
   if ( *sLine == ',' ) npars++;
   if ( *sLine != ' ' && *sLine != '\t' ) *(pars+i++) = *sLine;
   sLine++;
  }
  if ( i > 0 ) npars++;
  *(pars+i) = '\0';
  sLine++;
 }
 SKIPTABSPACES(sLine);

 lastdef = AddDefine ( defname, ( *sLine == '\0' )? NULL : sLine );

 lastdef->npars = npars;
 lastdef->pars = ( npars == 0 )? NULL : strodup ( pars );

 return 0;
}

DEFINES* AddDefine ( char* defname, char* value )
{
   DEFINES* stdef = DefSearch( defname );

   if ( stdef != NULL )
     stdef->pars = NULL;
   else
   {
     stdef = ( DEFINES * ) _xgrab( sizeof( DEFINES ) );
     stdef->last = topDefine;
     topDefine = stdef;
     stdef->name = strodup ( defname );
   }
   stdef->value = ( value == NULL )? NULL : strodup ( value );
   return stdef;
}

int ParseUndef( char* sLine)
{
 char defname[MAX_NAME];
 DEFINES* stdef;

 NextWord( &sLine, defname, FALSE );

 if ( ( stdef = DefSearch(defname) ) != NULL )
 {
  stdef->name = NULL;
 }
 return 0;
}

int ParseIfdef( char* sLine, int usl)
{
   char defname[MAX_NAME];
   DEFINES *stdef;

   if ( nCondCompile==0 || aCondCompile[nCondCompile-1])
   {
     NextWord( &sLine, defname, FALSE );
     if ( *defname == '\0' )
       GenError( _szPErrors, 'P', ERR_DEFINE_ABSENT, NULL, NULL );
   }
   if ( nCondCompile == maxCondCompile )
   {
     maxCondCompile += 5;
     aCondCompile = (int*)_xrealloc( aCondCompile, sizeof( int ) * maxCondCompile );
   }
   if ( nCondCompile==0 || aCondCompile[nCondCompile-1])
   {
     if ( ( (stdef = DefSearch(defname)) != NULL && usl )
       || ( stdef == NULL && !usl ) ) aCondCompile[nCondCompile] = 1;
     else aCondCompile[nCondCompile] = 0;
   }
   else aCondCompile[nCondCompile] = 0;
   nCondCompile++;
   return 0;
}

DEFINES* DefSearch(char *defname)
{
   int j;
   DEFINES * stdef = topDefine;

   while( stdef != NULL )
   {
     for ( j=0; *(stdef->name+j) == *(defname+j) &&
             *(stdef->name+j) != '\0'; j++ );
     if ( *(stdef->name+j) == *(defname+j) ) return stdef;
     stdef = stdef->last;
   }
   return NULL;
}

int ComSearch(char *cmdname, int ncmd)
{
 int i,j;
 if ( !ncmd || ncmd > kolcomm )
  for ( i=(ncmd)? ncmd-kolcomm-1:kolcommands-1; i >= 0; i-- )
  {
   for ( j=0; (*(aCommnew[i].name+j)==toupper(*(cmdname+j))) &&
             (*(aCommnew[i].name+j)!='\0') &&
             ((aCommnew[i].com_or_xcom)? 1:(j<4 || isname(*(cmdname+j+1)))); j++ );
   if ( (*(aCommnew[i].name+j)==toupper(*(cmdname+j))) ||
       ( !aCommnew[i].com_or_xcom && j >= 4 && *(aCommnew[i].name+j)!='\0') )
   return kolcomm+i;
  }

 for ( i=(ncmd && ncmd<=kolcomm)? ncmd-1:kolcomm-1; i >= 0; i-- )
 {
  for ( j=0; (*(aCommands[i].name+j)==toupper(*(cmdname+j))) &&
             (*(aCommands[i].name+j)!='\0') &&
             ((aCommands[i].com_or_xcom)? 1:(j<4 || isname(*(cmdname+j+1)))); j++ );
  if ( (*(aCommands[i].name+j)==toupper(*(cmdname+j))) ||
       ( !aCommands[i].com_or_xcom && j >= 4 && *(aCommands[i].name+j)!='\0'
                                             && *(cmdname+j) == '\0' ) )
  break;
 }
 return i;
}

int TraSearch(char *cmdname, int ncmd)
{
 int i,j;

 for ( i=(ncmd>=0)? ncmd:koltranslates-1; i >= 0; i-- )
 {
  for ( j=0; *(aTranslates[i].name+j)==toupper(*(cmdname+j)) &&
             *(aTranslates[i].name+j)!='\0' &&
             ((aTranslates[i].com_or_xcom)? 1:(j<4 || isname(*(cmdname+j+1)))); j++ );
  if ( *(aTranslates[i].name+j)==toupper(*(cmdname+j)) ||
       ( !aTranslates[i].com_or_xcom && j >= 4 &&
          *(aTranslates[i].name+j)!='\0' && *(cmdname+j) == '\0' ) )
  break;
 }
 return i;
}

int ParseCommand( char* sLine, int com_or_xcom, int com_or_tra )
{
 static char mpatt[PATTERN_SIZE], rpatt[PATTERN_SIZE];
 char cmdname[MAX_NAME];
 int mlen,rlen;
 int ipos, rez;

 NextWord( &sLine, cmdname, FALSE );
 /*  NextName( &sLine, cmdname, NULL ); */
 SKIPTABSPACES(sLine);
 stroupper( cmdname );

 if ( (ipos = pp_strAt( "=>", 2, sLine, strolen(sLine) )) > 0 )
   stroncpy( mpatt, sLine, ipos-1 );
 else GenError( _szPErrors, 'P', ERR_COMMAND_DEFINITION, NULL, NULL );
 mlen = strotrim( mpatt );

 sLine += ipos + 1;
 SKIPTABSPACES(sLine);
 strocpy( rpatt, sLine );
 rlen = strotrim( rpatt );

 if ( (rez = ConvertPatterns ( mpatt, mlen, rpatt, rlen )) > 0 ) return rez;

 if ( com_or_tra )
 {
  AddCommand ( cmdname );
  aCommnew[kolcommands-1].com_or_xcom = com_or_xcom;
  aCommnew[kolcommands-1].mpatt = strodup ( mpatt );
  aCommnew[kolcommands-1].value = ( rlen > 0 )? strodup ( rpatt ) : NULL;
 }
 else
 {
  AddTranslate ( cmdname );
  aTranslates[koltranslates-1].com_or_xcom = com_or_xcom;
  aTranslates[koltranslates-1].mpatt = strodup ( mpatt );
  aTranslates[koltranslates-1].value = ( rlen > 0 )? strodup ( rpatt ) : NULL;
 }

 return 0;
}

int ConvertPatterns ( char *mpatt, int mlen, char *rpatt, int rlen )
{
 int i = 0, ipos, ifou;
 int explen,rmlen;
 char exppatt[MAX_NAME], expreal[5] = "\1  0";
 char lastchar = '@', exptype;
 char *ptr;

 while ( *(mpatt+i) != '\0' )
 {
  if ( *(mpatt+i) == '<' )
  {  /* Drag match marker, determine it type */
   explen = 0; ipos = i; i++; exptype = '0';
   if ( *(mpatt+i) == '*' ) { exptype = '3'; i++; }
   else if ( *(mpatt+i) == '(' ) { exptype = '4'; i++; }
   while ( *(mpatt+i) != '>' )
   {
    if ( *(mpatt+i) == ',' )
    {
     exptype = '1';
     while ( *(mpatt+i) != '>' ) i++;
     break;
    }
    else if ( *(mpatt+i) == ':' ) { exptype = '2'; break; }
    *(exppatt+explen++) = *(mpatt+i++);
   }
   if ( exptype == '3' )
   {
     if ( *(exppatt+explen-1) == '*' ) explen--;
     else GenError( _szPErrors, 'P', ERR_PATTERN_DEFINITION, NULL, NULL );
   }
   else if ( exptype == '4' )
   {
     if ( *(exppatt+explen-1) == ')' ) explen--;
     else GenError( _szPErrors, 'P', ERR_PATTERN_DEFINITION, NULL, NULL );
   }
   rmlen = i - ipos + 1;
     /* Replace match marker with new marker */
   lastchar = (char) ( (unsigned int)lastchar + 1 );
   expreal[1] = lastchar;
   expreal[2] = exptype;
   pp_Stuff ( expreal, mpatt+ipos, 4, rmlen, mlen );
   mlen += 4 - rmlen; i += 4 - rmlen;

   ptr = rpatt;
   while ( (ifou = pp_strAt( exppatt, explen, ptr, rlen-(ptr-rpatt) )) > 0 )
   {
    ptr += ifou;
    if ( *(ptr-2) == '<' && *(ptr+explen-1) == '>' )
    {
     if ( *(ptr-3) == '#' ) { exptype = '1'; ptr -= 3; rmlen = explen+3; }
     else { exptype = '0'; ptr -= 2; rmlen = explen+2; }
    }
    else if ( *(ptr-3) == '<' && *(ptr+explen) == '>' )
    {
     ptr -= 2;
     if ( *ptr == '\"' ) exptype = '2';
     else if ( *ptr == '(' ) exptype = '3';
     else if ( *ptr == '{' ) exptype = '4';
     else if ( *ptr == '.' ) exptype = '5';
     ptr--;
     rmlen = explen+4;
    }
    else continue;
    expreal[2] = exptype;
    pp_Stuff ( expreal, ptr, 4, rmlen, rlen );
    rlen += 4 - rmlen;
   }
  }
  i++;
 }
 return 0;
}

void AddCommand ( char *cmdname )
{
 if ( kolcommands == maxcommands )
 {
  maxcommands += 50;
  aCommnew = (COMMANDS *)_xrealloc( aCommnew, sizeof( COMMANDS ) * maxcommands );
 }
 aCommnew[kolcommands].name = strodup ( cmdname );
 kolcommands++;
}

void AddTranslate ( char *cmdname )
{
 if ( koltranslates == maxtranslates )
 {
  maxtranslates += 50;
  aTranslates = (TRANSLATES *)_xrealloc( aTranslates, sizeof( TRANSLATES ) * maxtranslates );
 }
 aTranslates[koltranslates].name = strodup ( cmdname );
 koltranslates++;
}

COMMANDS* getCommand ( int ndef )
{
 return (ndef>=kolcomm)? &(aCommnew[ndef-kolcomm]):&(aCommands[ndef]);
}

int ParseExpression( char* sLine, char* sOutLine )
{
  char sToken[MAX_NAME];
  char *ptri, *ptro;
  int lenToken, i, ndef, ipos, isdvig, lens;
  int rezDef, rezDefsub, rezCom, kolpass = 0;
  int kolused = 0, lastused;
  DEFINES *aUsed[100], *stdef;

  do
  {
    strotrim ( sLine );
    ptri = sLine; ptro = sOutLine;
    rezDef = 0; rezCom = 0;
    lastused = kolused;
    isdvig = 0;
    do
    {
      ptri = sLine + isdvig;
      ipos = md_strAt( ";", 1, ptri, FALSE );
      if ( ipos > 0 ) *(ptri+ipos-1) = '\0';
      SKIPTABSPACES( ptri );
      if ( *ptri == '#' )
      {
        ParseDirective( ptri+1 );
        lens = strolen( sLine+isdvig );
        pp_Stuff ( "", sLine+isdvig, 0, (ipos)? ipos-1:lens, lens );
      }
      else
      {
         /* Look for macros from #define      */
        rezDefsub = 0;
        while ( ( lenToken = NextName(&ptri, sToken, &ptro) ) > 0 )
        if ( (stdef=DefSearch(sToken)) != NULL )
        {
          for(i=0;i<kolused;i++) if ( aUsed[i] == stdef ) break;
          if ( i < kolused )
          {
            if ( i < lastused ) GenError( _szPErrors, 'P', ERR_RECURSE, NULL, NULL );
          }
          if ( WorkDefine ( &ptri, &ptro, stdef, lenToken ) )
          {
            aUsed[kolused++] = stdef;
            rezDef++; rezDefsub++;
          }
        }
        if ( rezDefsub )  /* if some defines was processed */
        {
          *ptro = '\0';
          ptri = sLine + isdvig;
          if ( isdvig + ipos > 0 )
          {
            lens = strolen( ptri );
            if ( ipos > 0 )
            {
              *(ptri+lens) = ';';
              lens += strolen( ptri+ipos );
            }
            pp_Stuff ( sOutLine, ptri, ptro - sOutLine + 1, (ipos)? ipos-1:lens, lens );
            if ( ipos > 0 )
            {
              ipos = strolen( ptri );
              *(ptri+ipos) = '\0';
            }
          }
          else
            memcpy ( sLine, sOutLine, ptro - sOutLine + 1);
        }

          /* Look for definitions from #translate    */
        ptri = sLine + isdvig;
        while ( ( lenToken = NextName(&ptri, sToken, NULL) ) > 0 )
          if ( (ndef=TraSearch(sToken,-1)) >= 0 )
          {
            if( (i = WorkTranslate( sToken, ptri, ptro, ndef, &lens )) >= 0 )
            {
              while ( lens > 0 && (*(ptri+lens-1)==' ' || *(ptri+lens-1)=='\t') )
                lens--;
              ptri -= lenToken;
              if ( ipos > 0 )  *(sLine+isdvig+ipos-1) = ';';
              pp_Stuff( ptro, ptri, i, lens+lenToken, strolen(ptri) );
              if ( ipos > 0 )
              {
                ipos += i - lens - lenToken;
                *(sLine+isdvig+ipos-1) = '\0';
              }
              ptri += i;
            }
          }

          /* Look for definitions from #command      */
        if ( kolpass < 3 )
        {
          ptri = sLine + isdvig;
          if ( isname(*ptri) )
            NextName( &ptri, sToken, NULL);
          else
          {
            i = 0;
            while ( *ptri != ' ' && *ptri != '\t' && *ptri != '\0' && !isname(*ptri) )
            {
              *(sToken+i) = *ptri++;
              i++;
            }
            *(sToken+i) = '\0';
          }
          SKIPTABSPACES( ptri );

          if ( *ptri != ':' && *ptri != '=' && (isname(*ptri) || *(ptri+1) != '=')
              && (ndef=ComSearch(sToken,0)) >= 0 )
          {
            ptro = sOutLine;
            i = WorkCommand( sToken, ptri, ptro, ndef );
            ptri = sLine + isdvig;
            if ( ipos > 0 ) *(ptri+ipos-1) = ';';
            if ( i >= 0 )
            {
              if ( isdvig + ipos > 0 )
              {
                lens = strolen( sLine+isdvig );
                pp_Stuff ( ptro, sLine+isdvig, i, (ipos)? ipos-1:lens, lens );
                if( ipos > 0 ) ipos = i + 1;
              }
              else
                memcpy ( sLine, sOutLine, i+1);
            }
            rezCom = 1;
          }
          else if ( ipos > 0 ) *(sLine+isdvig+ipos-1) = ';';
        }
      }
      isdvig += ipos;
    }
    while ( ipos != 0 );
    kolpass++;
  }
  while ( rezDef || rezCom );

 return 0;
}

int WorkDefine ( char** ptri, char** ptro, DEFINES *stdef, int lenToken )
{
 int rezDef = 0, npars;
 char *ptr;
    if ( stdef->npars < 0 )
    {
     rezDef = 1;
     *ptro -= lenToken;
     lenToken = 0;
     while ( *(stdef->value+lenToken) != '\0' )
      *(*ptro)++ = *(stdef->value+lenToken++);
    }
    else
    {
     SKIPTABSPACES( *ptri );
     if ( **ptri == '(' )
     {
      npars = 0; ptr = *ptri;
      do
      {
        ptr++;
        if ( NextParm( &ptr, NULL ) > 0 ) npars++;
      }
      while ( *ptr != ')' && *ptr != '\0' );
      if ( *ptr == ')' && stdef->npars == npars )
      {
       rezDef = 1;
       *ptro -= lenToken;
       WorkPseudoF( ptri, ptro, stdef );
      }
     }
     else *(*ptro)++ = ' ';
    }
    return rezDef;
}

void WorkPseudoF ( char** ptri, char** ptro, DEFINES *stdef )
{
   char parfict[MAX_NAME], parreal[MAX_NAME];
   char *ptrb;
   int ipos = 0, ifou, ibeg;
   int lenfict, lenreal, lenres;

   while ( *(stdef->value+ipos) != '\0' ) /* Copying value of macro */
   {                                              /* to destination string  */
     *(*ptro+ipos) = *(stdef->value+ipos);
    ipos++;
   }
   *(*ptro+ipos) = '\0';
   lenres = ipos;

   if ( stdef->pars )
   {
     ipos = 0; ibeg = 0;
     do                               /* Parsing through parameters */
     {                                /* in macro definition        */
       if ( *(stdef->pars+ipos)==',' || *(stdef->pars+ipos)=='\0' )
       {
         *(parfict+ipos-ibeg) = '\0';
         lenfict = ipos - ibeg;

         if ( **ptri != ')' )
         {
           (*ptri)++;                 /* Parsing through real parameters */
           lenreal = NextParm( ptri, parreal );

           ptrb = *ptro;
           while ( (ifou = pp_strAt( parfict, lenfict, ptrb, lenres-(ptrb-*ptro) )) > 0 )
           {
             ptrb = ptrb+ifou-1;
             if ( !isname(*(ptrb-1)) && !isname(*(ptrb+lenfict)) )
             {
               pp_Stuff ( parreal, ptrb, lenreal, lenfict, lenres );
               lenres += lenreal - lenfict;
             }
             else ptrb++;
           }
           ibeg = ipos+1;
         }
       }
       else *(parfict+ipos-ibeg) = *(stdef->pars+ipos);
       if ( *(stdef->pars+ipos) == '\0' ) break;
       ipos++;
     }
     while ( 1 );
   }
   else  while ( **ptri != ')' ) (*ptri)++;
   (*ptri)++;
   *ptro += lenres;
}

int WorkCommand ( char* sToken, char* ptri, char* ptro, int ndef )
{
 int rez;
 int lenres;
 char *ptrmp;

 do
 {
  lenres = strocpy ( ptro, getCommand(ndef)->value ); /* Copying result pattern */
  ptrmp = getCommand(ndef)->mpatt;                    /* Pointer to a match pattern */
  Repeate = 0;
  groupchar = '@';
  rez = CommandStuff ( ptrmp, ptri, ptro, &lenres, TRUE );

  if ( rez < 0 ) ndef = ComSearch(sToken,ndef);
 }
 while ( rez < 0 && ndef >= 0 );

 *(ptro+lenres) = '\0';
 if ( rez >= 0 ) return lenres;
 return -1;
}

int WorkTranslate ( char* sToken, char* ptri, char* ptro, int ndef, int *lens )
{
 int rez;
 int lenres;
 char *ptrmp;

 do
 {
  lenres = strocpy ( ptro, aTranslates[ndef].value );
  ptrmp = aTranslates[ndef].mpatt;
  Repeate = 0;
  groupchar = '@';
  rez = CommandStuff ( ptrmp, ptri, ptro, &lenres, FALSE );

  if ( rez < 0 ) ndef = TraSearch(sToken,ndef-1);
 }
 while ( rez < 0 && ndef >= 0 );

 *(ptro+lenres) = '\0';
 if ( rez >= 0 )
 {
   *lens = rez;
   return lenres;
 }
 return -1;
}

int CommandStuff ( char *ptrmp, char *inputLine, char * ptro, int *lenres, int com_or_tra )
{
 int nbr = 0, endTranslation = FALSE;
 char *lastopti[2];
 char *ptri = inputLine, *ptr;

  SKIPTABSPACES( ptri );
  if ( ptrmp == NULL ) { if ( *ptri != '\0' ) return -1; }
  else
   while ( *ptri != '\0' && !endTranslation )
   {
     SKIPTABSPACES( ptrmp );
     SKIPTABSPACES( ptri );
     switch ( *ptrmp ) {
      case '[':
       nbr++;
       lastopti[Repeate++] = ptrmp;
       ptrmp++;
       break;
      case ']':
        if ( Repeate ) { Repeate--; ptrmp = lastopti[Repeate]; nbr--; }
        else { nbr--; ptrmp++; }
        break;
      case ',':
       if ( *ptri == ',' ) { ptrmp++; ptri++; }
       else
       {
        if ( nbr )
        {
          SkipOptional( &ptrmp, ptro, lenres, &nbr);
        }
        else return -1;
       }
       break;
      case '\1':  /*  Match marker */
       if ( !WorkMarkers( &ptrmp, &ptri, ptro, lenres, nbr ) )
       {
         if ( nbr )
         {
           SkipOptional( &ptrmp, ptro, lenres, &nbr);
         }
         else return -1;
       }
       break;
      case '\0':
       if ( com_or_tra ) return -1; else endTranslation = TRUE;
       break;
      default:    /*   Key word    */
       ptr = ptrmp;
       if ( *ptri == ',' || strincmp(ptri, &ptrmp ) )
       {
        if ( nbr )
        {
           SkipOptional( &ptrmp, ptro, lenres, &nbr);
        }
        else return -1;
       }
       else if ( *ptri != ',' ) ptri += (ptrmp - ptr);
     }
   };

  if ( *ptrmp != '\0' )
  {
   if ( Repeate ) { Repeate = 0; ptrmp = lastopti[0]; }
   do
   {
    SKIPTABSPACES( ptrmp );
    if ( *ptrmp != '\0' )
     switch ( *ptrmp ) {
      case '[':
       ptrmp++;
       SkipOptional( &ptrmp, ptro, lenres, NULL);
       ptrmp++;
       break;
      case ']': ptrmp++; break;
      default:
       return -1;
     }
   }
   while ( *ptrmp != '\0' );
  }
  if ( com_or_tra ) return 1; else return (ptri-inputLine);
}

int WorkMarkers( char **ptrmp, char **ptri, char *ptro, int *lenres, int nbr )
{
 char expreal[MAX_NAME], exppatt[MAX_NAME];
 int lenreal = 0, maxlenreal = STR_SIZE, lenpatt;
 int rezrestr, ipos;
 char *ptr, *ptrtemp;

         /* Copying a match pattern to 'exppatt' */
  lenpatt = stroncpy ( exppatt, *ptrmp, 4 );
  *ptrmp += 4;
  SKIPTABSPACES ( *ptrmp );
  if ( **ptri == ',' )
  {
    if ( nbr )
    {
      SearnRep( exppatt,"",0,ptro,lenres);
      return 0;
    }
  }
  ptrtemp = *ptrmp;
  if ( *(exppatt+2) != '2' && *ptrtemp == ']' )
  {
    ptrtemp++;
    SKIPTABSPACES ( ptrtemp );
  }
  if ( *(exppatt+2) != '2' && *ptrtemp != '\1' && *ptrtemp != ',' &&
        *ptrtemp != '[' && *ptrtemp != ']' && *ptrtemp != '\0' )
  {
   lenreal = strincpy ( expreal, ptrtemp );
   if ( (ipos = md_strAt( expreal, lenreal, *ptri, TRUE )) > 0 )
   {
    if ( ptrtemp > *ptrmp )
    {
      if ( ipos == 1 )
      {
        if ( nbr )
        {
          SearnRep( exppatt,"",0,ptro,lenres);
          return 0;
        }
      }
      else
      {
        maxlenreal = ipos - 1;
        lenreal = 0;
      }
    }
    else
    {
      lenreal = stroncpy( expreal, *ptri, ipos-1 );
      if ( ipos > 1 && isExpres ( expreal ) )
         *ptri += lenreal;
      else
      {
        if ( nbr )
        {
          SearnRep( exppatt,"",0,ptro,lenres);
          return 0;
        }
      }
    }
   }
   else
   {
     if ( nbr )
     {
       SearnRep( exppatt,"",0,ptro,lenres);
       return 0;
     }
     else lenreal = 0;
   }
  }

  if ( *(exppatt+2) == '4' )       /*  ----  extended match marker  */
  {
    if ( !lenreal ) lenreal = getExpReal ( expreal, ptri, FALSE, maxlenreal );
    SearnRep( exppatt,expreal,lenreal,ptro,lenres);
  }
  else if ( *(exppatt+2) == '3' )  /*  ----  wild match marker  */
  {
    lenreal = strocpy ( expreal, *ptri );
    *ptri += lenreal;
    SearnRep( exppatt,expreal,lenreal,ptro,lenres);
  }
  else if ( *(exppatt+2) == '2' )  /*  ---- restricted match marker  */
  {
   while ( **ptrmp != '>' ) *(exppatt+lenpatt++) = *((*ptrmp)++);
   *(exppatt+lenpatt) = '\0';
   (*ptrmp)++;

   ptr = exppatt + 4;
   rezrestr = 0;
   while ( *ptr != '\0' )
   {
     if ( *ptr == '&' )
     {
       if ( **ptri == '&' )
       {
         rezrestr = 1;
         /*  (*ptri)++; */
         lenreal = getExpReal ( expreal, ptri, FALSE, maxlenreal );
         SearnRep( exppatt,expreal,lenreal,ptro,lenres);
         break;
       }
       else ptr++;
     }
     else
     {
       SKIPTABSPACES( ptr );
           /* Comparing real parameter and restriction value */
       ptrtemp = ptr;
       if ( !strincmp ( *ptri, &ptr ) )
       {
         lenreal = stroncpy( expreal, *ptri, (ptr-ptrtemp) );
         *ptri += lenreal;
         SearnRep( exppatt,expreal,lenreal,ptro,lenres);
         rezrestr = 1;
         break;
       }
       else
       {
          while ( *ptr != ',' && *ptr != '\0' ) ptr++;
          if ( *ptr == ',' ) ptr++;
       }
     }
   }
   if ( rezrestr == 0 )
   {  /* If restricted match marker doesn't correspond to real parameter */
      if ( nbr )
      {
        SearnRep( exppatt,"",0,ptro,lenres);
        return 0;
      }
   }
  }
  else if ( *(exppatt+2) == '1' )  /*  ---- list match marker  */
  {
     if ( !lenreal ) lenreal = getExpReal ( expreal, ptri, TRUE, maxlenreal );
     SearnRep( exppatt,expreal,lenreal,ptro,lenres);
  }
  else                             /*  ---- regular match marker  */
  {
               /* Copying a real expression to 'expreal' */
     if ( !lenreal ) lenreal = getExpReal ( expreal, ptri, FALSE, maxlenreal );
     SearnRep( exppatt,expreal,lenreal,ptro,lenres);
  }
  return 1;
}

int getExpReal ( char *expreal, char **ptri, int prlist, int maxrez )
{
 int lens = 0;
 char *sZnaki = "+-=><*/$.&:#";
 int State;
 int StBr1 = 0, StBr2 = 0, StBr3 = 0;
 int rez = 0;

 SKIPTABSPACES ( *ptri );
 State = (**ptri=='\'' || **ptri=='\"')? STATE_EXPRES:STATE_ID;
 while ( **ptri != '\0' && !rez && lens < maxrez )
 {
  switch ( State ) {
    case STATE_QUOTE1:
     if(**ptri=='\'')
      State = (StBr1==0 && StBr2==0 && StBr3==0)? STATE_ID_END:STATE_BRACKET;
     break;
    case STATE_QUOTE2:
     if(**ptri=='\"')
      State = (StBr1==0 && StBr2==0 && StBr3==0)? STATE_ID_END:STATE_BRACKET;
     break;
    case STATE_BRACKET:
     if ( **ptri == '\'' ) State = STATE_QUOTE1;
     else if ( **ptri == '\"' ) State = STATE_QUOTE2;
     else if ( **ptri == '(' ) StBr1++;
     else if ( **ptri == '[' ) StBr2++;
     else if ( **ptri == '{' ) StBr3++;
     else if ( **ptri == ')' )
     { StBr1--; if (StBr1==0 && StBr2==0 && StBr3==0) State = STATE_ID_END; }
     else if ( **ptri == ']' )
     { StBr2--; if (StBr1==0 && StBr2==0 && StBr3==0) State = STATE_ID_END; }
     else if ( **ptri == '}' )
     { StBr3--; if (StBr1==0 && StBr2==0 && StBr3==0) State = STATE_ID_END; }
     break;
    case STATE_ID:
    case STATE_ID_END:
     if ( ( (isname(**ptri) || **ptri=='\\') && State == STATE_ID_END ) ||
          **ptri==',' || **ptri=='\'' || **ptri=='\"')
     {
      if ( **ptri == ',' )
      {
       if ( !prlist ) rez = 1;
       State = STATE_EXPRES;
      }
      else rez = 1;
     }
     else if ( IsInStr( **ptri, sZnaki ) )
     {
      State = STATE_EXPRES;
     }
     else if ( **ptri == '(' )
     {
      State = STATE_BRACKET;
      StBr1 = 1;
     }
     else if ( **ptri == '[' )
     {
      State = STATE_BRACKET;
      StBr2 = 1;
     }
     else if ( **ptri == '{' )
     {
      State = STATE_BRACKET;
      StBr3 = 1;
     }
     else if ( **ptri == ' ' ) State = STATE_ID_END;
     break;
    case STATE_EXPRES:
    case STATE_EXPRES_ID:
     if ( **ptri == '\'' ) State = STATE_QUOTE1;
     else if ( **ptri == '\"' ) State = STATE_QUOTE2;
     else if ( isname(**ptri) ) State = STATE_EXPRES_ID;
     else if ( **ptri == ' ' && State == STATE_EXPRES_ID ) State = STATE_ID_END;
     else if ( **ptri == '(' ) { StBr1++; State = STATE_BRACKET; }
     else if ( **ptri == '[' ) { StBr2++; State = STATE_BRACKET; }
     else if ( **ptri == '{' ) { StBr3++; State = STATE_BRACKET; }
     else if ( **ptri == ',' ) { if ( !prlist ) rez = 1; State = STATE_EXPRES; }
     else State = STATE_EXPRES;
     break;
  }
  if ( !rez )
  {
   if ( expreal != NULL ) *expreal++ = **ptri;
   (*ptri)++;
   lens++;
  }
 }
 if ( expreal != NULL )
 {
  if ( *(expreal-1) == ' ' ) { expreal--; lens--; };
  *expreal = '\0';
 }
 return lens;
}

int isExpres ( char* stroka )
{
 if ( strolen ( stroka ) > getExpReal ( NULL, &stroka, FALSE, STR_SIZE ) )
  return 0;
 else
  return 1;
}

void SkipOptional( char** ptri, char *ptro, int* lenres, int* pnbr)
{
 int nbr = 0;
 char exppatt[MAX_NAME];
 int lenpatt;

 while ( isname(**ptri) ) (*ptri)++;
 SKIPTABSPACES( *ptri );
 while ( **ptri != ']' || nbr )
 {
  switch ( **ptri ) {
   case '[':  nbr++; break;
   case ']':  nbr--; break;
   case '\1':
     if ( pnbr == NULL || *pnbr < 2 )
     {
       for ( lenpatt=0; lenpatt<4; lenpatt++ ) *(exppatt+lenpatt) = *((*ptri)++);
       (*ptri)--;
       if ( exppatt[2] == '2' )
         while ( **ptri != '>' ) (*ptri)++;
       SearnRep( exppatt,"",0,ptro,lenres);
     }
     break;
  }
  (*ptri)++;
 }
   if ( **ptri == ']' && pnbr != NULL )
   {
     if ( Repeate ) Repeate--;
     (*pnbr)--; (*ptri)++;
   }
}

void SearnRep( char *exppatt,char *expreal,int lenreal,char *ptro, int *lenres)
{
   int ifou, isdvig = 0, rezs;
   int kolmarkers;
   int lennew, i;
   char lastchar = '0';
   char expnew[MAX_NAME];
   char *ptr, *ptr2, *ptrOut = ptro;

   while ( (ifou = pp_strAt( exppatt, 2, ptrOut, *lenres-isdvig )) > 0 )
   {
     rezs = 0;
     ptr = ptrOut + ifou - 2;
     kolmarkers = 0;
     while ( ptr >= ptrOut )
     {
       if ( *ptr == '[' || *ptr == ']' ) break;
       if  ( *ptr == '\1' ) kolmarkers++;
       ptr--;
     }
     if ( *ptr == '[' )
     {
       ptr2 = ptrOut + ifou + 3;
       while ( *ptr2 != ']' ) { if ( *ptr2 == '\1' ) kolmarkers++; ptr2++; }
       if ( Repeate && lenreal && kolmarkers && lastchar != '0' &&
                                             *(ptrOut + ifou + 2) == '0' )
       {
         isdvig += ifou;
         rezs = 1;
       }
       else
       {
         if ( lenreal == 0 )
         {
           pp_Stuff ( "", ptr, 0, ptr2-ptr+1, *lenres-(ptr-ptro) );
           *lenres -= ptr2-ptr+1;
           isdvig = ptr - ptro;
           rezs = 1;
         }
         else
         {
           lennew = ptr2-ptr-1;

           memcpy ( expnew, ptr+1, lennew );
           *(expnew + lennew++) = ' ';
           *(expnew + lennew) = '\0';
           while ( (i = pp_strAt( exppatt, 2, expnew, lennew )) > 0 )
             lennew += ReplacePattern ( exppatt[2], expreal, lenreal, expnew+i-1, lennew );
           if ( kolmarkers )
           {
             groupchar = (char) ( (unsigned int)groupchar + 1 );
             for ( i=0; i<lennew; i++ )
               if ( *(expnew+i) == '\1' )
               {
                 *(expnew+i+3) = groupchar;
                 i += 4;
               }
           }
           pp_Stuff ( expnew, ptr, lennew, 0, *lenres-(ptr-ptro)+1 );
           *lenres += lennew;
           isdvig = ptr - ptro + (ptr2-ptr-1) + lennew;
           rezs = 1;
         }
       }
     }
     if ( !rezs )
     {
       if ( *(ptrOut + ifou + 2) != '0' )
       {
         if ( lastchar == '0' ) lastchar = *(ptrOut + ifou + 2);
         if ( lastchar != *(ptrOut + ifou + 2) )
         {
           isdvig += ifou + 3;
           ptrOut = ptro + isdvig;
           continue;
         }
       }
       *lenres += ReplacePattern ( exppatt[2], expreal, lenreal,
                             ptrOut + ifou - 1, *lenres-isdvig-ifou+1 );
       isdvig += ifou;
     }
     ptrOut = ptro + isdvig;
   }
}

int ReplacePattern ( char patttype, char *expreal, int lenreal, char *ptro, int lenres )
{
 int rmlen = lenreal;
 char *sQuotes = "\"\"";

     switch ( *(ptro+2) ) {
      case '0':  /* Regular result marker  */
         pp_Stuff ( expreal, ptro, lenreal, 4, lenres );
         break;
      case '1':  /* Dumb stringify result marker  */
         pp_rQuotes( expreal, &sQuotes );
         pp_Stuff ( sQuotes, ptro, 2, 4, lenres );
         if ( lenreal )
          pp_Stuff ( expreal, ptro+1, lenreal, 0, lenres );
         rmlen = lenreal + 2;
         break;
      case '2':  /* Normal stringify result marker  */
         if ( !lenreal )
          pp_Stuff ( "", ptro, 0, 4, lenres );
         else if ( patttype == '1' )          /* list match marker */
         {
         }
         else
         {
          pp_rQuotes( expreal, &sQuotes );
          pp_Stuff ( sQuotes, ptro, 2, 4, lenres );
          pp_Stuff ( expreal, ptro+1, lenreal, 0, lenres );
          rmlen = lenreal + 2;
         }
         break;
      case '3':  /* Smart stringify result marker  */
         if ( patttype == '1' )          /* list match marker */
         {
         }
         else if ( !lenreal || *expreal == '(' || *expreal == '&' ||
                                  *expreal == '\"' || *expreal == '\'' )
           pp_Stuff ( (*expreal=='&')? expreal+1:expreal, ptro,
                   (*expreal=='&')? lenreal-1:lenreal, 4, lenres );
         else
         {
          pp_rQuotes( expreal, &sQuotes );
          pp_Stuff ( sQuotes, ptro, 2, 4, lenres );
          pp_Stuff ( expreal, ptro+1, lenreal, 0, lenres );
          rmlen = lenreal + 2;
         }
         break;
      case '4':  /* Blockify result marker  */
         if ( !lenreal )
           pp_Stuff ( expreal, ptro, lenreal, 4, lenres );
         else if ( patttype == '1' )          /* list match marker */
         {
         }
         else
         {
          pp_Stuff ( "{||}", ptro, 4, 4, lenres );
          pp_Stuff ( expreal, ptro+3, lenreal, 0, lenres );
          rmlen = lenreal + 4;
         }
         break;
      case '5':  /* Logify result marker  */
         rmlen = 3;
         if ( !lenreal )
         {
          pp_Stuff ( ".F.", ptro, 3, 4, lenres );
         }
         else
          pp_Stuff ( ".T.", ptro, 3, 4, lenres );
         break;
     }
     return rmlen - 4;
}

void pp_rQuotes( char *expreal, char **sQuotes )
{
   int lQuote1 = 0, lQuote2 = 0;

   while( *expreal != '\0' )
   {
     if( *expreal == '\"' ) lQuote2 = 1;
     else if( *expreal == '\'' ) lQuote1 = 1;
     expreal++;
   }
   if( lQuote2 )
   {
     if( lQuote1 )
       { **sQuotes = '['; *(*sQuotes+1) = ']'; }
     else
       { **sQuotes = '\''; *(*sQuotes+1) = '\''; }
   }
}

int pp_RdStr(FILE* handl_i,char *buffer,int maxlen,int lDropSpaces,char* sBuffer, int* lenBuffer, int* iBuffer)
{
int readed = 0;
int State = 0;
char cha,cLast='\0';
  if ( *lenBuffer == 0 ) return -1;
  while(1)
  {
   if ( *iBuffer == *lenBuffer )
   {
    if ( (*lenBuffer = fread(sBuffer,1,BUFF_SIZE,handl_i)) < 1 ) sBuffer[0] = '\n';
    *iBuffer = 0;
   }
   cha = sBuffer[*iBuffer];
   (*iBuffer)++;
   if( cha == '\n' )  break;
   if ( maxlen > 0 )
   {
    switch ( ParseState ) {
      case STATE_COMMENT:
       if ( cha == '/' && cLast == '*' )
        { ParseState = STATE_NORMAL; cha = ' '; }
       cLast = cha;
       break;
      case STATE_QUOTE1: if(cha=='\'') ParseState = STATE_NORMAL; break;
      case STATE_QUOTE2: if(cha=='\"') ParseState = STATE_NORMAL; break;
      default:
       switch ( cha ) {
        case '\"': ParseState = STATE_QUOTE2; break;
        case '\'': ParseState = STATE_QUOTE1; break;
        case '&': if ( readed>0 && buffer[readed-1] == '&' ) { maxlen = 0; readed--; } break;
        case '/': if ( readed>0 && buffer[readed-1] == '/' ) { maxlen = 0; readed--; } break;
        case '*':
         if ( readed > 0 && buffer[readed-1] == '/' )
          { ParseState = STATE_COMMENT; readed--; }
         else if ( !State ) maxlen = readed = 0;
         break;
       }
    }
    if ( cha != ' ' && cha != '\t' ) State = 1;
    if( lDropSpaces && State ) lDropSpaces = 0;
    if( readed<maxlen && (!lDropSpaces || readed==0) &&
       ParseState != STATE_COMMENT )
     buffer[readed++]=cha;
   }
  }
  while(--readed >= 0 && ( buffer[readed] == ' ' || buffer[readed] == '\t') );
  readed++;
  buffer[readed]='\0';
  return readed;
}

int pp_WrStr(FILE* handl_o,char *buffer)
{
 int lens = strolen(buffer);
 fwrite(buffer,lens,1,handl_o);
 if ( *(buffer+lens-1) != '\n' ) fwrite("\n",1,1,handl_o);
 return 0;
}

/* locates a substring in a string */
int pp_strAt(char *szSub, int lSubLen, char *szText, int lLen)
{
   if( lSubLen )
   {
      if( lLen >= lSubLen )
      {
         long lPos = 0, lSubPos = 0;

         while( lPos < lLen && lSubPos < lSubLen )
         {
            if( *(szText + lPos) == *(szSub + lSubPos) )
            {
               lSubPos++;
               lPos++;
            }
            else if( lSubPos )
               lSubPos = 0;
            else
               lPos++;
         }
         return (lSubPos < lSubLen? 0: lPos - lSubLen + 1);
      }
      else
         return 0;
   }
   else
      return 1;
}

int md_strAt(char *szSub, int lSubLen, char *szText, int checkPrth)
{
 int State = STATE_NORMAL;
 long lPos = 0, lSubPos = 0;
 int kolPrth = 0;

   while( *(szText+lPos) != '\0' && lSubPos < lSubLen )
   {
     if( State == STATE_QUOTE1 )
     {
       if ( *(szText+lPos) == '\'' ) State = STATE_NORMAL;
       lPos++;
     }
     else if( State == STATE_QUOTE2 )
     {
       if ( *(szText+lPos) == '\"' ) State = STATE_NORMAL;
       lPos++;
     }
     else
     {
       if ( *(szText+lPos) == '\"' )
       {
         State = STATE_QUOTE2;
         lPos++;
         continue;
       }
       else if ( *(szText+lPos) == '\'' )
       {
         State = STATE_QUOTE1;
         lPos++;
         continue;
       }
       else if ( *(szText+lPos) == '(' )
         kolPrth++;
       else if ( *(szText+lPos) == ')' )
         kolPrth--;
       if( checkPrth && ( (kolPrth > 0) || (kolPrth == 0 && *(szText+lPos) == ')') ) )
       {
         lPos++;
         lSubPos = 0;
         continue;
       }

       if( toupper(*(szText + lPos)) == toupper(*(szSub + lSubPos)) )
       {
         lSubPos++;
         lPos++;
         if ( lSubPos >= lSubLen  &&
          ( ( isname(*szSub) && lPos>lSubPos && isname(*(szText+lPos-lSubPos-1)) ) ||
            ( isname(*(szSub+lSubLen-1)) && isname(*(szText+lPos)) ) ) )
          lSubPos = 0;
       }
       else if( lSubPos )  lSubPos = 0;
       else  lPos++;
     }
   }
   return (lSubPos < lSubLen? 0: lPos - lSubLen + 1);
}

int IsInStr ( char symb, char* s )
{
 while ( *s != '\0' ) if ( *s++ == symb ) return 1;
 return 0;
}

void pp_Stuff (char *ptri, char * ptro, int len1, int len2, int lenres )
{
 char *ptr1, *ptr2;
 int i;
  if ( len1 > len2 )
  {
   ptr1 = ptro+lenres;
   ptr2 = ptro + lenres + len1 - len2;
   for ( ; ptr1 >= ptro; ptr1--,ptr2-- ) *ptr2 = *ptr1;
  }
  else
  {
   ptr1 = ptro + len2;
   ptr2 = ptro + len1;
   for ( ; ptr1 <= ptro+lenres; ptr1++,ptr2++ ) *ptr2 = *ptr1;
  }
  ptr2 = ptro;
  for ( i=0; i < len1; i++ ) *ptr2++ = *(ptri+i);
}

int strocpy (char* ptro, char* ptri )
{
 int lens = 0;
 if ( ptri != NULL )
  while ( *ptri != '\0' )
  {
    *ptro++ = *ptri++;
    lens++;
  }
 *ptro = '\0';
 return lens;
}

int stroncpy (char* ptro, char* ptri, int lens )
{
 int i = 0;
 for ( ; i < lens; i++ ) *(ptro+i) = *ptri++;
 i--;
 while ( i > 0 && *(ptro+i) == ' ' ) i--;
 i++;
 *(ptro+i) = '\0';
 return i;
}

int strincmp (char* ptro, char** ptri )
{
 for ( ; **ptri != ' ' && **ptri != ',' && **ptri != '[' && **ptri != ']' &&
   **ptri != '\1' && **ptri != '\0' && toupper(**ptri)==toupper(*ptro);
     ptro++, (*ptri)++ );
 if ( **ptri == ' ' || **ptri == ',' || **ptri == '[' ||
              **ptri == ']' || **ptri == '\1' || **ptri == '\0' ) return 0;
 return 1;
}

int strincpy (char* ptro, char* ptri )
{
 int lens = 0;
 for ( ; *ptri != ' ' && *ptri != ',' && *ptri != '[' && *ptri != ']' &&
                   *ptri != '\1' && *ptri != '\0'; ptro++, ptri++, lens++ )
  *ptro = *ptri;
 return lens;
}

char* strodup ( char *stroka )
{
 char *ptr;
 int lens = 0;
  while ( *(stroka+lens) != '\0' ) lens++;
  ptr = ( char * ) _xgrab( lens + 1 );
  memcpy( ptr,  stroka, lens+1 );
  *(ptr+lens) = '\0';
  return ptr;
}

int strolen ( char *stroka )
{
 int lens = 0;
  while ( *(stroka+lens) != '\0' ) lens++;
  return lens;
}

void stroupper ( char *stroka )
{
  while ( *stroka != '\0' )
  {
    *stroka = toupper(*stroka);
    stroka++;
  }
}

int strotrim ( char *stroka )
{
 char *ptr = stroka, lastc = '0';
 int lens = 0, State = STATE_NORMAL;
 while ( *stroka != '\0' )
 {
  if ( State == STATE_QUOTE1 ) { if (*stroka == '\'') State = STATE_NORMAL; }
  else if ( State == STATE_QUOTE2 ) { if (*stroka=='\"') State = STATE_NORMAL; }
  else
  {
   if ( *stroka == '\'' ) State = STATE_QUOTE1;
   else if ( *stroka == '\"' ) State = STATE_QUOTE2;
  }
/*  if ( State != STATE_NORMAL || (*stroka != ' ' && *stroka != '\t') ||
      ( (isname(lastc) || lastc=='>') && (isname(*(stroka+1)) || *(stroka+1)=='<') ) )
*/
  if ( State != STATE_NORMAL || (*stroka != ' ' && *stroka != '\t') ||
      ( *stroka==' ' && lastc != ' ' && lastc != ',' && lastc != '(' && *(stroka+1)!=',') )
  {
     *ptr++ = *stroka;
     lastc = *stroka;
     lens++;
  }
  stroka++;
 }
 *ptr = '\0';
 return lens;
}

int NextWord ( char** sSource, char* sDest, int lLower )
{
 int i = 0;
 SKIPTABSPACES( (*sSource) );
 while ( **sSource != '\0' && **sSource != ' ' && **sSource != '\t' && **sSource != '(')
 {
   *sDest++ = (lLower)? tolower(**sSource):**sSource;
   (*sSource)++;
   i++;
 }
 *sDest = '\0';
 return i;
}

int NextName ( char** sSource, char* sDest, char **sOut )
{
 int lenName = 0, State = STATE_NORMAL;
 while ( **sSource != '\0' && ( !isname(**sSource) || State != STATE_NORMAL ) )
 {
  if ( State == STATE_QUOTE1 )
   { if ( **sSource == '\'' ) State = STATE_NORMAL; }
  else if ( State == STATE_QUOTE2 )
   { if ( **sSource == '\"' ) State = STATE_NORMAL; }
  else if ( **sSource == '\"' ) State = STATE_QUOTE2;
  else if ( **sSource == '\'' ) State = STATE_QUOTE1;

  if ( sOut !=NULL ) *(*sOut)++ = **sSource;
  (*sSource)++;
 }

 while ( **sSource != '\0' && isname(**sSource) )
  {
   if ( sOut !=NULL ) *(*sOut)++ = **sSource;
   *sDest++ = *(*sSource)++;
   lenName++;
  }
 *sDest = '\0';
 return lenName;
}

int NextParm ( char** sSource, char* sDest )
{
   int lenName = 0, State = STATE_NORMAL;

   SKIPTABSPACES( (*sSource) );
   while ( **sSource != '\0' )
   {
     if ( State == STATE_QUOTE1 )
     { if ( **sSource == '\'' ) State = STATE_NORMAL; }
     else if ( State == STATE_QUOTE2 )
     { if ( **sSource == '\"' ) State = STATE_NORMAL; }
     else if ( **sSource == '\"' ) State = STATE_QUOTE2;
     else if ( **sSource == '\'' ) State = STATE_QUOTE1;
     else if ( **sSource == ',' || **sSource == ')' ) break;

     if ( sDest != NULL ) *sDest++ = **sSource;
     (*sSource)++;
     lenName++;
   }

   if ( sDest != NULL ) *sDest = '\0';
   return lenName;
}

int OpenInclude( char * szFileName, PATHNAMES *pSearch, FILE** fptr )
{
  if( ! ( *fptr = fopen( szFileName, "r" ) ) )
  {
    if( pSearch )
    {
      FILENAME *pFileName =SplitFilename( szFileName );
      char szFName[ _POSIX_PATH_MAX ];    /* filename to parse */

      pFileName->name =szFileName;
      pFileName->extension =NULL;
      while( pSearch && !*fptr )
      {
        pFileName->path =pSearch->szPath;
        MakeFilename( szFName, pFileName );
        if( ! ( *fptr = fopen( szFName, "r" ) ) )
        {
            pSearch = pSearch->pNext;
            if( ! pSearch )
              return 0;
        }
      }
      _xfree( pFileName );
    }
    else
      return 0;
  }
  return 1;
}

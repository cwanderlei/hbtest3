/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * Compiler Expression Optimizer
 *
 * Copyright 1999 Ryszard Glab
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version, with one exception:
 *
 * The exception is that if you link the Harbour Runtime Library (HRL)
 * and/or the Harbour Virtual Machine (HVM) with other files to produce
 * an executable, this does not by itself cause the resulting executable
 * to be covered by the GNU General Public License. Your use of that
 * executable is in no way restricted on account of linking the HRL
 * and/or HVM code into it.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA (or visit
 * their web site at http://www.gnu.org/).
 *
 */

/* TOFIX: Split the code, since MSC8 can't compile it, even in Huge model. */

/* TODO:
 *    - Correct post- and pre- operations to correctly handle the following code
 *    a[ i++ ]++
 *    Notice: in current implementation (an in Clipper too) 'i++' is evaluated
 *    two times! This causes that the new value (after incrementation) is
 *    stored in next element of the array.
 */

#include <math.h>
#include "hbcomp.h"

/* memory allocation
 */
#define  HB_XGRAB( size )  hb_xgrab( (size) )
#define  HB_XFREE( pPtr )  hb_xfree( (void *)(pPtr) )


/* Table with operators precedence
 * NOTE:
 *    HB_ET_NIL is used for an ordinary values and post- operators
 *    HB_ET_NONE is used for invalid syntax, e.g. var := var1 += 2
 */
static BYTE s_PrecedTable[] = {
   HB_ET_NIL,                 /*   HB_ET_NONE = 0,    */
   HB_ET_NIL,                 /*   HB_ET_NIL,         */
   HB_ET_NIL,                 /*   HB_ET_NUMERIC,     */
   HB_ET_NIL,                 /*   HB_ET_STRING,      */
   HB_ET_NIL,                 /*   HB_ET_CODEBLOCK,   */
   HB_ET_NIL,                 /*   HB_ET_LOGICAL,     */
   HB_ET_NIL,                 /*   HB_ET_SELF,        */
   HB_ET_NIL,                 /*   HB_ET_ARRAY,       */
   HB_ET_NIL,                 /*   HB_ET_VARREF,      */
   HB_ET_NIL,                 /*   HB_ET_FUNREF,      */
   HB_ET_NIL,                 /*   HB_ET_IIF,         */
   HB_ET_NIL,                 /*   HB_ET_LIST,        */
   HB_ET_NIL,                 /*   HB_ET_ARGLIST,     */
   HB_ET_NIL,                 /*   HB_ET_ARRAYAT,     */
   HB_ET_NIL,                 /*   HB_ET_MACRO,       */
   HB_ET_NIL,                 /*   HB_ET_FUNCALL,     */
   HB_ET_NIL,                 /*   HB_ET_ALIASVAR,    */
   HB_ET_NIL,                 /*   HB_ET_ALIASEXPR,   */
   HB_ET_NIL,                 /*   HB_ET_SEND,        */
   HB_ET_NIL,                 /*   HB_ET_FUNNAME,     */
   HB_ET_NIL,                 /*   HB_ET_ALIAS,       */
   HB_ET_NIL,                 /*   HB_ET_RTVARIABLE,  */
   HB_ET_NIL,                 /*   HB_ET_VARIABLE,    */
   HB_ET_NIL,                 /*   HB_EO_POSTINC,     post-operators */
   HB_ET_NIL,                 /*   HB_EO_POSTDEC,     */
   HB_ET_NONE,                /*   HB_EO_ASSIGN,      assigments */
   HB_ET_NONE,                /*   HB_EO_PLUSEQ,      Invalid syntax */
   HB_ET_NONE,                /*   HB_EO_MINUSEQ,     */
   HB_ET_NONE,                /*   HB_EO_MULTEQ,      */
   HB_ET_NONE,                /*   HB_EO_DIVEQ,       */
   HB_ET_NONE,                /*   HB_EO_MODEQ,       */
   HB_ET_NONE,                /*   HB_EO_EXPEQ,       */
   HB_EO_OR,                  /*   HB_EO_OR,          logical operators */
   HB_EO_AND,                 /*   HB_EO_AND,         */
   HB_ET_NIL,                 /*   HB_EO_NOT,         */
   HB_EO_EQUAL,               /*   HB_EO_EQUAL,       relational operators */
   HB_EO_EQUAL,               /*   HB_EO_EQ,          */
   HB_EO_EQUAL,               /*   HB_EO_LT,          */
   HB_EO_EQUAL,               /*   HB_EO_GT,          */
   HB_EO_EQUAL,               /*   HB_EO_LE,          */
   HB_EO_EQUAL,               /*   HB_EO_GE,          */
   HB_EO_EQUAL,               /*   HB_EO_NE,          */
   HB_EO_EQUAL,               /*   HB_EO_IN,          */
   HB_EO_PLUS,                /*   HB_EO_PLUS,        addition */
   HB_EO_PLUS,                /*   HB_EO_MINUS,       */
   HB_EO_MULT,                /*   HB_EO_MULT,        multiple */
   HB_EO_MULT,                /*   HB_EO_DIV,         */
   HB_EO_MULT,                /*   HB_EO_MOD,         */
   HB_EO_POWER,               /*   HB_EO_POWER,       */
   HB_ET_NIL,                 /*   HB_EO_NEGATE,      sign operator */
   HB_ET_NIL,                 /*   HB_EO_PREINC,      */
   HB_ET_NIL                  /*   HB_EO_PREDEC,      pre-operators */
};


static HB_CBVAR_PTR hb_compExprCBVarNew( char *, BYTE );

/* ************************************************************************ */

/* Delete all components and delete self
 */
#if defined( HB_MACRO_SUPPORT )
void hb_compExprDelete( HB_EXPR_PTR pExpr, HB_MACRO_DECL )
#else
void hb_compExprDelete( HB_EXPR_PTR pExpr )
#endif
{
   HB_TRACE(HB_TR_DEBUG, ("hb_compExprDelete()"));
   HB_EXPR_USE( pExpr, HB_EA_DELETE );
   HB_XFREE( pExpr );
}

/* Delete all components and delete self
 */
void hb_compExprFree( HB_EXPR_PTR pExpr, HB_MACRO_DECL )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_compExprFree()"));
   HB_EXPR_USE( pExpr, HB_EA_DELETE );
   HB_XFREE( pExpr );
   HB_SYMBOL_UNUSED( HB_MACRO_VARNAME );
}

void hb_compExprErrorType( HB_EXPR_PTR pExpr, HB_MACRO_DECL )
{
   HB_TRACE(HB_TR_DEBUG, ("hb_compExprErrorType()"));
   hb_compErrorType( pExpr );
   HB_SYMBOL_UNUSED( HB_MACRO_VARNAME );
}

/* Add a new local variable declaration
 */
#ifdef HB_MACRO_SUPPORT
HB_EXPR_PTR hb_compExprCBVarAdd( HB_EXPR_PTR pCB, char * szVarName, HB_MACRO_DECL )
#else
HB_EXPR_PTR hb_compExprCBVarAdd( HB_EXPR_PTR pCB, char * szVarName, BYTE bType )
#endif
{
   HB_CBVAR_PTR pVar;

   HB_TRACE(HB_TR_DEBUG, ("hb_compExprCBVarAdd(%s)", szVarName));

   if( pCB->value.asList.pIndex )
   {
      /* add it to the end of the list
      */
      pVar = ( HB_CBVAR_PTR ) pCB->value.asList.pIndex;
      while( pVar )
      {
         if( strcmp( szVarName, pVar->szName ) == 0 )
            hb_compErrorDuplVar( szVarName );

         if( pVar->pNext )
            pVar = pVar->pNext;
         else
         {
#ifdef HB_MACRO_SUPPORT
            pVar->pNext = hb_compExprCBVarNew( szVarName, ' ' );
#else
            pVar->pNext = hb_compExprCBVarNew( szVarName, bType );
#endif
            pVar = NULL;
         }
      }
   }
   else
#ifdef HB_MACRO_SUPPORT
      pCB->value.asList.pIndex = ( HB_EXPR_PTR ) hb_compExprCBVarNew( szVarName, ' ' );
#else
      pCB->value.asList.pIndex = ( HB_EXPR_PTR ) hb_compExprCBVarNew( szVarName, bType );
#endif

   return pCB;
}

/* Create a new IIF() expression or set arguments
 *
 * pIIF is a list of three expressions
 */
HB_EXPR_PTR hb_compExprNewIIF( HB_EXPR_PTR pExpr )
{
#ifndef HB_MACRO_SUPPORT
   HB_EXPR_PTR pTmp;

   pExpr->ExprType = HB_ET_IIF;

   pTmp = pExpr->value.asList.pExprList;  /* get first expression */
   if( pTmp->ExprType == HB_ET_NONE )
   {
      /* there is no conditional expression e.g. IIF( , true, false )
       */
      hb_compErrorSyntax( pExpr );
   }
#else
   pExpr->ExprType = HB_ET_IIF;
#endif

   return pExpr;
}

/* Create function call
 */
#ifdef HB_MACRO_SUPPORT
HB_EXPR_PTR hb_compExprNewFunCall( HB_EXPR_PTR pName, HB_EXPR_PTR pParms, HB_MACRO_DECL )
#else
HB_EXPR_PTR hb_compExprNewFunCall( HB_EXPR_PTR pName, HB_EXPR_PTR pParms )
#endif
{
   HB_EXPR_PTR pExpr = NULL;

   if( pName->ExprType == HB_ET_FUNNAME )
   {
      /* The name of a function is specified at compile time
       * e.g. MyFunc()
       *
       * NOTE:  'pName' can be a macro expression that will be resolved
       * at runtime - in this case pName is an expression of HB_ET_MACRO type
       * e.g. &MyVar()
       */
      int iCount;

      HB_TRACE(HB_TR_DEBUG, ("hb_compExprNewFunCall(%s)", pName->value.asSymbol));

      if( pParms )
      {
         iCount = hb_compExprListLen( pParms );
         /* Check the special case when no parameters are passed - in this case
         * pParms is an expression of type HB_ET_NONE and we shouldn't
         * replace it with NIL value
         */
         if( iCount == 1 && pParms->value.asList.pExprList->ExprType == HB_ET_NONE )
            --iCount;
      }
      else
         iCount = 0;

#ifndef HB_MACRO_SUPPORT
      hb_compFunCallCheck( pName->value.asSymbol, iCount );
#endif

      /* TODO: AT() (also done by Clipper, already mentioned)
               LEN() (also done by Clipper)
               ASC() (not done by Clipper)
               EMPTY() (not done by Clipper) */

      if( ( strcmp( "CHR", pName->value.asSymbol ) == 0 ) && iCount )
      {
         /* try to change it into a string */
         HB_EXPR_PTR pArg = pParms->value.asList.pExprList;

         if( pArg->ExprType == HB_ET_NUMERIC )
         {
            /* NOTE: CA-Cl*pper's compiler optimizer will be wrong for those
                     CHR() cases where the passed parameter is a constant which
                     can be divided by 256 but it's not zero, in this case it
                     will return an empty string instead of a Chr(0). [vszakats] */

            pExpr = hb_compExprNew( HB_ET_STRING );
            pExpr->ValType = HB_EV_STRING;
            if( pArg->value.asNum.NumType == HB_ET_LONG )
            {
               if( ( pArg->value.asNum.lVal % 256 ) == 0 && pArg->value.asNum.lVal != 0 )
               {
                  pExpr->value.asString = ( char * ) HB_XGRAB( 1 );
                  pExpr->value.asString[ 0 ] = '\0';
                  pExpr->ulLength = 0;
               }
               else
               {
                  pExpr->value.asString = ( char * ) HB_XGRAB( 2 );
                  pExpr->value.asString[ 0 ] = ( pArg->value.asNum.lVal % 256 );
                  pExpr->value.asString[ 1 ] = '\0';
                  pExpr->ulLength = 1;
               }
            }
            else
            {
               pExpr->value.asString = ( char * ) HB_XGRAB( 2 );
               pExpr->value.asString[ 0 ] = ( ( long ) pArg->value.asNum.dVal % 256 );
               pExpr->value.asString[ 1 ] = '\0';
               pExpr->ulLength = 1;
            }
            HB_EXPR_PCODE1( hb_compExprDelete, pParms );
            HB_EXPR_PCODE1( hb_compExprDelete, pName );
         }
      }
   }
   else if( pName->ExprType == HB_ET_MACRO )
   {
      /* Signal that macro compiler have to generate a pcode that will
       * return function name as symbol instead of usual value
       */
      pName->value.asMacro.SubType = HB_ET_MACRO_SYMBOL;

      HB_TRACE(HB_TR_DEBUG, ("hb_compExprNewFunCall(&)"));
   }

   if( pExpr == NULL )
   {
      pExpr = hb_compExprNew( HB_ET_FUNCALL );
      pExpr->value.asFunCall.pParms = pParms;
      pExpr->value.asFunCall.pFunName = pName;
   }

   return pExpr;
}

/* Creates new array access expression
 *    pArray[ pIndex ]
 * NOTE: In case of multiple indexes it is called recursively
 *    array[ idx1, idx2 ] => ( array[ idx1 ] )[ idx2 ]
 */
#ifdef HB_MACRO_SUPPORT
HB_EXPR_PTR hb_compExprNewArrayAt( HB_EXPR_PTR pArray, HB_EXPR_PTR pIndex, HB_MACRO_DECL )
#else
HB_EXPR_PTR hb_compExprNewArrayAt( HB_EXPR_PTR pArray, HB_EXPR_PTR pIndex )
#endif
{
   HB_EXPR_PTR pExpr;

   HB_TRACE(HB_TR_DEBUG, ("hb_compExprNewArrayAt()"));

   pExpr = hb_compExprNew( HB_ET_ARRAYAT );

   /* Check if this expression can be indexed */
   HB_EXPR_USE( pArray, HB_EA_ARRAY_AT );
   /* Check if this expression can be an index */
   HB_EXPR_USE( pIndex, HB_EA_ARRAY_INDEX );
   pExpr->value.asList.pExprList = pArray;
   pExpr->value.asList.pIndex = pIndex;

   return pExpr;
}


/* ************************************************************************* */

#ifndef HB_MACRO_SUPPORT
static void hb_compExprCheckStaticInitializers( HB_EXPR_PTR pLeftExpr, HB_EXPR_PTR pRightExpr )
{
   HB_EXPR_PTR pElem = pRightExpr->value.asList.pExprList;
   HB_EXPR_PTR pNext;
   HB_EXPR_PTR * pPrev;

   pPrev = &pRightExpr->value.asList.pExprList;
   while( pElem )
   {
      /* NOTE: During reduction the expression can be replaced by the
       *    new one - this will break the linked list of expressions.
       * (classical case of replacing an item in a linked list)
       */
      pNext = pElem->pNext; /* store next expression in case the current  will be reduced */
      pElem = hb_compExprListStrip( HB_EXPR_USE( pElem, HB_EA_REDUCE ), HB_MACRO_PARAM );
      if( pElem->ExprType > HB_ET_FUNREF )
         hb_compErrorStatic( pLeftExpr->value.asSymbol, pElem );
      *pPrev = pElem;   /* store a new expression into the previous one */
      pElem->pNext = pNext;  /* restore the link to next expression */
      pPrev  = &pElem->pNext;
      pElem  = pNext;
   }
}

/* It initializes static variable.
 *    It is called in the following context:
 * STATIC sVar := expression
 *
 * pLeftExpr - is a variable name
 * pRightExpr - can be an expression of any type
 */
HB_EXPR_PTR hb_compExprAssignStatic( HB_EXPR_PTR pLeftExpr, HB_EXPR_PTR pRightExpr )
{
   HB_EXPR_PTR pExpr;

   HB_TRACE(HB_TR_DEBUG, ("hb_compExprAssignStatic()"));

   pExpr = hb_compExprNew( HB_EO_ASSIGN );

   pExpr->value.asOperator.pLeft  = pLeftExpr;
   /* Try to reduce the assigned value */
   pRightExpr = hb_compExprListStrip( HB_EXPR_USE( pRightExpr, HB_EA_REDUCE ), HB_MACRO_PARAM );
   pExpr->value.asOperator.pRight = pRightExpr;

   if( pRightExpr->ExprType == HB_ET_ARGLIST )
   {
       /* HB_ET_ARGLIST is used in case of STATIC var[dim1, dim2, dimN]
        * was used - we have to check if all array dimensions are
        * constant values
        */
      hb_compExprCheckStaticInitializers( pLeftExpr, pRightExpr );
   }
   else if( pRightExpr->ExprType > HB_ET_FUNREF )
   {
      /* Illegal initializer for static variable (not a constant value)
       */
      hb_compErrorStatic( pLeftExpr->value.asSymbol, pRightExpr );
   }
   else if( pRightExpr->ExprType == HB_ET_ARRAY )
   {
      /* { elem1, elem2, elemN } was used as initializer
       * Scan an array for illegal initializers.
       * An array item have to be a const value too.
       */
      hb_compExprCheckStaticInitializers( pLeftExpr, pRightExpr );
   }

   return pExpr;
}
#endif


/* Sets the argument of an operation found previously
 */
#ifdef HB_MACRO_SUPPORT
HB_EXPR_PTR hb_compExprSetOperand( HB_EXPR_PTR pExpr, HB_EXPR_PTR pItem, HB_MACRO_DECL )
#else
HB_EXPR_PTR hb_compExprSetOperand( HB_EXPR_PTR pExpr, HB_EXPR_PTR pItem )
#endif
{
   BYTE ucRight;

   ucRight = s_PrecedTable[ pItem->ExprType ];
   if( ucRight == HB_ET_NIL )
   {
      /* the right side of an operator is an ordinary value
       * e.g. a := 1
       */
      pExpr->value.asOperator.pRight = pItem;
   }
   else if( ucRight == HB_ET_NONE )
   {
      /* the right side of an operator is an invalid expression
       * e.g.
       *    a := 1 + b:=2
       *    a := 1 + b += 2
       */
      hb_compErrorSyntax( pItem );
   }
   else
   {
      /* the right side of an operator is an expression with other operator
       * e.g. a := 2 + b * 3
       *   We have to set the proper order of evaluation using
       * precedence rules
       */
      BYTE ucLeft = s_PrecedTable[ pExpr->ExprType ];
      if( ucLeft >= ucRight )
      {
         /* Left operator has the same or lower precedence then the right one
          * e.g.  a * b + c
          *    pItem -> b + c   -> L=b  R=c  O=+
          *    pExpr -> a *     -> l=a  r=   o=*
          *
          *    -> (a * b) + c    -> Lelf=(a * b)  Right=c  Oper=+
          *             Left  := l (o) L
          *             Right := R
          *             Oper  := O
          */
#ifdef HB_MACRO_SUPPORT
         pItem->value.asOperator.pLeft = hb_compExprSetOperand( pExpr, pItem->value.asOperator.pLeft, HB_MACRO_PARAM );
#else
         pItem->value.asOperator.pLeft = hb_compExprSetOperand( pExpr, pItem->value.asOperator.pLeft );
#endif
         pExpr = pItem;
      }
      else
      {
         /* Left operator has a lower precedence then the right one
          * e.g.  a + b * c
          *    pItem -> b * c    -> L=b  R=c  O=*
          *    pExpr -> a +      -> l=a  r=   o=+
          *
          *    -> a + (b * c)    -> Left=a  Right=(b * c)  Oper=+
          *             Left  := l
          *             Right := L (O) R  := pItem
          *             Oper  := o
          */
         pExpr->value.asOperator.pRight = pItem;
      }
   }

   return pExpr;
}

/* ************************************************************************* */

/* Generates pcode for inline expression used as a statement
 * NOTE: It doesn't not leave any value on the eval stack
 */
#ifdef HB_MACRO_SUPPORT
HB_EXPR_PTR hb_compExprGenStatement( HB_EXPR_PTR pExpr, HB_MACRO_DECL )
#else
HB_EXPR_PTR hb_compExprGenStatement( HB_EXPR_PTR pExpr )
#endif
{
   HB_TRACE(HB_TR_DEBUG, ("hb_compExprGenStatement(%i)", pExpr->ExprType));

   pExpr = HB_EXPR_USE( pExpr, HB_EA_REDUCE );
   HB_EXPR_USE( pExpr, HB_EA_STATEMENT );
   return pExpr;
}

/* Generates pcode to push an expressions
 * NOTE: It pushes a value on the stack and leaves this value on the stack
 */
#ifdef HB_MACRO_SUPPORT
HB_EXPR_PTR hb_compExprGenPush( HB_EXPR_PTR pExpr, HB_MACRO_DECL )
#else
HB_EXPR_PTR hb_compExprGenPush( HB_EXPR_PTR pExpr )
#endif
{
   HB_TRACE(HB_TR_DEBUG, ("hb_compExprGenPush(%i)", pExpr->ExprType));

   pExpr = HB_EXPR_USE( pExpr, HB_EA_REDUCE );
   HB_EXPR_USE( pExpr, HB_EA_PUSH_PCODE );
   return pExpr;
}

/* Generates pcode to pop an expressions
 */
#ifdef HB_MACRO_SUPPORT
HB_EXPR_PTR hb_compExprGenPop( HB_EXPR_PTR pExpr, HB_MACRO_DECL )
#else
HB_EXPR_PTR hb_compExprGenPop( HB_EXPR_PTR pExpr )
#endif
{
   HB_TRACE(HB_TR_DEBUG, ("hb_compExprGenPop(%i)", pExpr->ExprType));

   return HB_EXPR_USE( pExpr, HB_EA_POP_PCODE );
}

/* ************************************************************************* */

/* Create a new declaration for codeblock local variable
 */
static HB_CBVAR_PTR hb_compExprCBVarNew( char * szVarName, BYTE bType )
{
   HB_CBVAR_PTR pVar;

   HB_TRACE(HB_TR_DEBUG, ("hb_compExprCBVarNew(%s)", szVarName));

   pVar = ( HB_CBVAR_PTR ) HB_XGRAB( sizeof( HB_CBVAR ) );

   pVar->szName = szVarName;
   pVar->bType  = bType;
   pVar->pNext  = NULL;

   return pVar;
}

/* NOTE: This deletes all linked variables
 */
void hb_compExprCBVarDel( HB_CBVAR_PTR pVars )
{
   HB_CBVAR_PTR pDel;

   while( pVars )
   {
      pDel  = pVars;
      pVars = pVars->pNext;
#ifdef HB_MACRO_SUPPORT
      HB_XFREE( pDel->szName );
#endif
      HB_XFREE( pDel );
   }
}


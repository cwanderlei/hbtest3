/*
 * $Id$
 */

/*
 * Harbour Project source code:
 *
 * Copyright 2009 Pritpal Bedi <pritpal@vouchcac.com>
 * www - http://www.harbour-project.org
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#ifndef HB_QTC_H_

#define HB_QTC_H_

#define HB_GT_NAME  QTC

#include <QtGui/QtGui>
#include <Qt/qglobal.h>
#include <QtGui/QtGui>
#include <QtCore/QObject>
#include <QtCore/QList>
#include <QtGui/QApplication>
#include <QtGui/QMainWindow>
#include <QtGui/QDesktopWidget>
#include <QtGui/QWidget>
#include <QtGui/QFont>
#include <QtGui/QPainter>
#include <QtGui/QPaintDevice>
#include <QtGui/QColor>
#include <QtGui/QKeyEvent>
#include <QtGui/QMouseEvent>
#include <QtGui/QClipboard>
#include <QtCore/QThread>

#include "hbset.h"
#include "hbgtcore.h"
#include "hbapicdp.h"
#include "hbapierr.h"
#include "hbapiitm.h"
#include "inkey.ch"
#include "hbvm.h"
#include "hbthread.h"

#define WVT_CHAR_QUEUE_SIZE       4096 //  128
#define WVT_MAX_TITLE_SIZE         128
#define WVT_MAX_ROWS               256
#define WVT_MAX_COLS               256
#define WVT_MAX_WINDOWS            256
#if defined( HB_OS_WIN_CE )
#  define WVT_DEFAULT_ROWS          15
#  define WVT_DEFAULT_COLS          50
#  define WVT_DEFAULT_FONT_HEIGHT   12
#  define WVT_DEFAULT_FONT_WIDTH     8
#else
#  define WVT_DEFAULT_ROWS          25
#  define WVT_DEFAULT_COLS          80
#  define WVT_DEFAULT_FONT_HEIGHT   20
#  define WVT_DEFAULT_FONT_WIDTH    10
#endif
#define WVT_DEFAULT_FONT_NAME    "Courier New"

//#define QQRGB( r,g,b )  ( ( QRgb ) ( ( r ) + ( g * 256 ) + ( b * 256 * 256 ) ) )
#define QQRGB( r,g,b )  ( qRgb( r,g,b ) )

#define C_BLACK          RGB( 0x0 ,0x0 ,0x0  )
#define C_BLUE           RGB( 0x0 ,0x0 ,0x85 )
#define C_GREEN          RGB( 0x0 ,0x85,0x0  )
#define C_CYAN           RGB( 0x0 ,0x85,0x85 )
#define C_RED            RGB( 0x85,0x0 ,0x0  )
#define C_MAGENTA        RGB( 0x85,0x0 ,0x85 )
#define C_BROWN          RGB( 0x85,0x85,0x0  )
#define C_WHITE          RGB( 0xC6,0xC6,0xC6 )
#define C_LIGHT_GRAY     RGB( 0x60,0x60,0x60 )
#define C_BRIGHT_BLUE    RGB( 0x00,0x00,0xFF )
#define C_BRIGHT_GREEN   RGB( 0x60,0xFF,0x60 )
#define C_BRIGHT_CYAN    RGB( 0x60,0xFF,0xFF )
#define C_BRIGHT_RED     RGB( 0xF8,0x00,0x26 )
#define C_BRIGHT_MAGENTA RGB( 0xFF,0x60,0xFF )
#define C_YELLOW         RGB( 0xFF,0xFF,0x00 )
#define C_BRIGHT_WHITE   RGB( 0xFF,0xFF,0xFF )

#define BLACK          QQRGB( 0x0 ,0x0 ,0x0  )
#define BLUE           QQRGB( 0x0 ,0x0 ,0x85 )
#define GREEN          QQRGB( 0x0 ,0x85,0x0  )
#define CYAN           QQRGB( 0x0 ,0x85,0x85 )
#define RED            QQRGB( 0x85,0x0 ,0x0  )
#define MAGENTA        QQRGB( 0x85,0x0 ,0x85 )
#define BROWN          QQRGB( 0x85,0x85,0x0  )
#define WHITE          QQRGB( 0xC6,0xC6,0xC6 )
#define LIGHT_GRAY     QQRGB( 0x60,0x60,0x60 )
#define BRIGHT_BLUE    QQRGB( 0x00,0x00,0xFF )
#define BRIGHT_GREEN   QQRGB( 0x60,0xFF,0x60 )
#define BRIGHT_CYAN    QQRGB( 0x60,0xFF,0xFF )
#define BRIGHT_RED     QQRGB( 0xF8,0x00,0x26 )
#define BRIGHT_MAGENTA QQRGB( 0xFF,0x60,0xFF )
#define YELLOW         QQRGB( 0xFF,0xFF,0x00 )
#define BRIGHT_WHITE   QQRGB( 0xFF,0xFF,0xFF )

/* xHarbour compatible definitions */
#if !defined( K_SH_LEFT )
#define K_SH_LEFT           K_LEFT            /* Shift-Left  == Left  */
#define K_SH_UP             K_UP              /* Shift-Up    == Up    */
#define K_SH_RIGHT          K_RIGHT           /* Shift-Right == Right */
#define K_SH_DOWN           K_DOWN            /* Shift-Down  == Down  */
#define K_SH_INS            K_INS             /* Shift-Ins   == Ins   */
#define K_SH_DEL            K_DEL             /* Shift-Del   == Del   */
#define K_SH_HOME           K_HOME            /* Shift-Home  == Home  */
#define K_SH_END            K_END             /* Shift-End   == End   */
#define K_SH_PGUP           K_PGUP            /* Shift-PgUp  == PgUp  */
#define K_SH_PGDN           K_PGDN            /* Shift-PgDn  == PgDn  */
#define K_SH_RETURN         K_RETURN          /* Shift-Enter == Enter */
#define K_SH_ENTER          K_ENTER           /* Shift-Enter == Enter */
#endif

#ifndef WM_MOUSEWHEEL
#  define WM_MOUSEWHEEL 0x020A
#endif
#ifndef WM_ENTERSIZEMOVE
#  define WM_ENTERSIZEMOVE 561
#endif
#ifndef WM_EXITSIZEMOVE
#  define WM_EXITSIZEMOVE  562
#endif

#ifndef SWP_DEFERERASE
#  define SWP_DEFERERASE 0x2000
#endif
#ifndef SW_NORMAL
#  define SW_NORMAL 1
#endif
#ifndef SC_MAXIMIZE
#  define SC_MAXIMIZE 0xF030
#endif

#define SYS_EV_MARK  1000

void hb_ToOutDebug( const char * sTraceMsg, ... );

/*----------------------------------------------------------------------*/

class MainWindow;

class DrawingArea : public QWidget
{
   Q_OBJECT

public:
   DrawingArea(QWidget *parent = 0);

   PHB_GT pGT;

   void   resetWindowSize(void);
   void   redrawBuffer(const QRect & rect );

   bool   createCaret(int iWidth, int iHeight);
   void   showCaret(void);
   void   hideCaret(void);
   void   setCaretPos(int iRow, int iCol);
   void   destroyCaret();

   void   displayCell(int iRow, int iCol);
   void   displayBlock(int iRow, int iCol);
   void   resizeImage(const QSize &newSize);
   void   drawBoxCharacter(QPainter *painter, USHORT usChar, BYTE bColor, int x, int y);

   QRgb   _COLORS[ 16 ];

   int    _fontHeight;
   int    _fontWidth;
   int    _fontAscent;

   int    _iROWS, _iCOLS;
   int    _wndWidth, _wndHeight;

   int    _crtHeight;
   int    _crtWidth;
   bool   _bBlinking;
   int    _crtLastRow;
   int    _crtLastCol;

   bool   _bFirst;
   bool   _bSizing;

   QBasicTimer *_basicTimer;

protected:
   void   keyPressEvent(QKeyEvent *event);
   void   keyReleaseEvent(QKeyEvent *event);
   void   mousePressEvent(QMouseEvent *event);
   void   mouseMoveEvent(QMouseEvent *event);
   void   mouseReleaseEvent(QMouseEvent *event);
   void   mouseDoubleClickEvent(QMouseEvent * event);
   void   paintEvent(QPaintEvent *event);
   void   resizeEvent(QResizeEvent *event);
   void   wheelEvent(QWheelEvent *event);
   void   timerEvent(QTimerEvent *event);
   void   focusInEvent(QFocusEvent *event);
   void   focusOutEvent(QFocusEvent *event);
   void   moveEvent(QMoveEvent *event);
   bool   event(QEvent *event);

private:
   QFont       _qFont;
   QImage      *_image;
};

/*----------------------------------------------------------------------*/

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow();

    DrawingArea *_drawingArea;
    PHB_GT      pGT;

    void setWindowSize( void );

protected:
    void closeEvent(QCloseEvent *event);

};

/*----------------------------------------------------------------------*/

typedef struct
{
   PHB_GT       pGT;                          /* core GT pointer */
   int          iHandle;                      /* window number */

   QApplication *qApplctn;
   MainWindow   *qWnd;
   QFont        *qFont;
   QFont        *qFontBox;
   QEventLoop   *qEventLoop;

   int          iCmdShow;

   USHORT       ROWS;                         /* number of displayable rows in window */
   USHORT       COLS;                         /* number of displayable columns in window */

   bool         CaretExist;                   /* TRUE if a caret has been created */
   bool         CaretHidden;                  /* TRUE if a caret has been hiden */
   int          CaretSize;                    /* Height of solid caret */
   int          CaretWidth;                   /* Width of solid caret */

   QPoint       MousePos;                     /* the last mouse position */
   bool         MouseMove;                    /* Flag to say whether to return mouse movement events */

   int          Keys[ WVT_CHAR_QUEUE_SIZE ];  /* Array to hold the characters & events */
   int          keyPointerIn;                 /* Offset into key array for character to be placed */
   int          keyPointerOut;                /* Offset into key array of next character to read */
   int          keyLast;                      /* last inkey code value in buffer */

   QPoint       PTEXTSIZE;                    /* size of the fixed width font */
   bool         FixedFont;                    /* TRUE if current font is a fixed font */
   int          FixedSize[ WVT_MAX_COLS ];    /* buffer for ExtTextOut() to emulate fixed pitch when Proportional font selected */
   int          fontHeight;                   /* requested font height */
   int          fontWidth;                    /* requested font width */
   int          fontWeight;                   /* Bold level */
   int          fontQuality;                  /* requested font quality */
   char         fontFace[ WVT_MAX_COLS ];     /* requested font face name LF_FACESIZE #defined in wingdi.h */

   bool         fInit;                        /* logical variable indicating that window should be open */

   PHB_CODEPAGE hostCDP;                      /* Host/HVM CodePage for unicode output translations */
   PHB_CODEPAGE inCDP;                        /* Host/HVM CodePage for unicode input translations */
   PHB_CODEPAGE boxCDP;                       /* CodePage for legacy drawing chars: IBM437 */

   QIcon        qIcon;                        /* Title Bar and Task List icon. Can be NULL. */
   bool         bIconToFree;                  /* Do we need to free this icon when it's not NULL? */

   int          CodePage;                     /* Code page to use for display characters */
   bool         AltF4Close;                   /* Can use Alt+F4 to close application */
   bool         CenterWindow;                 /* True if window is to be Reset into centre of window */

   bool         bMaximized;                   /* Flag is set when window has been maximized */
   bool         bBeingMarked;                 /* Flag to control DOS window like copy operation */
   bool         bBeginMarked;

   bool         bResizable;
   bool         bSelectCopy;
   char *       pszSelectCopy;
   bool         bClosable;

   int          ResizeMode;                   /* Sets the resizing mode either to FONT or ROWS */
   bool         bResizing;
   bool         bAlreadySizing;

#if defined( UNICODE )
   PHB_CODEPAGE boxCDP;                     /* CodePage for legacy drawing chars: IBM437 */
#endif

#if !defined( UNICODE )
   BYTE         keyTransTbl[ 256 ];
   BYTE         chrTransTbl[ 256 ];
#endif

} HB_GTWVT, * PHB_GTWVT;


/*
 * The code below is pulled from KDE distribution.
 * Experimental: do not know yet if it will be used in future or not.
 */
static const quint32 LineChars[] = {
   0x00007c00, 0x000fffe0, 0x00421084, 0x00e739ce, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
   0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00427000, 0x004e7380, 0x00e77800, 0x00ef7bc0,
   0x00421c00, 0x00439ce0, 0x00e73c00, 0x00e7bde0, 0x00007084, 0x000e7384, 0x000079ce, 0x000f7bce,
   0x00001c84, 0x00039ce4, 0x00003dce, 0x0007bdee, 0x00427084, 0x004e7384, 0x004279ce, 0x00e77884,
   0x00e779ce, 0x004f7bce, 0x00ef7bc4, 0x00ef7bce, 0x00421c84, 0x00439ce4, 0x00423dce, 0x00e73c84,
   0x00e73dce, 0x0047bdee, 0x00e7bde4, 0x00e7bdee, 0x00427c00, 0x0043fce0, 0x004e7f80, 0x004fffe0,
   0x004fffe0, 0x00e7fde0, 0x006f7fc0, 0x00efffe0, 0x00007c84, 0x0003fce4, 0x000e7f84, 0x000fffe4,
   0x00007dce, 0x0007fdee, 0x000f7fce, 0x000fffee, 0x00427c84, 0x0043fce4, 0x004e7f84, 0x004fffe4,
   0x00427dce, 0x00e77c84, 0x00e77dce, 0x0047fdee, 0x004e7fce, 0x00e7fde4, 0x00ef7f84, 0x004fffee,
   0x00efffe4, 0x00e7fdee, 0x00ef7fce, 0x00efffee, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
   0x000f83e0, 0x00a5294a, 0x004e1380, 0x00a57800, 0x00ad0bc0, 0x004390e0, 0x00a53c00, 0x00a5a1e0,
   0x000e1384, 0x0000794a, 0x000f0b4a, 0x000390e4, 0x00003d4a, 0x0007a16a, 0x004e1384, 0x00a5694a,
   0x00ad2b4a, 0x004390e4, 0x00a52d4a, 0x00a5a16a, 0x004f83e0, 0x00a57c00, 0x00ad83e0, 0x000f83e4,
   0x00007d4a, 0x000f836a, 0x004f93e4, 0x00a57d4a, 0x00ad836a, 0x00000000, 0x00000000, 0x00000000,
   0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00001c00, 0x00001084, 0x00007000, 0x00421000,
   0x00039ce0, 0x000039ce, 0x000e7380, 0x00e73800, 0x000e7f80, 0x00e73884, 0x0003fce0, 0x004239ce
};

/*----------------------------------------------------------------------*/


#endif /* HB_QTC_H_ */

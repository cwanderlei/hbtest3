/*
 * $Id$
 */

/*
 * Harbour Project source code:
 * IBM424 <-> Unicode conversion table
 *
 * Copyright 2009 Viktor Szakats (harbour.01 syenar.hu)
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

#include "hbapi.h"
#include "hbapicdp.h"

#define NUMBER_OF_CHARS    256

static HB_WCHAR uniCodes[ NUMBER_OF_CHARS ] =
{
   0x0020, 0x263A, 0x263B, 0x2665, 0x2666, 0x2663, 0x2660, 0x2022,
   0x25D8, 0x25CB, 0x25D9, 0x2642, 0x2640, 0x266A, 0x266B, 0x263C,
   0x25BA, 0x25C4, 0x2195, 0x203C, 0x00B6, 0x00A7, 0x25AC, 0x21A8,
   0x2191, 0x2193, 0x2192, 0x2190, 0x2319, 0x2194, 0x25B2, 0x25BC,
   0x0080, 0x0081, 0x0082, 0x0083, 0x0084, 0x000A, 0x0017, 0x001B,
   0x0088, 0x0089, 0x008A, 0x008B, 0x008C, 0x0005, 0x0006, 0x0007,
   0x0090, 0x0091, 0x0016, 0x0093, 0x0094, 0x0095, 0x0096, 0x0004,
   0x0098, 0x0099, 0x009A, 0x009B, 0x0014, 0x0015, 0x009E, 0x001A,
   0x0020, 0x05D0, 0x05D1, 0x05D2, 0x05D3, 0x05D4, 0x05D5, 0x05D6,
   0x05D7, 0x05D8, 0x00A2, 0x002E, 0x003C, 0x0028, 0x002B, 0x007C,
   0x0026, 0x05D9, 0x05DA, 0x05DB, 0x05DC, 0x05DD, 0x05DE, 0x05DF,
   0x05E0, 0x05E1, 0x0021, 0x0024, 0x002A, 0x0029, 0x003B, 0x00AC,
   0x002D, 0x002F, 0x05E2, 0x05E3, 0x05E4, 0x05E5, 0x05E6, 0x05E7,
   0x05E8, 0x05E9, 0x00A6, 0x002C, 0x0025, 0x005F, 0x003E, 0x003F,
   0x0000, 0x05EA, 0x0000, 0x0000, 0x00A0, 0x0000, 0x0000, 0x0000,
   0x2017, 0x0060, 0x003A, 0x0023, 0x0040, 0x0027, 0x003D, 0x0022,
   0x0000, 0x0061, 0x0062, 0x0063, 0x0064, 0x0065, 0x0066, 0x0067,
   0x0068, 0x0069, 0x00AB, 0x00BB, 0x0000, 0x0000, 0x0000, 0x00B1,
   0x00B0, 0x006A, 0x006B, 0x006C, 0x006D, 0x006E, 0x006F, 0x0070,
   0x0071, 0x0072, 0x0000, 0x0000, 0x0000, 0x00B8, 0x0000, 0x00A4,
   0x00B5, 0x007E, 0x0073, 0x0074, 0x0075, 0x0076, 0x0077, 0x0078,
   0x0079, 0x007A, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x00AE,
   0x005E, 0x00A3, 0x00A5, 0x00B7, 0x00A9, 0x00A7, 0x00B6, 0x00BC,
   0x00BD, 0x00BE, 0x005B, 0x005D, 0x00AF, 0x00A8, 0x00B4, 0x00D7,
   0x007B, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047,
   0x0048, 0x0049, 0x00AD, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
   0x007D, 0x004A, 0x004B, 0x004C, 0x004D, 0x004E, 0x004F, 0x0050,
   0x0051, 0x0052, 0x00B9, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
   0x005C, 0x00F7, 0x0053, 0x0054, 0x0055, 0x0056, 0x0057, 0x0058,
   0x0059, 0x005A, 0x00B2, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
   0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035, 0x0036, 0x0037,
   0x0038, 0x0039, 0x00B3, 0x0000, 0x0000, 0x0000, 0x0000, 0x009F
};

HB_UNITABLE hb_uniTbl_424 = { HB_CPID_424, NUMBER_OF_CHARS, FALSE, uniCodes };

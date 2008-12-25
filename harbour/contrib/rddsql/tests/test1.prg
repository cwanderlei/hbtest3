/*
 * $Id$
 */

#include "dbinfo.ch"
#include "error.ch"

#define DBI_QUERY             1001

#define RDDI_CONNECT          1001
#define RDDI_DISCONNECT       1002
#define RDDI_EXECUTE          1003
#define RDDI_ERROR            1004
#define RDDI_ERRORNO          1005
#define RDDI_NEWID            1006
#define RDDI_AFFECTEDROWS     1007
#define RDDI_QUERY            1008


REQUEST SDDMY, SQLMIX

FIELD RESIDENTS

PROC main()
LOCAL hConn
   RDDSETDEFAULT("SQLMIX")

   AEVAL(RDDLIST(), {|X| QOUT(X)})

   IF RDDINFO(RDDI_CONNECT, {"MYSQL", "localhost", "test",, "test"}) == 0
      ? "Unable connect to the server"
      RETURN 
   ENDIF

   CreateTable()

   ? "Let's browse table (press any key)"
   INKEY(0)
   DBUSEAREA( .T.,, "SELECT * FROM country", "country" )
   Browse()

   ? "Let's browse table ordered by resident count (press any key)"
   INKEY(0)
   INDEX ON RESIDENTS TAG residents TO country
   Browse()

   DBCLOSEALL()
RETURN

STATIC PROC CreateTable()
   ? RDDINFO(RDDI_EXECUTE, "DROP TABLE country")
   ? RDDINFO(RDDI_EXECUTE, "CREATE TABLE country (CODE char(3), NAME char(50), RESIDENTS int(11))")
   ? RDDINFO(RDDI_EXECUTE, "INSERT INTO country values ('LTU', 'Lithuania', 3369600), ('USA', 'United States of America', 305397000), ('POR', 'Portugal', 10617600), ('POL', 'Poland', 38115967), ('AUS', 'Australia', 21446187), ('FRA', 'France', 64473140), ('RUS', 'Russia', 141900000)")
RETURN

PROC RDDSYS();  RETURN

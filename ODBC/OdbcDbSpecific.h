//
//  OdbcDbSpecific.h
//  ODBC
//
//  Created by artyom on 12/7/25.
//  Copyright © 2025 Mikael Hakman. All rights reserved.
//

#ifndef DBSPECIFIC_H
#define DBSPECIFIC_H

// NOTE: adopted from https://github.com/mkleehammer/pyodbc/blob/master/src/dbspecific.h

// Items specific to databases.
//
// Obviously we'd like to minimize this, but if they are needed this file isolates them.  I'd like for there to be a
// single build of pyodbc on each platform and not have a bunch of defines for supporting different databases.


// ---------------------------------------------------------------------------------------------------------------------
// SQL Server


#define SQL_SS_VARIANT -150     // SQL Server 2008 SQL_VARIANT type
#define SQL_SS_XML -152         // SQL Server 2005 XML type
#define SQL_DB2_DECFLOAT -360   // IBM DB/2 DECFLOAT type
#define SQL_DB2_XML -370        // IBM DB/2 XML type
#define SQL_SS_TIME2 -154       // SQL Server 2008 time type

struct SQL_SS_TIME2_STRUCT
{
   SQLUSMALLINT hour;
   SQLUSMALLINT minute;
   SQLUSMALLINT second;
   SQLUINTEGER  fraction;
};

#endif // DBSPECIFIC_H

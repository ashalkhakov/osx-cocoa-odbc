//
//  OdbcTests.m
//  OdbcTests
//
//  Created by Mikael Hakman on 2013-09-30.
//  Copyright (c) 2013 Mikael Hakman. All rights reserved.
//

#import "ConnectionTests.h"

#import <Odbc/Odbc.h>
/*
#include <sqltypes.h>
#include <sql.h>
#include <sqlext.h>
*/
#define SQL_TXN_READ_UNCOMMITTED        0x00000001L
#define SQL_TRANSACTION_READ_UNCOMMITTED    SQL_TXN_READ_UNCOMMITTED
#define SQL_TXN_READ_COMMITTED            0x00000002L
#define SQL_TRANSACTION_READ_COMMITTED        SQL_TXN_READ_COMMITTED
#define SQL_TXN_REPEATABLE_READ            0x00000004L
#define SQL_TRANSACTION_REPEATABLE_READ        SQL_TXN_REPEATABLE_READ
#define SQL_TXN_SERIALIZABLE            0x00000008L
#define SQL_TRANSACTION_SERIALIZABLE        SQL_TXN_SERIALIZABLE

@implementation ConnectionTestsSQLite

- (NSString *) backend {
    return @"SQLite";
}

- (void) setUp {

    [self initialize];
    [super setUp];
}

- (void) tearDown {
    
    [super tearDown];
}

- (void) testConnectionWith {
    
    NSString *dsn = self->configuration[@"DataSourceName"];
    NSString *username = self->configuration[@"Username"];
    NSString *password = self->configuration[@"Password"];
    
    OdbcConnection * newConnection =
    
    [OdbcConnection connectionWithDataSource : dsn username : (username ? username : @"") password : (password ? password : @"")];

    XCTAssertNotNil (newConnection);
    
    XCTAssertTrue (newConnection.connected);
    
    [newConnection disconnect];
}

- (void) testNew {
    
    OdbcConnection * newConnection = [OdbcConnection new];
    
    XCTAssertNotNil (newConnection);
}

- (void) testConnect {
    
    NSString *dsn = self->configuration[@"DataSourceName"];
    NSString *username = self->configuration[@"Username"];
    NSString *password = self->configuration[@"Password"];
    
    OdbcConnection * newConnection =
    
    [OdbcConnection connectionWithDataSource : dsn username : (username ? username : @"") password : (password ? password : @"")];

    [newConnection disconnect];
}

- (void) testDisconnect {

    OdbcConnection * newConnection = [OdbcConnection new];

    NSString *dsn = self->configuration[@"DataSourceName"];
    NSString *username = self->configuration[@"Username"];
    NSString *password = self->configuration[@"Password"];
    
    [newConnection connect : dsn username : (username ? username : @"") password : (password ? password : @"")];

    [newConnection disconnect];
}

- (void) testCommit {
    
    NSString * prepSql;
    NSString * sql;
    
    NSString * dbms = self->connection.dbmsName;
    
    if ([[dbms lowercaseString] hasPrefix:@"oracle"]) {
        
        prepSql = @"delete from testtab where id = 10";
        
        sql =
        
        @"insert into testtab values (10,'Testing commit',10,date '2010-10-10',to_date ('10:10:10','HH24:MI:SS'),timestamp '2010-10-10 10:10:10')";
        
    } else if ([dbms hasPrefix : @"SQLite"]) {
        
        prepSql = @"delete from testtab where id = 10";
        
        sql =
        
        @"insert into testtab values (10,'Testing commit',10,'2010-10-10','10:10:10','2010-10-10 10:10:10')";

    } else if ([dbms hasPrefix: @"Microsoft SQL Server"]) {

        prepSql = @"delete from testtab where id = 10";

        sql =
        
        @"insert into testtab values (10,'Testing commit',10,'2010-10-10','10:10:10','2010-10-10 10:10:10')";

    } else {
        prepSql = @"delete from testtab where id = 10";

        sql =
        
        @"insert into testtab values (10,'Testing commit',10,date '2010-10-10',time '10:10:10',timestamp '2010-10-10 10:10:10')";
    }
    
    [self->connection setAutocommit:YES];

    [self->connection execDirect:prepSql];
    
    [self->connection setAutocommit:NO];

    OdbcStatement * stmt = [self->connection newStatement];
    
    [stmt execDirect : sql];

    [self->connection commit];
    
    [self disconnect];
    
    [self connect];
    
    sql = @"select * from testtab where id = 10";
    
    stmt = [self->connection newStatement];
    
    [stmt execDirect : sql];
    
    bool found = [stmt fetch];
    
    XCTAssertTrue (found);
    
    [stmt closeCursor];
    
    [self->connection commit];
    
    sql = @"delete from testtab where id = 10";
    
    [stmt execDirect : sql];
    
    [self->connection commit];
}

- (void) testRollback {
    
    NSString * prepSql;
    NSString * sql;
    
    NSString * dbms = self->connection.dbmsName;
    
    if ([[dbms lowercaseString] hasPrefix:@"oracle"]) {
        
        prepSql = @"delete from testtab where id = 10";

        sql =
        
        @"insert into testtab values (10,'Testing commit',10,date '2010-10-10',to_date ('10:10:10','HH24:MI:SS'),timestamp '2010-10-10 10:10:10')";
        
    } else if ([dbms hasPrefix : @"SQLite"]) {
        
        prepSql = @"delete from testtab where id = 10";

        sql =
        
        @"insert into testtab values (10,'Testing commit',10,'2010-10-10','10:10:10','2010-10-10 10:10:10')";

    } else if ([dbms hasPrefix: @"Microsoft SQL Server"]) {
        
        prepSql = @"delete from testtab where id = 10";

        sql =
        
        @"insert into testtab values (10,'Testing commit',10,'2010-10-10','10:10:10','2010-10-10 10:10:10')";

    } else {
        
        prepSql = @"delete from testtab where id = 10";

        sql =
        
        @"insert into testtab values (10,'Testing commit',10,date '2010-10-10',time '10:10:10',timestamp '2010-10-10 10:10:10')";
    }
    
    [self->connection setAutocommit:YES];

    [self->connection execDirect:prepSql];
    
    [self->connection setAutocommit:NO];

    OdbcStatement * stmt = [self->connection newStatement];
    
    [stmt execDirect : sql];
    
    [self->connection rollback];
    stmt = nil;
    
    [self disconnect];
    
    [self connect];
    
    [self->connection setAutocommit:YES];

    sql = @"select * from testtab where id = 10";
    
    stmt = [self->connection newStatement];
    
    [stmt execDirect : sql];
    
    bool found = [stmt fetch];

    XCTAssertFalse (found);
    
    [stmt closeCursor];
}

- (void) testNewStatement {
    
    OdbcStatement * stmt = [self->connection newStatement];
    
    XCTAssertNotNil (stmt);
}

- (void) testTablesCatalogSchemaTableTableTypes {
    
    NSString * dbms = self->connection.dbmsName;
    
    NSString * catalogName = self->connection.currentCatalog;
    
    NSString * schemaName = self->connection.currentSchema;
            
    if ([dbms hasPrefix:@"Microsoft SQL Server"]) {
        
        schemaName = @"dbo";

    }

    OdbcStatement * stmt = [self->connection tablesCatalog : catalogName
                                                    schema : schemaName
                                                     table : @"testtab"
                                                tableTypes : @"table"];
    
    bool found = [stmt fetch];
    
    XCTAssertTrue (found);
    
    NSString * catalog = nil;

    @try {
    
        catalog = [stmt getStringByName : @"TABLE_CAT"];
        
    } @catch (NSException * exception) {
        
        catalog = [stmt getStringByName : @"TABLE_QUALIFIER"];
    }
    
    if (!catalog) catalog = @"";
    
    XCTAssertEqualObjects (catalogName,catalog);
    
    NSString * schema = nil;
    
    @try {
        
        schema = [stmt getStringByName : @"TABLE_SCHEM"];
        
    } @catch (NSException * exception) {
        
        schema = [stmt getStringByName : @"TABLE_OWNER"];
    }
    
    if (! schema) schema = @"";
    
    if (schema.length > 0) {
        
        NSString * username = self->connection.username;
        
        if ([dbms hasPrefix:@"PostgreSQL"]) {
            
            XCTAssertEqualObjects ([schema uppercaseString], @"PUBLIC");
            
        } else if ([dbms hasPrefix:@"Microsoft SQL Server"]) {
            
            XCTAssertEqualObjects([schema uppercaseString], @"DBO");
            
        } else {
            
            XCTAssertEqualObjects ([schema uppercaseString],[username uppercaseString]);
            
        }
    }
        
    NSString * table = [stmt getStringByName : @"TABLE_NAME"];
    
    XCTAssertEqualObjects (@"testtab",[table lowercaseString]);
    
    NSString * tableType = [stmt getStringByName : @"TABLE_TYPE"];
    
    XCTAssertEqualObjects (@"TABLE",tableType);
    
    found = [stmt fetch];
    
    XCTAssertFalse (found);
    
    [stmt closeCursor];
    
    [self->connection commit];
}

- (void) testHdbc {
    
    if (! self->connection.hdbc) {
        
        XCTFail (@"HDBC is nil");
    }
}

- (void) testEnv {
    
    XCTAssertNotNil (self->connection.env);
}

- (void) testConnected {
    
    [self disconnect];
    
    XCTAssertFalse (self->connection.connected);
    
    [self connect];
    
    XCTAssertTrue (self->connection.connected);
}

- (void) testTransactionIsolation {

    NSString * dbms = self->connection.dbmsName;

    long curTxnIsolation = self->connection.transactionIsolation;
    
    if ([dbms hasPrefix:@"PostgreSQL"] || [dbms hasPrefix:@"MariaDB"] || [dbms hasPrefix:@"Microsoft SQL Server"]) {

        XCTAssertEqual (curTxnIsolation,SQL_TXN_REPEATABLE_READ);

    }
    else if ([dbms hasPrefix: @"SQLite"]) {
        
        XCTAssertEqual (curTxnIsolation,SQL_TXN_SERIALIZABLE);

    } else {
        XCTFail(@"Not implemented");
    }

    long newTxnIsolation;
        
    if ([dbms hasPrefix : @"SQLite"]) {
        
        ;
        
    } else if ([dbms hasPrefix : @"Oracle"]) {
        
        self->connection.transactionIsolation = SQL_TXN_REPEATABLE_READ;
        
        curTxnIsolation = self->connection.transactionIsolation;
        
        XCTAssertEqual (curTxnIsolation,SQL_TXN_REPEATABLE_READ);
    
    } else {
    
        self->connection.transactionIsolation = SQL_TXN_READ_COMMITTED;
        
        newTxnIsolation = self->connection.transactionIsolation;
        
        XCTAssertEqual(newTxnIsolation,SQL_TXN_READ_COMMITTED);

        self->connection.transactionIsolation = SQL_TXN_READ_UNCOMMITTED;
    
        newTxnIsolation = self->connection.transactionIsolation;
    
        XCTAssertEqual (newTxnIsolation,SQL_TXN_READ_UNCOMMITTED);
    
        self->connection.transactionIsolation = SQL_TXN_REPEATABLE_READ;
    
        curTxnIsolation = self->connection.transactionIsolation;
    
        XCTAssertEqual (curTxnIsolation,SQL_TXN_REPEATABLE_READ);
    }
}

- (void) testAutocommit {

    NSString * dbms = self->connection.dbmsName;
        
    if ([dbms hasPrefix : @"MariaDB"]) {
        NSLog(@"Need a better test case");
        return;
    }

    XCTAssertTrue (self->connection.autocommit);
    
    self->connection.autocommit = NO;
    
    XCTAssertFalse (self->connection.autocommit);
    
    self->connection.autocommit = YES;
    
    XCTAssertTrue (self->connection.autocommit);
}

- (void) testDataSource {
    NSString *dsn = self->configuration[@"DataSourceName"];
    XCTAssertEqualObjects (self->connection.dataSource,dsn);
}

- (void) testUsername {
    NSString *username = self->configuration[@"Username"];
    XCTAssertEqualObjects(self->connection.username,(username ? username : @""));
}

- (void) testCatalogs {
    
    NSArray * catalogs = self->connection.catalogs;
    
    XCTAssertTrue ([catalogs count] >= 0);

    if (catalogs.count > 0) {
    
        NSString * currentCatalog = self->connection.currentCatalog;
    
        long index = [catalogs indexOfObject : currentCatalog];
    
        XCTAssertTrue (index >= 0);
    
        NSString * catalog = [catalogs objectAtIndex : index];
    
        XCTAssertEqualObjects (catalog,currentCatalog);
    }
}

- (void) testSchemas {
    
    NSArray * schemas = self->connection.schemas;
    
    long count = [schemas count];
    
    XCTAssertTrue (count >= 0);
}

- (void) testTableTypes {
    
    NSArray * tableTypes = self->connection.tableTypes;
    
    long index = [tableTypes indexOfObject : @"TABLE"];
    
    XCTAssertTrue (index >= 0);
}

- (void) testCurrentCatalog {
    
    NSString * catalog = self->connection.currentCatalog;

    NSLog (@"%s current catalog %@",__PRETTY_FUNCTION__,catalog);
}

- (void) testCurrentUser {
    
    NSString * dbms = self->connection.dbmsName;
    
    NSString * user = self->connection.currentUser;
    
    if ([dbms hasPrefix : @"SQLite"]) {
        
        XCTAssertEqualObjects (user,@"");
        
    } else {
        NSString *username = self->configuration[@"Username"];
        if (!username) {
            username = @"";
        }
        
        XCTAssertEqualObjects ([user uppercaseString],[username uppercaseString]);
    }
}

- (void) testSchemaTerm {
    NSString * term = self->connection.schemaTerm;
    
    XCTAssertNotNil (term);
}

- (void) testCurrentSchema {
    
    NSString * schema = self->connection.currentSchema;
    
    if (schema.length > 0) {
        
        XCTAssertEqualObjects (schema,self->connection.currentUser);
    }
}

- (void) testExecDirect {
    
    OdbcStatement * stmt = [self->connection execDirect : @"delete from testtab"];
    
    stmt = [self->connection
                execDirect: @"insert into testtab(id,name) values (10,'Testing')"];

    stmt = [self->connection execDirect : @"select * from testtab"];
    
    bool found = [stmt fetch];
    
    XCTAssertTrue (found);
    
    [stmt closeCursor];
}

@end

@implementation ConnectionTestsPGSQL

- (NSString *) backend {
    return @"PGSQL";
}

@end

@implementation ConnectionTestsMySQL

- (NSString *) backend {
    return @"MySQL";
}

@end

@implementation ConnectionTestsMSSQL

- (NSString *) backend {
    return @"MSSQL";
}

@end

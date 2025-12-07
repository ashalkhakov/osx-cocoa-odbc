//
//  OdbcTests.m
//  OdbcTests
//
//  Created by artyom on 12/4/25.
//  Copyright © 2025 Mikael Hakman. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Odbc/Odbc.h>

NSString * DataSourceName;
NSString * Username;
NSString * Password;

@interface OdbcBase : XCTestCase {
    
@protected
    
    NSDictionary   * configuration;

    OdbcConnection * connection;

    OdbcStatement  * statement;
}

@end

@implementation OdbcBase

- (NSString *)backend {
    return nil;
}

- (void) initialize {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSString *configPath = [testBundle pathForResource:@"config" ofType:@"plist"];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];

    self->configuration = config[[self backend]];
}

- (void)setUp {

    [self connect];

    @try {
        
        [self->connection execDirect : @"delete from testtab"];
        
        [self->connection commit];
        
    } @catch (OdbcException * exception) {}
    
    @try {
        
        [self->connection execDirect : @"drop table testtab"];
        
        [self->connection commit];
        
    } @catch (NSException * exception) {}
    
    NSString * dbms = self->connection.dbmsName;
    NSString *createSql;
    
    if ([[dbms lowercaseString] hasPrefix:@"oracle"]) {
        createSql = nil;
    } else if ([dbms hasPrefix : @"SQLite"]) {
        
        createSql = @"CREATE TABLE \"testtab\" (\"id\" INTEGER, \"name\" TEXT, \"price\" NUMERIC, \"date\" TEXT, \"time\" TEXT, \"ts\" TEXT, PRIMARY KEY(\"id\" AUTOINCREMENT))";

    } else if ([dbms hasPrefix:@"MariaDB"]) {
        createSql = @"CREATE TABLE testtab (id INT AUTO_INCREMENT PRIMARY KEY, name TEXT, price DOUBLE, date DATE, time TIME, ts DATETIME)";
    } else if ([dbms hasPrefix:@"Microsoft SQL Server"]) {
        createSql = @"CREATE TABLE testtab (id INT PRIMARY KEY, name VARCHAR(100), price FLOAT, date DATE, time TIME(0), ts DATETIME)";
    } else {
        createSql = @"CREATE TABLE testtab (id SERIAL PRIMARY KEY, name TEXT, price DOUBLE PRECISION, date DATE, time TIME, ts TIMESTAMP)";
    }
    
    @try {

        [self->connection execDirect : createSql];

        [self->connection commit];

    } @catch (NSException * exception) {}
}

- (void)tearDown {
    [self disconnect];
}

- (void) connect {
    self->statement = nil;
    self->connection = [OdbcConnection new];
    
    XCTAssertNotNil(self->configuration, @"Please setup the config file and run the -initializeWith:(NSString*) method");

    NSString *dsn = self->configuration[@"DataSourceName"];
    NSString *username = self->configuration[@"Username"];
    NSString *password = self->configuration[@"Password"];
    
    [self->connection connect : dsn username : (username ? username : @"") password : (password ? password : @"")];
    [self->connection setAutocommit:YES];
}

- (void) disconnect {
    self->statement = nil;
    [self->connection disconnect];
    self->connection = nil;
}

@end

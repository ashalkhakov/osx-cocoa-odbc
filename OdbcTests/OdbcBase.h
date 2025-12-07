//
//  OdbcTests.h
//  OdbcTests
//
//  Created by Mikael Hakman on 2013-09-30.
//  Copyright (c) 2013 Mikael Hakman. All rights reserved.
//

#import <XCTest/XCTest.h>

@class OdbcConnection;
@class OdbcStatement;

@interface OdbcBase : XCTestCase {
    
@protected
    
    NSDictionary   * configuration;

    OdbcConnection * connection;

    OdbcStatement  * statement;
}

- (NSString *)backend;

- (void) initialize;

- (void) connect;

- (void) disconnect;

@end

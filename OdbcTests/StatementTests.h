//
//  StatementTests.h
//  Odbc
//
//  Created by Mikael Hakman on 2013-10-01.
//  Copyright (c) 2013 Mikael Hakman. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OdbcBase.h"

@interface StatementTestsSQLite : OdbcBase
- (void)insertIntoTestTab:(int)ident name:(NSString *)name price:(double)price date:(NSDate *)date time:(NSDate *)time ts:(NSDate *)ts;
- (NSString *) backend;
@end

@interface StatementTestsPGSQL : StatementTestsSQLite
- (NSString *) backend;
@end

@interface StatementTestsMySQL : StatementTestsSQLite
- (NSString *) backend;
@end

@interface StatementTestsMSSQL : StatementTestsSQLite
- (NSString *) backend;
@end

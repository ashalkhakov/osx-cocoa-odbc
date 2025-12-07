//
//  OdbcTests.h
//  OdbcTests
//
//  Created by Mikael Hakman on 2013-09-30.
//  Copyright (c) 2013 Mikael Hakman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "OdbcBase.h"

@interface ConnectionTestsSQLite : OdbcBase
- (NSString *) backend;
@end

@interface ConnectionTestsPGSQL : ConnectionTestsSQLite
- (NSString *) backend;
@end

@interface ConnectionTestsMySQL : ConnectionTestsSQLite
- (NSString *) backend;
@end

@interface ConnectionTestsMSSQL : ConnectionTestsSQLite
- (NSString *) backend;
@end

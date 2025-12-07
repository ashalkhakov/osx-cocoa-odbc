//
//  PrepareDescriptor.h
//  OdbcTest1
//
//  Created by Mikael Hakman on 2013-09-05.
//  Copyright (c) 2013 Mikael Hakman. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sqltypes.h>
#include <sql.h>

@class OdbcStatement;
@class OdbcParameterDescriptor;

@interface OdbcPrepareDescriptor : NSObject {
    
@protected
    
    __weak OdbcStatement  * statement;
    SQLSMALLINT      numParams;
    NSMutableArray * parameterDescriptors;
}

@property (weak,readonly) OdbcStatement * statement;
@property (readonly) SQLSMALLINT     numParams;
@property (readonly) NSArray       * parameterDescriptors;

+ (OdbcPrepareDescriptor *) descriptorWithStatement : (OdbcStatement *) stmt;

- (OdbcPrepareDescriptor *) initWithStatement : (OdbcStatement *) stmt;

- (OdbcParameterDescriptor *) parameterDescriptorAtIndex : (int) index;

@end

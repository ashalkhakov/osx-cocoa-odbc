//
//  OdbcStoreTests.h
//  Odbc
//
//  Created by Mikael Hakman on 2013-10-09.
//  Copyright (c) 2013 Mikael Hakman. All rights reserved.
//

#import "OdbcBase.h"

@interface OdbcStoreTestsSQLite : OdbcBase
- (void) initialize;
- (NSString *) backend;
@end

@interface OdbcStoreTestsPGSQL : OdbcStoreTestsSQLite
- (NSString *) backend;
@end

@interface OdbcStoreTestsMySQL : OdbcStoreTestsSQLite
- (NSString *) backend;
@end

@interface OdbcStoreTestsMSSQL : OdbcStoreTestsSQLite
- (NSString *) backend;
@end

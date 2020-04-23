//
//  WCTTable+Redisable.h
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "VVRedisable.h"
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCTTable (Redisable) <VVRedisable>
@property (nonatomic, copy) NSString *vt_key;
@property (nonatomic, weak) WCTDatabase *vt_wcdb;
@end

NS_ASSUME_NONNULL_END

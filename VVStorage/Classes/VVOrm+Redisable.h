//
//  VVOrm+Redisable.h
//  VVStorage
//
//  Created by Valo on 2019/12/25.
//

#import <Foundation/Foundation.h>
#import <VVSequelize/VVSequelize.h>
#import "VVRedisable.h"

NS_ASSUME_NONNULL_BEGIN

@interface VVOrm (Redisable) <VVRedisable>

- (VTKey)vt_keyForObject:(id)object;

@end

NS_ASSUME_NONNULL_END

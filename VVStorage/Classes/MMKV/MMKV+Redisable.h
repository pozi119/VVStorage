//
//  MMKV+Redisable.h
//  VVStorage
//
//  Created by Valo on 2020/11/18.
//

#import <MMKV/MMKV.h>
#import "VVRedisable.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMKV (Redisable) <VVRedisable>

@end

NS_ASSUME_NONNULL_END

//
//  VVRedisStorable.h
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import <Foundation/Foundation.h>
#import "VVRedisable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VVRedisStorable <VVRedisable>
@property (nonatomic, strong, readonly, nonnull) NSObject<VVRedisable> *cache;
@property (nonatomic, strong, readonly, nonnull) NSObject<VVRedisable> *storage;

- (instancetype)initWithCache:(nonnull NSObject<VVRedisable> *)cache
        storage:(nonnull NSObject<VVRedisable> *)storage;
@end

@interface VVRedisStorage : NSObject <VVRedisStorable>
@property (nonatomic, strong, readonly, nonnull) NSObject<VVRedisable> *cache;
@property (nonatomic, strong, readonly, nonnull) NSObject<VVRedisable> *storage;
@end

NS_ASSUME_NONNULL_END

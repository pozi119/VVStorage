//
//  VVRedisableCache.m
//  VVStorage
//
//  Created by Valo on 2020/4/23.
//

#import "VVRedisableCache.h"
@interface VVRedisableCache ()
@property (nonatomic, strong) NSMutableSet *vt_allKeysSet;
@end

@implementation VVRedisableCache
- (instancetype)init
{
    self = [super init];
    if (self) {
        _vt_allKeysSet = [NSMutableSet set];
    }
    return self;
}

- (nonnull NSArray<VTKey> *)vt_allKeys {
    return self.vt_allKeysSet.allObjects;
}

- (nullable VTValue)vt_objectForKey:(nonnull VTKey)aKey {
    VTValue value = [self objectForKey:aKey];
    if (!value) {
        [self.vt_allKeysSet removeObject:aKey];
    }
    return value;
}

- (void)vt_setObject:(nullable VTValue)anObject forKey:(nonnull VTKey)aKey {
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    } else {
        [self removeObjectForKey:aKey];
    }
}

- (void)setObject:(id)obj forKey:(id)key {
    [super setObject:obj forKey:key];
    if (obj) {
        [self.vt_allKeysSet addObject:key];
    } else {
        [self.vt_allKeysSet removeObject:key];
    }
}

- (void)removeObjectForKey:(id)key {
    [super removeObjectForKey:key];
    [self.vt_allKeysSet removeObject:key];
}

@end

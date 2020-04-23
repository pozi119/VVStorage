//
//  NSMutableDictionary+Dictionariable.m
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "NSMutableDictionary+Dictionariable.h"

@implementation NSMutableDictionary (Dictionariable)
- (nonnull NSArray<VTKey> *)vt_allKeys {
    return self.allKeys;
}

- (nullable VTValue)vt_objectForKey:(nonnull VTKey)aKey {
    return [self objectForKey:aKey];
}

- (void)vt_setObject:(nullable VTValue)anObject forKey:(nonnull VTKey)aKey {
    [self setObject:anObject forKey:aKey];
}

@end

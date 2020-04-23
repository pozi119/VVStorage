//
//  MMKV+Dictionariable.m
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "MMKV+Dictionariable.h"
#import <objc/runtime.h>

static const char *__vt_valueClass = "__vt_valueClass";
static const char *__vt_stringToKey = "__vt_stringToKey";
static const char *__vt_keyToString = "__vt_keyToString";

@implementation MMKV (Dictionariable)

- (StringToVTKey)stringToKey {
    return (StringToVTKey)objc_getAssociatedObject(self, __vt_stringToKey);
}

- (void)setStringToKey:(StringToVTKey)stringToKey {
    objc_setAssociatedObject(self, __vt_stringToKey, stringToKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (VTKeyToString)keyToString {
    return (VTKeyToString)objc_getAssociatedObject(self, __vt_keyToString);
}

- (void)setKeyToString:(VTKeyToString)keyToString {
    objc_setAssociatedObject(self, __vt_keyToString, keyToString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (Class)valueClass {
    return (Class)objc_getAssociatedObject(self, __vt_valueClass);
}

- (void)setValueClass:(Class)storageClass {
    objc_setAssociatedObject(self, __vt_valueClass, storageClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nonnull NSArray<VTKey> *)vt_allKeys {
    NSArray *keys = self.allKeys;
    if (!self.stringToKey) return keys;
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:keys.count];
    for (NSString *key in keys) {
        [results addObject:self.stringToKey(key)];
    }
    return results;
}

- (nullable VTValue)vt_objectForKey:(VTKey)aKey {
    NSAssert(self.valueClass != nil, @"valueClass must be set first");
    NSString *key = self.keyToString ? self.keyToString(aKey) : (NSString *)aKey;
    return [self getObjectOfClass:self.valueClass forKey:key];
}

- (void)vt_setObject:(nullable VTValue)anObject forKey:(VTKey)aKey {
    NSAssert(self.valueClass != nil, @"valueClass must be set first");
    NSString *key = self.keyToString ? self.keyToString(aKey) : (NSString *)aKey;
    if (anObject) {
        NSAssert([anObject conformsToProtocol:@protocol(NSCoding)], @"object must conforms to NSCoding");
        [self setObject:(NSObject<NSCoding> *)anObject forKey:key];
    } else {
        [self removeValueForKey:key];
    }
}

@end

//
//  VVDictionariable.m
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "VVDictionariable.h"
#import <objc/runtime.h>

static const char *__vt_keyComparator = "__vt_keyComparator";

@implementation NSObject (Dictionariable)

- (NSComparator)vtkeyComparator {
    NSComparator comparator = (NSComparator)objc_getAssociatedObject(self, __vt_keyComparator);
    if (!comparator) {
        comparator = ^(VTKey key1, VTKey key2) {
            return key1 < key2 ? NSOrderedAscending : NSOrderedDescending;
        };
        [self setVtkeyComparator:comparator];
    }
    return comparator;
}

- (void)setVtkeyComparator:(NSComparator)vtkeyComparator {
    objc_setAssociatedObject(self, __vt_keyComparator, vtkeyComparator, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

// MARK: set
- (NSInteger)set:(VTValue)anObject forKey:(VTKey)aKey
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    VTValue oldValue = [dictionariable vt_objectForKey:aKey];
    if ([anObject isEqual:oldValue]) return 0;
    [dictionariable vt_setObject:anObject forKey:aKey];
    return 1;
}

- (NSDictionary<VTKey, VTValue> *)multiSet:(NSDictionary<VTKey, VTValue> *)keyValues
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (VTKey key in keyValues.allKeys) {
        VTValue oldValue = [dictionariable vt_objectForKey:key];
        VTValue value = keyValues[key];
        if ([value isEqual:oldValue]) continue;
        [dictionariable vt_setObject:value forKey:key];
        results[key] = value;
    }
    return results;
}

// MARK: get
- (nullable VTValue)get:(VTKey)aKey
{
    NSAssert([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class");
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    return [dictionariable vt_objectForKey:aKey];
}

- (NSDictionary<VTKey, VTValue> *)multiGet:(NSArray<VTKey> *)keys
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (VTKey key in keys) {
        results[key] = [dictionariable vt_objectForKey:key];
    }
    return results;
}

- (BOOL)exists:(VTKey)aKey
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    return [dictionariable.vt_allKeys containsObject:aKey];
}

// MARK: del
- (nullable VTValue)del:(VTKey)aKey
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    VTValue value = [dictionariable vt_objectForKey:aKey];
    [dictionariable vt_setObject:nil forKey:aKey];
    return value;
}

- (NSDictionary<VTKey, VTValue> *)multiDel:(NSArray<VTKey> *)keys
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (VTKey key in keys) {
        results[key] = [dictionariable vt_objectForKey:key];
        [dictionariable vt_setObject:nil forKey:key];
    }
    return results;
}

// MARK: query
- (NSArray<VTKey> *)keys:(nullable VTKey)lower
                   upper:(nullable VTKey)upper
                  bounds:(VTBounds)bounds
                   limit:(NSUInteger)limit
                   order:(BOOL)desc
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    NSMutableSet *set = [NSMutableSet setWithArray:dictionariable.vt_allKeys];
    BOOL addLower = NO, addUpper = NO;
    if (lower) {
        if (![set containsObject:lower]) {
            [set addObject:lower];
            addLower = YES;
        }
    }
    if (upper) {
        if (![set containsObject:upper]) {
            [set addObject:upper];
            addUpper = YES;
        }
    }
    NSArray *keys = [set.allObjects sortedArrayUsingComparator:self.vtkeyComparator];
    NSUInteger loc = 0;
    if (lower) {
        NSUInteger idx = [keys indexOfObject:lower];
        loc = ((bounds & VTBoundLower) && !addLower) ? idx : idx + 1;
    }
    NSUInteger end = keys.count;
    if (upper) {
        NSUInteger idx = [keys indexOfObject:upper];
        end = ((bounds & VTBoundUpper) && !addUpper) ? idx + 1 : idx;
    }
    if (loc >= end) return @[];
    NSRange range = NSMakeRange(loc, end - loc);
    NSArray *array = [keys subarrayWithRange:range];
    if (desc) {
        array = array.reverseObjectEnumerator.allObjects;
    }

    return (limit == 0 || array.count <= limit) ? array : [array subarrayWithRange:NSMakeRange(0, limit)];
}

- (NSArray<VTElement *> *)scan:(nullable VTKey)lower
                         upper:(nullable VTKey)upper
                        bounds:(VTBounds)bounds
                         limit:(NSUInteger)limit
                         order:(BOOL)desc
{
    NSAssert1([self conformsToProtocol:@protocol(VVDictionariable)], @"Invalid class: %@", self.class);
    NSObject<VVDictionariable> *dictionariable = (NSObject<VVDictionariable> *)self;

    NSArray *keys = [self keys:lower upper:upper bounds:bounds limit:limit order:desc];
    NSMutableArray *results = [NSMutableArray array];
    for (VTKey key in keys) {
        VTElement *element = [VTElement new];
        element.key = key;
        element.value = [dictionariable vt_objectForKey:key];
        [results addObject:element];
    }
    return results;
}

- (NSArray<VTElement *> *)round:(nullable VTKey)center
                          lower:(NSInteger)lower
                          upper:(NSInteger)upper
                          order:(BOOL)desc
{
    NSArray<VTElement *> *after = [self scan:center upper:nil bounds:0 limit:upper order:NO];
    NSArray<VTElement *> *front = @[];
    if (center) {
        front = [self scan:nil upper:center bounds:VTBoundUpper limit:lower + 1 order:YES].reverseObjectEnumerator.allObjects;
    }
    NSArray<VTElement *> *results = [front arrayByAddingObjectsFromArray:after];
    return desc ? results.reverseObjectEnumerator.allObjects : results;
}

@end

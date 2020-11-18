//
//  MMKV+Redisable.m
//  VVStorage
//
//  Created by Valo on 2020/11/18.
//

#import "MMKV+Redisable.h"

@implementation MMKV (Redisable)

- (Class)metaClass{
    Class cls = self.associate.metaClass;
    NSAssert(cls != nil, @"Please set `self.associate.metaClass` first!");
    return cls;
}

+ (NSString *)keyOfVTKey:(VTKey)key
{
    return key ? [NSString stringWithFormat:@"%@",key] : @"";
}

+ (NSObject<NSCoding> *)valueOfVTValue:(VTValue)value
{
    NSAssert([value conformsToProtocol:@protocol(NSCoding)], @"value must conforms to `NSCoding`!");
    return (NSObject<NSCoding> *)value;
}

// MARK: set
- (NSInteger)set:(VTValue)anObject forKey:(VTKey)aKey
{
    NSString *key = [MMKV keyOfVTKey:aKey];
    NSObject<NSCoding> *value = [MMKV valueOfVTValue:anObject];
    NSObject<NSCoding> *oldValue = [self getObjectOfClass:self.metaClass forKey:key];
    if ([value isEqual:oldValue]) return 0;
    [self setObject:value forKey:key];
    return 1;
}

- (NSDictionary<VTKey, VTValue> *)multiSet:(NSDictionary<VTKey, VTValue> *)keyValues
{
    __block NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [keyValues enumerateKeysAndObjectsUsingBlock:^(VTKey aKey, VTValue anObject, BOOL *stop) {
        NSString *key = [MMKV keyOfVTKey:aKey];
        NSObject<NSCoding> * value =[MMKV valueOfVTValue:anObject];
        NSObject<NSCoding> * oldValue = [self getObjectOfClass:self.metaClass forKey:key];
        if (![value isEqual:oldValue]) {
            [self setObject:value forKey:key];
            results[aKey] = value;
        }
    }];
    return results;
}

// MARK: get
- (nullable VTValue)get:(VTKey)aKey
{
    NSString *key = [MMKV keyOfVTKey:aKey];
    return [self getObjectOfClass:self.metaClass forKey:key];
}

- (NSDictionary<VTKey, VTValue> *)multiGet:(NSArray<VTKey> *)keys
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (VTKey aKey in keys) {
        NSString *key = [MMKV keyOfVTKey:aKey];
        results[aKey] = [self getObjectOfClass:self.metaClass forKey:key];
    }
    return results;
}

- (BOOL)exists:(VTKey)aKey
{
    NSString *key = [MMKV keyOfVTKey:aKey];
    return [self containsKey:key];
}

// MARK: del
- (nullable VTValue)del:(VTKey)aKey
{
    NSString *key = [MMKV keyOfVTKey:aKey];
    NSObject<NSCoding> * value = [self getObjectOfClass:self.metaClass forKey:key];
    [self removeValueForKey:key];
    return value;
}

- (NSDictionary<VTKey, VTValue> *)multiDel:(NSArray<VTKey> *)keys
{
    NSDictionary *results = [self multiGet:keys];
    NSMutableArray *xKeys = [NSMutableArray arrayWithCapacity:keys.count];
    for (VTKey aKey in keys) {
        NSString *key = [MMKV keyOfVTKey:aKey];
        [xKeys addObject:key];
    }
    [self removeValuesForKeys:xKeys];
    return results;
}

// MARK: query
- (NSArray<VTKey> *)keys:(nullable VTKey)lower
                   upper:(nullable VTKey)upper
                  bounds:(VTBounds)bounds
                   limit:(NSUInteger)limit
                   order:(BOOL)desc;
{
    NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:2];
    if (lower) {
        [conditions addObject:[NSString stringWithFormat:@"SELF %@ %@",((bounds & VTBoundLower) ? @">=" : @">"), lower]];
    }
    if (upper){
        [conditions addObject:[NSString stringWithFormat:@"SELF %@ %@",((bounds & VTBoundUpper) ? @"<=" : @"<"), upper]];
    }
    NSString *format = [conditions componentsJoinedByString:@" AND "];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    NSArray *filtered = [self.allKeys filteredArrayUsingPredicate:predicate];
    NSArray *sorted = [filtered sortedArrayUsingComparator:self.associate.comparator];
    NSArray *array = desc ? sorted.reverseObjectEnumerator.allObjects : sorted;
    return (limit == 0 || array.count <= limit) ? array : [array subarrayWithRange:NSMakeRange(0, limit)];
}

- (NSArray<VTElement *> *)scan:(nullable VTKey)lower
                         upper:(nullable VTKey)upper
                        bounds:(VTBounds)bounds
                         limit:(NSUInteger)limit
                         order:(BOOL)desc;
{
    NSArray *keys = [self keys:lower upper:upper bounds:bounds limit:limit order:desc];
    NSMutableArray *results = [NSMutableArray array];
    for (NSString * key in keys) {
        VTElement *element = [VTElement new];
        element.key = key;
        element.value = [self getObjectOfClass:self.metaClass forKey:key];
        [results addObject:element];
    }
    return results;
}

- (NSArray<VTElement *> *)round:(nullable VTKey)center
                          lower:(NSInteger)lower
                          upper:(NSInteger)upper
                          order:(BOOL)desc;
{
    NSArray<VTElement *> *after = [self scan:center upper:nil bounds:0 limit:upper order:NO];
    NSArray<VTElement *> *front = @[];
    if (center) {
        front = [self scan:nil upper:center bounds:VTBoundUpper limit:lower + 1 order:YES].reverseObjectEnumerator.allObjects;
    }
    NSArray<VTElement *> *results = [front arrayByAddingObjectsFromArray:after];
    return desc ? results.reverseObjectEnumerator.allObjects : results;
}

// MARK: transaction

- (BOOL)begin
{
    if (self.associate.inTransaction) return YES;
    self.associate.inTransaction = YES;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:self.count];
    NSArray *allKeys = self.allKeys;
    for (NSString *key in allKeys) {
        dic[key] = [self getObjectOfClass:self.metaClass forKey:key];
    }
    self.associate.snapshot = [NSDictionary dictionaryWithDictionary:dic];
    return YES;
}

- (BOOL)commit
{
    if (!self.associate.inTransaction) return YES;
    self.associate.snapshot = nil;
    return YES;
}

- (BOOL)rollback
{
    if (!self.associate.inTransaction) return YES;
    [self clearAll];
    [self.associate.snapshot enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject<NSCoding> * obj, BOOL *stop) {
        [self setObject:obj forKey:key];
    }];
    [self trim];
    self.associate.snapshot = nil;
    return YES;
}

@end

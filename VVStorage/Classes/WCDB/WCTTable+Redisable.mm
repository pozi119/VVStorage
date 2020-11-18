//
//  WCTTable+Redisable.m
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "WCTTable+Redisable.h"
#import <objc/runtime.h>

@implementation WCTTable (Redisable)

// MARK: - runtime properties
- (NSString *)vt_key {
    NSString *key = self.associate.uniqueKey;
    NSAssert(key.length > 0, @"Please set `self.associate.uniqueKey` first!");
    return key;
}

- (WCTDatabase *)vt_wcdb {
    WCTDatabase *wcdb = (WCTDatabase *)self.associate.reserved;
    NSAssert(wcdb != nil && [wcdb isKindOfClass:WCTDatabase.class], @"Please set `self.associate.reserved` with WCTDatabase");
    return wcdb;
}

// MARK: - Redisable

// MARK: set

- (NSInteger)set:(VTValue)anObject forKey:(VTKey)aKey {
    NSAssert1([anObject conformsToProtocol:@protocol(WCTTableCoding)], @"Invalid object: %@", anObject.class);
    VTKey key = [anObject valueForKey:self.vt_key];
    if (![key isEqual:aKey]) {
        return -1;
    }
    WCTCondition condition = WCTProperty(self.vt_key) == aKey;
    VTValue object = [self getObjectsWhere:condition].firstObject;
    if ([object isEqual:anObject]) {
        return 0;
    }
    NSObject<WCTTableCoding> *_anObject = (NSObject<WCTTableCoding> *)anObject;
    BOOL ret = [self insertOrReplaceObject:_anObject];
    return ret ? 1 : -1;
}

- (NSDictionary<VTKey, VTValue> *)multiSet:(NSDictionary<VTKey, VTValue> *)keyValues {
    if (keyValues.count == 0) {
        return @{};
    }
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [self.vt_wcdb beginTransaction];
    for (VTKey key in keyValues.allKeys) {
        VTValue object = keyValues[key];
        NSInteger ret = [self set:object forKey:key];
        if (ret >= 0) {
            results[key] = object;
        }
    }
    if (results.count > 0) {
        [self.vt_wcdb commitTransaction];
    } else {
        [self.vt_wcdb rollbackTransaction];
    }
    return results;
}

// MARK: get

- (nullable VTValue)get:(VTKey)aKey {
    WCTCondition condition = WCTProperty(self.vt_key) == aKey;
    VTValue object = [self getObjectsWhere:condition].firstObject;
    return object;
}

- (NSDictionary<VTKey, VTValue> *)multiGet:(NSArray<VTKey> *)keys {
    if (keys.count == 0) {
        return @{};
    }
    WCTCondition condition = WCTProperty(self.vt_key).in (keys);
    NSArray *objects = [self getObjectsWhere:condition];
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (VTValue object in objects) {
        VTKey key = [object valueForKey:self.vt_key];
        results[key] = object;
    }
    return results;
}

- (BOOL)exists:(VTKey)aKey {
    WCTCondition condition = WCTProperty(self.vt_key) == aKey;
    NSNumber *count = [self getOneValueOnResult:WCTProperty("*").count() where:condition];
    return count.longLongValue > 0;
}

// MARK: delete

- (nullable VTValue)del:(VTKey)aKey {
    WCTCondition condition = WCTProperty(self.vt_key) == aKey;
    VTValue object = [self getObjectsWhere:condition].firstObject;
    BOOL ret = [self deleteObjectsWhere:condition];
    return ret ? object : nil;
}

- (NSDictionary<VTKey, VTValue> *)multiDel:(NSArray<VTKey> *)keys {
    if (keys.count == 0) {
        return @{};
    }
    WCTCondition condition = WCTProperty(self.vt_key).in (keys);
    NSArray *objects = [self getObjectsWhere:condition];
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (VTValue object in objects) {
        VTKey key = [object valueForKey:self.vt_key];
        results[key] = object;
    }
    BOOL ret = [self deleteObjectsWhere:condition];
    return ret ? results : @{};
}

// MARK: query
- (NSArray<VTKey> *)keys:(nullable VTKey)lower upper:(nullable VTKey)upper bounds:(VTBounds)bounds limit:(NSUInteger)limit order:(BOOL)desc {
    if (limit == 0) return @[];

    WCTExpr expr = WCTProperty(self.vt_key);
    WCTCondition lowerWhere = nil;
    WCTCondition upperWhere = nil;
    if (lower) {
        lowerWhere = (bounds & VTBoundLower) ? (expr >= lower) : (expr > lower);
    }
    if (upper) {
        upperWhere = (bounds & VTBoundUpper) ? (expr <= upper) : (expr < upper);
    }
    WCTCondition condition = (lower && upper) ? (lowerWhere && upperWhere) : (lower ? lowerWhere : (upper ? upperWhere : nil));
    WCTOrderBy orderby = expr.order(desc ? WCTOrderedDescending : WCTOrderedAscending);
    NSArray *rows = [self getRowsOnResults:{ expr } where:condition orderBy:orderby limit:limit];
    NSMutableArray *results = [NSMutableArray array];
    for (NSArray *keys in rows) {
        VTKey key = keys.firstObject ? : @"";
        [results addObject:key];
    }
    return results;
}

- (NSArray<VTElement *> *)scan:(nullable VTKey)lower upper:(nullable VTKey)upper bounds:(VTBounds)bounds limit:(NSUInteger)limit order:(BOOL)desc {
    NSArray<VTKey> *keys = [self keys:lower upper:upper bounds:bounds limit:limit order:desc];
    NSDictionary *keyValues = [self multiGet:keys];

    NSMutableArray<VTElement *> *results = [NSMutableArray array];
    for (VTKey key in keys) {
        VTElement *element = [VTElement new];
        element.key = key;
        element.value = keyValues[key];
        [results addObject:element];
    }
    return results;
}

- (NSArray<VTElement *> *)round:(nullable VTKey)center lower:(NSInteger)lower upper:(NSInteger)upper order:(BOOL)desc {
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
    return [self.vt_wcdb beginTransaction];
}

- (BOOL)commit
{
    return [self.vt_wcdb commitTransaction];
}

- (BOOL)rollback
{
    return [self.vt_wcdb rollbackTransaction];
}


@end

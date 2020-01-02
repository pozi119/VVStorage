//
//  VVOrm+Redisable.m
//  VVStorage
//
//  Created by Valo on 2019/12/25.
//

#import <Foundation/Foundation.h>
#import "VVOrm+Redisable.h"

static const char *__vt_uniqueKey = "__vt_uniqueKey";

@interface VVOrm ()
@property (nonatomic, copy, readonly) NSString *vt_uniqueKey;
@end

@implementation VVOrm (Redisable)

- (NSString *)vt_uniqueKey {
    NSString *key = objc_getAssociatedObject(self, __vt_uniqueKey);
    if (!key) {
        if (self.config.primaries.count == 1) {
            key = self.config.primaries.firstObject;
        } else if (self.config.uniques.count > 0) {
            key = self.config.uniques.firstObject;
        } else {
            NSAssert(NO, @"Invalid Orm");
        }
        objc_setAssociatedObject(self, __vt_uniqueKey, key, OBJC_ASSOCIATION_COPY);
    }
    return key;
}

- (VTKey)vt_keyForObject:(id)object
{
    return [object valueForKey:self.vt_uniqueKey];
}

// MARK: set
- (NSInteger)set:(VTValue)anObject forKey:(VTKey)aKey
{
    VTKey key = [self vt_keyForObject:anObject];
    if (![key isEqual:aKey]) return -1;
    NSDictionary *condition = [self uniqueConditionForObject:anObject];
    VTValue value = [self findOne:condition];
    if ([value isEqual:anObject]) return 0;
    BOOL ret = [self upsertOne:anObject];
    return ret ? 1 : -1;
}

- (NSDictionary<VTKey, VTValue> *)multiSet:(NSDictionary<VTKey, VTValue> *)keyValues
{
    if (keyValues.count == 0) return @{};
    NSMutableDictionary<VTKey, VTValue> *results = [NSMutableDictionary dictionary];
    [self.vvdb begin:VVDBTransactionImmediate];
    for (VTKey key in keyValues.allKeys) {
        VTValue value = keyValues[key];
        NSInteger ret = [self set:value forKey:key];
        if (ret >= 0) {
            results[key] = value;
        }
    }
    if (results.count > 0) {
        [self.vvdb commit];
    } else {
        [self.vvdb rollback];
    }
    return results;
}

// MARK: get
- (nullable VTValue)get:(VTKey)aKey
{
    return [self findOne:self.vt_uniqueKey.eq(aKey)];
}

- (NSDictionary<VTKey, VTValue> *)multiGet:(NSArray<VTKey> *)keys
{
    NSMutableDictionary<VTKey, VTValue> *results = [NSMutableDictionary dictionary];
    for (VTKey aKey in keys) {
        VTValue value = [self findOne:self.vt_uniqueKey.eq(aKey)];
        results[aKey] = value;
    }
    return results;
}

- (BOOL)exists:(VTKey)aKey
{
    return [self count:self.vt_uniqueKey.eq(aKey)] > 0;
}

// MARK: del
- (nullable VTValue)del:(VTKey)aKey
{
    VVExpr *condition = self.vt_uniqueKey.eq(aKey);
    VTValue value = [self findOne:condition];
    BOOL ret = [self deleteWhere:condition];
    return ret ? value : nil;
}

- (NSDictionary<VTKey, VTValue> *)multiDel:(NSArray<VTKey> *)keys
{
    NSMutableDictionary<VTKey, VTValue> *results = [NSMutableDictionary dictionary];
    for (VTKey aKey in keys) {
        VVExpr *condition = self.vt_uniqueKey.eq(aKey);
        VTValue value = [self findOne:condition];
        BOOL ret = [self deleteWhere:condition];
        if (ret) {
            results[aKey] = value;
        }
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
    if (limit == 0) return @[];

    NSString *column = self.vt_uniqueKey;
    NSString *condition = @"";
    if (lower) {
        if (bounds & VTBoundLower) {
            condition = condition.and(column.gte(lower));
        } else {
            condition = condition.and(column.gt(lower));
        }
    }
    if (upper) {
        if (bounds & VTBoundUpper) {
            condition = condition.and(column.lte(upper));
        } else {
            condition = condition.and(column.lt(upper));
        }
    }
    VVOrderBy *orderby = desc ? column.desc : column.asc;
    VVSelect *select = [VVSelect makeSelect:^(VVSelect *make) {
        make.orm(self).fields(column).where(condition).orderBy(orderby).limit(limit);
    }];
    NSArray *keyValues = [select allKeyValues];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:keyValues.count];
    for (NSDictionary *kv in keyValues) {
        VTKey key = kv[column];
        if (key) [results addObject:key];
    }

    return results;
}

- (NSArray<VTElement *> *)scan:(nullable VTKey)lower
                         upper:(nullable VTKey)upper
                        bounds:(VTBounds)bounds
                         limit:(NSUInteger)limit
                         order:(BOOL)desc
{
    if (limit == 0) return @[];

    NSString *column = self.vt_uniqueKey;
    NSString *condition = @"";
    if (lower) {
        if (bounds & VTBoundLower) {
            condition = condition.and(column.gte(lower));
        } else {
            condition = condition.and(column.gt(lower));
        }
    }
    if (upper) {
        if (bounds & VTBoundUpper) {
            condition = condition.and(column.lte(upper));
        } else {
            condition = condition.and(column.lt(upper));
        }
    }
    VVOrderBy *orderby = desc ? column.desc : column.asc;
    VVSelect *select = [VVSelect makeSelect:^(VVSelect *make) {
        make.orm(self).where(condition).orderBy(orderby).limit(limit);
    }];
    NSArray *objects = [select allObjects];
    NSMutableArray<VTElement *> *results = [NSMutableArray arrayWithCapacity:objects.count];
    for (VTValue obj in objects) {
        VTKey key = [self vt_keyForObject:obj];
        if (key) {
            VTElement *element = [VTElement new];
            element.key = key;
            element.value = obj;
            [results addObject:element];
        }
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
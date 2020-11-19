//
//  VVRedisStorable.m
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "VVRedisStorage.h"

@interface VVRedisStorage ()
@property (nonatomic, strong, nonnull) NSObject<VVRedisable> *cache;
@property (nonatomic, strong, nonnull) NSObject<VVRedisable> *storage;
@end

@implementation VVRedisStorage

- (instancetype)initWithCache:(nonnull NSObject<VVRedisable> *)cache
        storage:(nonnull NSObject<VVRedisable> *)storage
{
	self = [super init];
	if (self) {
		_cache = cache;
		_storage = storage;
	}
	return self;
}

// MARK: set
- (NSInteger)set:(VTValue)anObject forKey:(VTKey)aKey
{
	VTValue oldValue = [_cache get:aKey];
	if ([oldValue isEqual:anObject]) return 0;
	NSInteger ret = [_storage set:anObject forKey:aKey];
	if (ret >= 0) {
		[_cache set:anObject forKey:aKey];
	}
	return ret;
}

- (NSDictionary<VTKey, VTValue> *)multiSet:(NSDictionary<VTKey, VTValue> *)keyValues
{
	NSArray<VTKey> *keys = keyValues.allKeys;
	NSMutableDictionary<VTKey, VTValue> *storeKeyValues = [NSMutableDictionary dictionary];
	for (VTKey key in keys) {
		VTValue oldValue = [_cache get:key];
		VTValue value = keyValues[key];
		if ([oldValue isEqual:value]) continue;
		storeKeyValues[key] = value;
	}
	NSDictionary *results = [_storage multiSet:storeKeyValues];
	[_cache multiSet:results];
	return results;
}

// MARK: get
- (nullable VTValue)get:(VTKey)aKey
{
	VTValue value = [_cache get:aKey];
	if (value) return value;

	value = [_storage get:aKey];
	if (value) {
		[_cache set:value forKey:aKey];
	}
	return value;
}

- (NSDictionary<VTKey, VTValue> *)multiGet:(NSArray<VTKey> *)keys
{
	NSDictionary *keyValues = [_cache multiGet:keys];
	if (keyValues.count == keys.count) return keyValues;
	NSMutableSet *tempKeys = [NSMutableSet setWithArray:keys];
	NSSet *gainedKeys = [NSSet setWithArray:keyValues.allKeys];
	[tempKeys minusSet:gainedKeys];
	NSArray<VTKey> *subKeys = tempKeys.allObjects;
	NSDictionary *subKeyValues = [_storage multiGet:subKeys];
	if (subKeyValues.count > 0) {
		[_cache multiSet:subKeyValues];
	}
	return keyValues;
}

- (BOOL)exists:(VTKey)aKey
{
	BOOL ret = [_cache exists:aKey];
	if (ret) return ret;
	VTValue value = [_storage get:aKey];
	if (value) {
		[_cache set:value forKey:aKey];
		return YES;
	}
	return NO;
}

// MARK: del
- (nullable VTValue)del:(VTKey)aKey
{
	[_cache del:aKey];
	return [_storage del:aKey];
}

- (NSDictionary<VTKey, VTValue> *)multiDel:(NSArray<VTKey> *)keys
{
	[_cache multiDel:keys];
	return [_storage multiDel:keys];
}

// MARK: query
- (NSArray<VTKey> *)keys:(nullable VTKey)lower
        upper:(nullable VTKey)upper
        bounds:(VTBounds)bounds
        limit:(NSUInteger)limit
        order:(BOOL)desc
{
	return [_storage keys:lower upper:upper bounds:bounds limit:limit order:desc];
}

- (NSArray<VTElement *> *)scan:(nullable VTKey)lower
        upper:(nullable VTKey)upper
        bounds:(VTBounds)bounds
        limit:(NSUInteger)limit
        order:(BOOL)desc
{
	NSArray<VTKey> *storageKeys = [_storage keys:lower upper:upper bounds:bounds limit:limit order:desc];
	NSArray<VTKey> *cacheKeys = [_cache keys:lower upper:upper bounds:bounds limit:limit order:desc];

	NSSet<VTKey> *_storageKeys = [NSSet setWithArray:storageKeys];
	NSSet<VTKey> *_cacheKeys = [NSSet setWithArray:cacheKeys];

	NSMutableSet<VTKey> *delKeys = [NSMutableSet setWithArray:cacheKeys];
	[delKeys minusSet:_storageKeys];
	[_cache multiDel:delKeys.allObjects];

	NSMutableSet<VTKey> *addKeys = [NSMutableSet setWithArray:storageKeys];
	[addKeys minusSet:_cacheKeys];
	NSDictionary *addKeyValues = [_storage multiGet:addKeys.allObjects];
	[_cache multiSet:addKeyValues];

	NSDictionary *keyValues = [_cache multiGet:storageKeys];

	NSMutableArray<VTElement *> *results = [NSMutableArray array];
	for (VTKey key in storageKeys) {
		VTElement *element = [VTElement new];
		element.key = key;
		element.value = keyValues[key];
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

- (BOOL)begin {
	BOOL ret =[self.cache begin];
	if (ret) ret = [self.storage begin];
	return ret;
}


- (BOOL)commit {
	BOOL ret =[self.cache commit];
	if (ret) ret = [self.storage commit];
	return ret;
}


- (BOOL)rollback {
	BOOL ret =[self.cache rollback];
	if (ret) ret = [self.storage rollback];
	return ret;
}

@end

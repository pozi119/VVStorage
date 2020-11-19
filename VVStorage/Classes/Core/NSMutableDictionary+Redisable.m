//
//  NSMutableDictionary+Redisable.m
//  VVStorage
//
//  Created by Valo on 2020/11/18.
//

#import "NSMutableDictionary+Redisable.h"
#import "VVAssociate.h"
#import <objc/runtime.h>

static const char *_vv_associate = "_vv_associate";

@interface NSMutableDictionary ()
@property (nonatomic, strong) VVAssociate *associate;
@end

@implementation NSMutableDictionary (Redisable)

- (VVAssociate *)associate {
	VVAssociate *_associate = objc_getAssociatedObject(self, _vv_associate);
	if(!_associate) {
		_associate = [[VVAssociate alloc] init];
		objc_setAssociatedObject(self, _vv_associate, _associate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return _associate;
}

// MARK: set
- (NSInteger)set:(VTValue)anObject forKey:(VTKey)aKey
{
	VTValue oldValue = [self objectForKey:aKey];
	if ([anObject isEqual:oldValue]) return 0;
	[self setObject:anObject forKey:aKey];
	return 1;
}

- (NSDictionary<VTKey, VTValue> *)multiSet:(NSDictionary<VTKey, VTValue> *)keyValues
{
	NSMutableDictionary *results = [NSMutableDictionary dictionary];
	for (VTKey key in keyValues.allKeys) {
		VTValue oldValue = [self objectForKey:key];
		VTValue value = keyValues[key];
		if ([value isEqual:oldValue]) continue;
		[self setObject:value forKey:key];
		results[key] = value;
	}
	return results;
}

// MARK: get
- (nullable VTValue)get:(VTKey)aKey
{
	return [self objectForKey:aKey];
}

- (NSDictionary<VTKey, VTValue> *)multiGet:(NSArray<VTKey> *)keys
{
	NSMutableDictionary *results = [NSMutableDictionary dictionary];
	for (VTKey key in keys) {
		results[key] = [self objectForKey:key];
	}
	return results;
}

- (BOOL)exists:(VTKey)aKey
{
	return [self objectForKey:aKey] != nil;
}

// MARK: del
- (nullable VTValue)del:(VTKey)aKey
{
	VTValue value = [self objectForKey:aKey];
	[self removeObjectForKey:aKey];
	return value;
}

- (NSDictionary<VTKey, VTValue> *)multiDel:(NSArray<VTKey> *)keys
{
	NSDictionary *results = [self multiGet:keys];
	[self removeObjectsForKeys:keys];
	return results;
}

// MARK: query
- (NSArray<VTKey> *)keys:(nullable VTKey)lower
        upper:(nullable VTKey)upper
        bounds:(VTBounds)bounds
        limit:(NSUInteger)limit
        order:(BOOL)desc
{
	VTKey left = lower <= upper ? lower : upper;
	VTKey right = lower <= upper ? upper : lower;
	NSString *format = [NSString stringWithFormat:@"SELF %@ %@ AND SELF %@ %@",
	                    ((bounds & VTBoundLower) ? @">=" : @">"), left,
	                    ((bounds & VTBoundUpper) ? @"<=" : @"<"), right];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
	NSArray *filtered = [self.allKeys filteredArrayUsingPredicate:predicate];
    NSArray *sorted = [filtered sortedArrayUsingComparator:^NSComparisonResult (VTValue obj1, VTValue obj2) {
        return obj1 < obj2;
    }];
	NSArray *array = desc ? sorted.reverseObjectEnumerator.allObjects : sorted;
	return (limit == 0 || array.count <= limit) ? array : [array subarrayWithRange:NSMakeRange(0, limit)];
}

- (NSArray<VTElement *> *)scan:(nullable VTKey)lower
        upper:(nullable VTKey)upper
        bounds:(VTBounds)bounds
        limit:(NSUInteger)limit
        order:(BOOL)desc
{
	NSArray *keys = [self keys:lower upper:upper bounds:bounds limit:limit order:desc];
	NSMutableArray *results = [NSMutableArray array];
	for (VTKey key in keys) {
		VTElement *element = [VTElement new];
		element.key = key;
		element.value = [self objectForKey:key];
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

// MARK: transaction

- (BOOL)begin
{
	@synchronized (self) {
		VVAssociate *ass = self.associate;
		if (![ass begin]) return NO;

		ass.snapshot = [NSDictionary dictionaryWithDictionary:self];
		return YES;
	}
}

- (BOOL)commit
{
	@synchronized (self) {
		VVAssociate *ass = self.associate;
		if (![ass commit]) return NO;

		ass.snapshot = nil;
		return YES;
	}
}

- (BOOL)rollback
{
	@synchronized (self) {
		VVAssociate *ass = self.associate;
		if (![ass rollback]) return NO;

		[self removeAllObjects];
		if (ass.snapshot) [self setDictionary:self.associate.snapshot];
		ass.snapshot = nil;
		return YES;
	}
}

@end

//
//  VVAssociate.m
//  VVStorage
//
//  Created by Valo on 2020/11/18.
//

#import "VVAssociate.h"

@implementation VVAssociate

- (NSComparator)comparator {
	if (!_comparator) {
		_comparator = ^NSComparisonResult (id obj1, id obj2) {
			return obj1 < obj2 ? NSOrderedAscending : NSOrderedDescending;
		};
	}
	return _comparator;
}

// MARK: transaction

- (BOOL)begin
{
	if (self.inTransaction) return YES;
	self.inTransaction = YES;
	if (self.beginAction && !self.beginAction()) {
		self.inTransaction = NO;
		return NO;
	}
	return YES;
}

- (BOOL)commit {
	if (!self.inTransaction) return YES;
	if (self.commitAction && !self.commitAction()) {
		self.inTransaction = NO;
		return NO;
	}
	return YES;
}

- (BOOL)rollback {
	if (!self.inTransaction) return YES;
	if (self.rollbackAction && !self.rollbackAction()) {
		self.inTransaction = NO;
		return NO;
	}
	return YES;
}

@end

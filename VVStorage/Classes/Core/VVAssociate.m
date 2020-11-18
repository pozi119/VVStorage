//
//  VVAssociate.m
//  VVStorage
//
//  Created by Valo on 2020/11/18.
//

#import "VVAssociate.h"

@implementation VVAssociate

- (NSComparator)comparator{
    if (!_comparator) {
        _comparator = ^NSComparisonResult(id obj1, id obj2) {
            return obj1 < obj2 ? NSOrderedAscending : NSOrderedDescending;
        };
    }
    return _comparator;
}

@end

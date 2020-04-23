//
//  VVRedisable.m
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "VVRedisable.h"

@implementation VTElement

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@, (%@)]", _key, _value];
}

@end

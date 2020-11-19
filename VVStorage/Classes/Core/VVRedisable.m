//
//  VVRedisable.m
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import "VVRedisable.h"
#import <objc/runtime.h>

static const char *_vv_associate = "_vv_associate";

@implementation VTElement

- (NSString *)description {
	return [NSString stringWithFormat:@"[%@, (%@)]", _key, _value];
}

@end

@implementation NSObject (VVRedisable)

- (VVAssociate *)associate {
	VVAssociate *_associate = objc_getAssociatedObject(self, _vv_associate);
	if(!_associate) {
		_associate = [[VVAssociate alloc] init];
		objc_setAssociatedObject(self, _vv_associate, _associate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return _associate;
}

@end

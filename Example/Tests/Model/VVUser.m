//
//  VVUser.m
//  VVStorage
//
//  Created by Valo on 2019/12/1.
//

#import "VVUser.h"

@implementation VVUser
- (NSUInteger)hash {
    return [@(_my_id) hash] ^ _name.hash ^ _avatar_id.hash ^ _remark.hash;
}

- (BOOL)isEqual:(id)object {
    return object != nil && [object isKindOfClass:self.class] && [object hash] == self.hash;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeInt64:_my_id forKey:@"my_id"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_remark forKey:@"remark"];
    [coder encodeObject:_avatar_id forKey:@"avatar_id"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if (self = [super init]) {
        _my_id = [coder decodeInt64ForKey:@"my_id"];
        _name = [coder decodeObjectOfClass:NSString.class forKey:@"name"];
        _remark = [coder decodeObjectOfClass:NSString.class forKey:@"remark"];
        _avatar_id = [coder decodeObjectOfClass:NSString.class forKey:@"avatar_id"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"id: %@, name: %@, remark: %@, avatar: %@", @(_my_id), _name, _remark, _avatar_id];
}

+ (NSArray<NSString *> *)primaries{
    return @[@"my_id"];
}
@end

@implementation VVUserEx

- (NSUInteger)hash {
    return [@(_my_id) hash] ^ [@(_last_login_time) hash];
}

- (BOOL)isEqual:(id)object {
    return object != nil && [object isKindOfClass:self.class] && [object hash] == self.hash;
}

@end

//
//  VVUser.h
//  VVStorage
//
//  Created by Valo on 2019/12/1.
//

#import <Foundation/Foundation.h>
#import <VVSequelize/VVSequelize.h>

NS_ASSUME_NONNULL_BEGIN

@interface VVUser : NSObject <NSCoding, VVOrmable>
@property (nonatomic, assign) int64_t my_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *avatar_id;
@end

@interface VVUserEx : NSObject
@property (nonatomic, assign) int64_t my_id;
@property (nonatomic, assign) NSTimeInterval last_login_time;
@end

NS_ASSUME_NONNULL_END

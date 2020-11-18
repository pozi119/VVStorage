//
//  VVRedisable.h
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import <Foundation/Foundation.h>
#import "VVAssociate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSObject<NSCopying> * VTKey;
typedef NSObject *            VTValue;

typedef NS_OPTIONS (NSUInteger, VTBounds) {
    VTBoundLower = 1 << 0,
    VTBoundUpper = 1 << 1,
};

@interface VTElement : NSObject
@property (nonatomic, copy) VTKey key;
@property (nonatomic, strong) VTValue value;
@end

@protocol VVRedisable <NSObject>

// MARK: set
- (NSInteger)set:(VTValue)anObject forKey:(VTKey)aKey;

- (NSDictionary<VTKey, VTValue> *)multiSet:(NSDictionary<VTKey, VTValue> *)keyValues;

// MARK: get
- (nullable VTValue)get:(VTKey)aKey;

- (NSDictionary<VTKey, VTValue> *)multiGet:(NSArray<VTKey> *)keys;

- (BOOL)exists:(VTKey)aKey;

// MARK: del
- (nullable VTValue)del:(VTKey)aKey;

- (NSDictionary<VTKey, VTValue> *)multiDel:(NSArray<VTKey> *)keys;

// MARK: query
- (NSArray<VTKey> *)keys:(nullable VTKey)lower
                   upper:(nullable VTKey)upper
                  bounds:(VTBounds)bounds
                   limit:(NSUInteger)limit
                   order:(BOOL)desc;

- (NSArray<VTElement *> *)scan:(nullable VTKey)lower
                         upper:(nullable VTKey)upper
                        bounds:(VTBounds)bounds
                         limit:(NSUInteger)limit
                         order:(BOOL)desc;

- (NSArray<VTElement *> *)round:(nullable VTKey)center
                          lower:(NSInteger)lower
                          upper:(NSInteger)upper
                          order:(BOOL)desc;

// MARK: transaction

- (BOOL)begin;

- (BOOL)commit;

- (BOOL)rollback;

@end

@interface NSObject (VVRedisable)
@property (nonatomic, strong, readonly) VVAssociate *associate;
@end

NS_ASSUME_NONNULL_END

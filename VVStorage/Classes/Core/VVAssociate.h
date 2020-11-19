//
//  VVAssociate.h
//  VVStorage
//
//  Created by Valo on 2020/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^VVAssociateAction)(void);

@interface VVAssociate : NSObject
@property (nonatomic, assign) BOOL inTransaction;
@property (nonatomic, strong) Class metaClass;
@property (nonatomic, copy) NSString *uniqueKey;
@property (nonatomic, copy, nullable) NSDictionary *snapshot;
@property (nonatomic, weak) id reserved;

@property (nonatomic, copy) NSComparator comparator;
@property (nonatomic, copy) VVAssociateAction beginAction;
@property (nonatomic, copy) VVAssociateAction commitAction;
@property (nonatomic, copy) VVAssociateAction rollbackAction;

// MARK: transaction

- (BOOL)begin;

- (BOOL)commit;

- (BOOL)rollback;

@end

NS_ASSUME_NONNULL_END

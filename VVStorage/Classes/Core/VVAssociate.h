//
//  VVAssociate.h
//  VVStorage
//
//  Created by Valo on 2020/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VVAssociate : NSObject
@property (nonatomic, assign) BOOL inTransaction;
@property (nonatomic, strong) Class metaClass;
@property (nonatomic, copy) NSString *uniqueKey;
@property (nonatomic, copy) NSComparator comparator;
@property (nonatomic, copy, nullable) NSDictionary *snapshot;
@property (nonatomic, weak) id reserved;
@end

NS_ASSUME_NONNULL_END

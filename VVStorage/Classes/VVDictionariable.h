//
//  VVDictionariable.h
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import <Foundation/Foundation.h>
#import "VVRedisable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VVDictionariable <NSObject>
- (nullable VTValue)vt_objectForKey:(VTKey)aKey;

- (void)vt_setObject:(nullable VTValue)anObject forKey:(VTKey)aKey;

- (NSArray<VTKey> *)vt_allKeys;
@end

@interface NSObject (Dictionariable) <VVRedisable>
@property (nonatomic, copy) NSComparator vtkeyComparator;
@end

NS_ASSUME_NONNULL_END

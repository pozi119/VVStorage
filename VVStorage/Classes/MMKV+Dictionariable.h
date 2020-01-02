//
//  MMKV+Dictionariable.h
//  VVStorage
//
//  Created by Valo on 2019/11/29.
//

#import <Foundation/Foundation.h>
#import <MMKV/MMKV.h>
#import "VVDictionariable.h"

NS_ASSUME_NONNULL_BEGIN

typedef VTKey _Nonnull (^StringToVTKey)(NSString *);
typedef NSString * _Nonnull (^VTKeyToString)(VTKey);

@interface MMKV (Dictionariable) <VVDictionariable>
@property (nonatomic, strong) Class valueClass;
@property (nonatomic, copy, nullable) StringToVTKey stringToKey;
@property (nonatomic, copy, nullable) VTKeyToString keyToString;
@end

NS_ASSUME_NONNULL_END

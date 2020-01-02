#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MMKV+Dictionariable.h"
#import "NSMutableDictionary+Dictionariable.h"
#import "VVDictionariable.h"
#import "VVOrm+Redisable.h"
#import "VVRedisable.h"
#import "VVRedisStorage.h"

FOUNDATION_EXPORT double VVStorageVersionNumber;
FOUNDATION_EXPORT const unsigned char VVStorageVersionString[];

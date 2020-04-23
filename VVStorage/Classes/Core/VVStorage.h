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

#import "NSMutableDictionary+Dictionariable.h"
#import "VVDictionariable.h"
#import "VVRedisable.h"
#import "VVRedisableCache.h"
#import "VVRedisStorage.h"

FOUNDATION_EXPORT double VVStorageVersionNumber;
FOUNDATION_EXPORT const unsigned char VVStorageVersionString[];

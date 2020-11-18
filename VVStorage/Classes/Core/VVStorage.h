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

#import "NSMutableDictionary+Redisable.h"
#import "VVAssociate.h"
#import "VVRedisable.h"
#import "VVRedisStorage.h"

#ifdef VVSTORAGE_SEQUELIZE
#import "VVOrm+Redisable.h"
#endif

#ifdef VVSTORAGE_MMKV
#import "MMKV+Redisable.h"
#endif

#ifdef VVSTORAGE_WCDB
#import "WCTTable+Redisable.h"
#endif

FOUNDATION_EXPORT double VVStorageVersionNumber;
FOUNDATION_EXPORT const unsigned char VVStorageVersionString[];

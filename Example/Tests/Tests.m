//
//  VVStorageTests.m
//  VVStorageTests
//
//  Created by pozi119 on 12/25/2019.
//  Copyright (c) 2019 pozi119. All rights reserved.
//

#import "VVUser.h"
#import <MMKV/MMKV.h>
#import <VVSequelize/VVSequelize.h>
#import <VVStorage/VVStorage.h>

@import XCTest;

@interface Tests : XCTestCase
@property (nonatomic, strong) VVDatabase *db;
@property (nonatomic, strong) VVOrm *orm;
@property (nonatomic, strong) MMKV *mmkv;
@property (nonatomic, strong) VVRedisStorage *storage;
@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [dir stringByAppendingPathComponent:@"test.db"];

    NSComparator comparator = ^(NSNumber *key1, NSNumber *key2) {
        return key1.longLongValue < key2.longLongValue ? NSOrderedAscending : NSOrderedDescending;
    };

    self.db = [VVDatabase databaseWithPath:path];
    self.orm = [VVOrm ormWithClass:VVUser.class name:@"user" database:self.db];

    self.mmkv = [MMKV mmkvWithID:@"com.valo.storage.test"];
    self.mmkv.associate.comparator = comparator;
    self.mmkv.associate.metaClass = VVUser.class;
    self.storage = [[VVRedisStorage alloc] initWithCache:self.mmkv storage:self.orm];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEqual
{
    VVUser *user1 = [VVUser new];
    user1.my_id = 1;
    user1.name = @"张三";
    user1.remark = @"zhangsan";

    VVUser *user2 = [VVUser new];
    user2.my_id = 1;
    user2.name = @"张三";
    user2.remark = @"zhangsan";

    VVUser *user3 = [VVUser new];
    user3.my_id = 2;
    user3.name = @"张三";
    user3.remark = @"zhangsan";

    XCTAssertTrue([user1 isEqual:user2]);
    XCTAssertFalse([user1 isEqual:user3]);
}

- (void)testSet
{
    VVUser *user1 = [VVUser new];
    user1.my_id = 1;
    user1.name = @"张三";
    user1.remark = @"zhangsan";

    [self.storage set:user1 forKey:@(1)];
}

- (void)testMultiSet
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < 100; i++) {
        VVUser *user = [VVUser new];
        user.my_id = i;
        user.name = [NSString stringWithFormat:@"li %@", @(i)];
        user.remark = [NSString stringWithFormat:@"李%@", @(i)];
        dic[@(i)] = user;
    }
    NSDictionary *results = [self.storage multiSet:dic];
    if (results) {
    }
}

- (void)testGet
{
    VVUser *user = (VVUser *)[self.storage get:@(2)];
    if (user) {
    }
}

- (void)testMulitGet
{
    NSDictionary *users = [self.storage multiGet:@[@(0), @(1), @(2), @(9)]];
    if (users) {
    }
}

- (void)testExists
{
    BOOL ret1 = [self.storage exists:@(22)];
    BOOL ret2 = [self.storage exists:@(222)];
    XCTAssertEqual(true, ret1);
    XCTAssertEqual(false, ret2);
}

- (void)testKeys
{
    NSArray *keys1 = [self.storage keys:nil upper:@(20) bounds:0 limit:50 order:NO];
    NSArray *keys2 = [self.storage keys:nil upper:@(20) bounds:VTBoundUpper limit:10 order:YES];
    NSArray *keys3 = [self.storage keys:@(30) upper:@(50) bounds:VTBoundLower limit:10 order:NO];
    NSArray *keys4 = [self.storage keys:@(30) upper:@(50) bounds:VTBoundUpper limit:10 order:YES];
    NSLog(@"keys1: %@\nkeys2: %@\nkeys3: %@\nkeys4: %@\n", keys1, keys2, keys3, keys4);
}

- (void)testScan
{
    NSArray *res1 = [self.storage scan:nil upper:@(20) bounds:0 limit:50 order:NO];
    NSArray *res2 = [self.storage scan:nil upper:@(20) bounds:VTBoundUpper limit:10 order:YES];
    NSArray *res3 = [self.storage scan:@(30) upper:@(50) bounds:VTBoundLower limit:10 order:NO];
    NSArray *res4 = [self.storage scan:@(30) upper:@(50) bounds:VTBoundUpper limit:10 order:YES];
    NSLog(@"results1: %@\nresults2: %@\nresults3: %@\nresults4: %@\n", res1, res2, res3, res4);
}

- (void)testRound
{
    NSArray *res = [self.storage round:@(30) lower:10 upper:10 order:NO];
    NSLog(@"results: %@", res);
}

@end

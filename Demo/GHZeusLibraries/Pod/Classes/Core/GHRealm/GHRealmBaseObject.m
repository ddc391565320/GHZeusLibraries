//
//  GHRealmBaseObject.m
//  GHRealm
//
//  Created by 张冠华 on 16/3/16.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHRealmBaseObject.h"

@implementation GHRealmBaseObject

+ (NSString *)primaryKey
{
    return @"primaryKey";
}
//
///*
// *  根据realm与主键获取实例
// */
//+ (id)realmObjectWithRealm:(RLMRealm *)realm PrimaryKey:(NSString *)primaryKey
//{
//    return [GHRealmBaseObject objectInRealm:realm forPrimaryKey:primaryKey];
//}
//
///*
// *  根据realmName获取实例需要主键
// */
//+ (GHRealmBaseObject *)realmObjectWithRealmName:(NSString *)realmname PrimaryKey:(NSString *)primaryKey
//{
//    return [GHRealmBaseObject objectInRealm:[GHRLMRealm realmWithRealmName:realmname] forPrimaryKey:primaryKey];
//}
//
///*
// *  根据主键更新自身数据库数据
// */
//+ (void)updata:(GHRealmBaseObject *)object Realm:(GHRLMRealm *)realm
//{
//    [realm transactionWithBlock:^{
//        [GHRealmBaseObject createOrUpdateInRealm:realm withValue:object];
//    } error:nil];
//}
//
///*
// *  根据不同realm更新数据库
// */
//+ (void)updata:(GHRealmBaseObject *)object RealmName:(NSString *)realmName
//{
//    @autoreleasepool {
//        GHRLMRealm * realm_ = [GHRLMRealm realmWithRealmName:realmName];
//        [realm_ transactionWithBlock:^{
//            [GHRealmBaseObject createOrUpdateInRealm:realm_ withValue:object];
//        } error:nil];
//    }
//}
//
///*
// *  直接根据已设置主键更新数据库,必需设置主键后才可使用此方法，否则抛出false
// */
//- (void)updataWithRealm:(GHRLMRealm *)realm
//{
//    [realm transactionWithBlock:^{
//        [GHRealmBaseObject createOrUpdateInRealm:realm withValue:self];
//    } error:nil];
//}
//
///*
// *  直接根据已设置主键更新数据库,必需设置主键后才可使用此方法，否则抛出false
// */
//- (void)updataWithRealmName:(NSString *)realmName
//{
//    @autoreleasepool {
//        GHRLMRealm * realm_ = [GHRLMRealm realmWithRealmName:realmName];
//        [realm_ transactionWithBlock:^{
//            [GHRealmBaseObject createOrUpdateInRealm:realm_ withValue:self];
//        } error:nil];
//    }
//
//}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end

//
//  GHRealmBaseObject.h
//  GHRealm
//
//  Created by 张冠华 on 16/3/16.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Realm/Realm.h>
#import "GHRLMRealm.h"

@interface GHRealmBaseObject : RLMObject
@property NSString  *primaryKey;    //主键,用于索引使用

///*
// *  根据realm与主键获取实例
// */
//+ (id)realmObjectWithRealm:(RLMRealm *)realm PrimaryKey:(NSString *)primaryKey;
//
///*
// *  根据realmName获取实例需要主键
// */
//+ (GHRealmBaseObject *)realmObjectWithRealmName:(NSString *)realmname PrimaryKey:(NSString *)primaryKey;
//
///*
// *  根据主键更新自身数据库数据
// */
//+ (void)updata:(GHRealmBaseObject *)object Realm:(GHRLMRealm *)realm;
//
///*
// *  根据不同realm更新数据库,同样需要设置主键
// */
//+ (void)updata:(GHRealmBaseObject *)object RealmName:(NSString *)realmName;
//
///*
// *  直接根据已设置主键更新数据库,必需设置主键后才可使用此方法，否则抛出false
// */
//- (void)updataWithRealm:(GHRLMRealm *)realm;
//
///*
// *  直接根据已设置主键更新数据库,必需设置主键后才可使用此方法，否则抛出false
// */
//- (void)updataWithRealmName:(NSString *)realmName;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<GHRealmBaseObject>
RLM_ARRAY_TYPE(GHRealmBaseObject)

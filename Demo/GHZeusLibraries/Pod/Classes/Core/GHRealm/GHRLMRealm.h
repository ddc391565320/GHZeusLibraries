//
//  GHRLMRealm.h
//  GHRealm
//
//  Created by 张冠华 on 16/3/16.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMRealm(privateSel)

/*
    warning    类目中添加与删除的操作均需要配套:@autorelease使用
    example    
     @autoreleasepool {
     GHRLMRealm *realm_ = [GHRLMRealm defaultSessionRealm];
     [realm_ synAddObject:object];
     }
 */

/*
 *  在安全的线程中添加数据
 */
- (void)synAddObject:(RLMObject *)object;

/*
 *  在安全的线程中删除数据
 */
- (void)synDeleteObject:(RLMObject *)object;

/*
 *  在安全的线程中添加内存数据库数据
 */
- (void)synMemoryDBAddObject:(RLMObject *)object;

/*
 *  在安全的线程中删除内存数据库数据
 */
- (void)synMemoryDBDeleteObject:(RLMObject *)object;

@end

@interface GHRLMRealm : RLMRealm

/*
 *  返回默认会话数据库
 *  会话数据库只存在于内存,并且只存在于应用生命周期中,若应用关闭,会话数据库销毁
 */
+ (GHRLMRealm *)defaultSessionRealm;

/*
 *  根据realmName返回realm实例，若查无此realmName于本地，则创建数据库，理解为创建表或者获取表即可
 */
+ (GHRLMRealm *)realmWithRealmName:(NSString *)realmName;

/*
 *  设置默认数据库路径,理解为设置表名
 */
+ (void)saveDefaultRealmPathWithRealmName:(NSString *)realmName;

/*
 *  获取所有本地数据库path列表数据,方便硬盘空间不够缓存删除
 */
+ (NSArray *)realmList;

/*
 *  储存数据,通过线程队列,需要传入realmName
 */
+ (void)synAddObject:(RLMObject *)object RealmName:(NSString *)realmName;

/*
 *  删除数据,通过线程队列,需要传入realmName
 */
+ (void)synDelegateObject:(RLMObject *)object RealmName:(NSString *)realmName;

/*
 *  储存内存数据,通过线程队列,需要传入realmName
 */
+ (void)synMemoryDBAddObject:(RLMObject *)object RealmName:(NSString *)realmName;

/*
 *  删除内存数据,通过线程队列,需要传入realmName
 */
+ (void)synMemoryDBDeleteObject:(RLMObject *)object RealmName:(NSString *)realmName;

@end

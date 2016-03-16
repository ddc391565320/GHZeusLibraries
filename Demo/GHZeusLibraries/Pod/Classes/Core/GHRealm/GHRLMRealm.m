//
//  GHRLMRealm.m
//  GHRealm
//
//  Created by 张冠华 on 16/3/16.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHRLMRealm.h"
#import <objc/runtime.h>

#define DZ_PATH_OF_DOCUMENT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface GHRLMRealm(private)
@property (nonatomic,strong) RLMRealm *memoryRealm;
@property (nonatomic,strong) dispatch_queue_t   dbQueue;
@property (nonatomic,strong) dispatch_queue_t   memotyDBQueue;
+ (GHRLMRealm *)sharePrivateRealm;
@end

@implementation GHRLMRealm(private)

+ (GHRLMRealm *)sharePrivateRealm
{
    static GHRLMRealm *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        sharedAccountManagerInstance.dbQueue = dispatch_queue_create("com.collegepre.RealmQueue", DISPATCH_QUEUE_SERIAL);
        sharedAccountManagerInstance.memotyDBQueue = dispatch_queue_create("com.collegepre.RealmMemotyQueue", DISPATCH_QUEUE_SERIAL);
    });
    return sharedAccountManagerInstance;
}

- (void)setMemoryRealm:(RLMRealm *)memoryRealm
{
    objc_setAssociatedObject(self, @selector(memoryRealm), memoryRealm, OBJC_ASSOCIATION_RETAIN);
}

- (RLMRealm *)memoryRealm
{
    return objc_getAssociatedObject(self, _cmd);
}

- (dispatch_queue_t)dbQueue
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDbQueue:(dispatch_queue_t)dbQueue
{
    objc_setAssociatedObject(self, @selector(dbQueue), dbQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_queue_t)memotyDBQueue
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMemotyDBQueue:(dispatch_queue_t)memotyDBQueue
{
    objc_setAssociatedObject(self, @selector(memotyDBQueue), memotyDBQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation GHRLMRealm

/*
 *  返回默认会话数据库
 *  会话数据库只存在于内存,并且只存在于应用生命周期中,若应用关闭,会话数据库销毁
 */
+ (GHRLMRealm *)defaultSessionRealm
{
    if (![GHRLMRealm sharePrivateRealm].memoryRealm) {
        NSError * error;
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.inMemoryIdentifier = @"com.collegepre.memoryDB";
        [GHRLMRealm sharePrivateRealm].memoryRealm = [RLMRealm realmWithConfiguration:config error:&error];
    }
    return (GHRLMRealm *)[GHRLMRealm sharePrivateRealm].memoryRealm;
}

/*
 *  根据realmName返回realm实例，若查无此realmName于本地，则创建数据库，理解为创建表或者获取表即可
 */
+ (GHRLMRealm *)realmWithRealmName:(NSString *)realmName
{
    NSString *dbPath = [DZ_PATH_OF_DOCUMENT stringByAppendingPathComponent:[realmName stringByAppendingString:@".realm"]];
#ifdef DEBUG
    NSLog(@"%@",dbPath);
#endif
    GHRLMRealm *realm = (GHRLMRealm *)[RLMRealm realmWithPath:dbPath];
    return realm;
}

/*
 *  设置默认数据库路径,理解为设置表名
 */
+ (void)saveDefaultRealmPathWithRealmName:(NSString *)realmName
{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.path = [[[config.path stringByDeletingLastPathComponent]
                    stringByAppendingPathComponent:realmName]
                   stringByAppendingPathExtension:@"realm"];
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

/*
 *  获取所有本地数据库path列表数据,方便硬盘空间不够缓存删除
 */
+ (NSArray *)realmList
{
    //暂时不实现
    return @[];
}

/*
 *  储存数据,通过线程队列,需要传入realmName
 */
+ (void)synAddObject:(RLMObject *)object RealmName:(NSString *)realmName
{
    dispatch_async([GHRLMRealm sharePrivateRealm].dbQueue, ^{
        @autoreleasepool {
            GHRLMRealm *realm_ = [GHRLMRealm realmWithRealmName:realmName]; 
            [realm_ beginWriteTransaction];
            [realm_ addObject:object];
            [realm_ commitWriteTransaction];
        }
        
    });
}

/*
 *  删除数据,通过线程队列,需要传入realmName
 */
+ (void)synDelegateObject:(RLMObject *)object RealmName:(NSString *)realmName
{
    if(!object)return;
    dispatch_async([GHRLMRealm sharePrivateRealm].dbQueue, ^{
        @autoreleasepool {
            GHRLMRealm *realm_ = [GHRLMRealm realmWithRealmName:realmName];
            [realm_ beginWriteTransaction];
            [realm_ deleteObject:object];
            [realm_ commitWriteTransaction];
        }
    });
}

/*
 *  储存内存数据,通过线程队列,需要传入realmName
 */
+ (void)synMemoryDBAddObject:(RLMObject *)object RealmName:(NSString *)realmName
{
    dispatch_async([GHRLMRealm sharePrivateRealm].dbQueue, ^{
        @autoreleasepool {
            GHRLMRealm *realm_ = [GHRLMRealm defaultSessionRealm];
            [realm_ beginWriteTransaction];
            [realm_ addObject:object];
            [realm_ commitWriteTransaction];
        }
    });
}

/*
 *  删除内存数据,通过线程队列,需要传入realmName
 */
+ (void)synMemoryDBDeleteObject:(RLMObject *)object RealmName:(NSString *)realmName
{
    if(!object)return;
    dispatch_async([GHRLMRealm sharePrivateRealm].dbQueue, ^{
        @autoreleasepool {
            GHRLMRealm *realm_ = [GHRLMRealm defaultSessionRealm];
            [realm_ beginWriteTransaction];
            [realm_ deleteObject:object];
            [realm_ commitWriteTransaction];
        }
    });
}

@end

#pragma mark - category Sel

/*
 *  此处线程安全处理还没有维护，内存与db没有分开，暂时使用
 */

@implementation RLMRealm(privateSel)

/*
 *  在安全的线程中添加数据,数据存在线程队列中
 */
- (void)synAddObject:(RLMObject *)object
{
    [self transactionWithBlock:^{
        [self addObject:object];
    } error:nil];
}

/*
 *  在安全的线程中删除数据，数据存在线程队列中
 */
- (void)synDeleteObject:(RLMObject *)object
{
    if(!object)return;
    [self transactionWithBlock:^{
        [self deleteObject:object];
    } error:nil];
}

/*
 *  在安全的线程中添加内存数据库数据,数据存在线程队列中
 */
- (void)synMemoryDBAddObject:(RLMObject *)object
{
    [self transactionWithBlock:^{
        [self addObject:object];
    } error:nil];
}

/*
 *  在安全的线程中删除内存数据库数据，数据存在线程队列中
 */
- (void)synMemoryDBDeleteObject:(RLMObject *)object
{
    if(!object)return;
    [self transactionWithBlock:^{
        [self deleteObject:object];
    } error:nil];
}


@end

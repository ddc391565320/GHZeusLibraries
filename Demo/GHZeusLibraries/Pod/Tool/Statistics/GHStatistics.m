//
//  GHStatistics.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/25.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHStatistics.h"
#import "TMCache.h"
#import "GHNetwork.h"
#import "GHMacros.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "NSObject+GHExtend.h"

static NSString * const reportServerUrlString = @"reportSeverUrl";          //服务器接收的地址
static NSString * const reportServerParamKey  = @"reportServerParamKey";    //服务器接收的Key
static NSString * const reportServerPolicy    = @"reportServerPolicy";      //上传到服务器的策略
static NSString * const statisticsKey         = @"statisticsKey";           //存储用户使用的Key值
static NSString * const statisticsDefaultPathKey = @"detault_map";          //储存字典的默认Key
static NSString * const statisticsMapEventKey = @"event";                   //点击事件根结点key值
static NSString * const statisticsResidenceTimeMapKey = @"residence_time";  //纪录时间事件结点
static NSString * const statisticsUsedTimeKey = @"used_time";               //纪录app使用时间Key值
static NSString * const statisticsAppStartTimeKey= @"began_time";           //app开始使用的时间
static NSString * const statisticsAppEndTimeKey  = @"end_time";             //app使用结束时间
/*hash map key*/
static NSString * const statisticsHashMapHashKey = @"hash";                 //hashMap唯一标识key值
static NSString * const statisticsPageNameStartKey = @"began_time";
static NSString * const statisticsPageNameEndKey   = @"end_time";
static NSString * const statisticsPageNameKey      = @"page_name";

@interface GHStatistics(private)
- (void)initialize;
- (NSMutableDictionary *)appKeyMap;
- (NSMutableDictionary *)eventMap;
- (NSMutableDictionary *)labelEventMap:(NSString *)labelId;
- (NSMutableDictionary *)residenctTimeMap;
- (NSMutableDictionary *)usedTimeMap;
- (NSMutableDictionary *)pageHashMap:(NSString *)hash PageName:(NSString *)pageName;
@property  (nonatomic,strong) NSMutableDictionary   *statisticsMap;
@property  (nonatomic,strong) NSMutableArray        *statisticsPageHashArr;
@property  (nonatomic,copy)   NSString              *appKey;
@property  (nonatomic,assign) BOOL                   isFristRun;
@end

@implementation GHStatistics
GH_SYNTHESIZE_SINGLETON_FOR_CLASS_M(statistics)

+ (void)statisticsStartWithAppkey:(NSString *)appKey reportPolicy:(GHReportPolicy)reportPolicy reportUrl:(NSString *)reportUrl reportKey:(NSString *)reportKey
{
    [[TMCache sharedCache] setObject:GH_INT_STRING(reportPolicy) forKey:reportServerPolicy];
    [[TMCache sharedCache] setObject:reportUrl forKey:reportServerUrlString];
    [[TMCache sharedCache] setObject:reportKey forKey:reportServerParamKey];
    [GHStatistics sharedstatistics].appKey = appKey;
    [[GHStatistics sharedstatistics] initialize];
}

+ (void)setAppkey:(NSString *)appKey
{
    [GHStatistics sharedstatistics].appKey = appKey;
}

+ (void)beganSetTimeForPage:(NSString *)pageName isaHashKey:(NSUInteger)isaHashKey
{
    [[[GHStatistics sharedstatistics] pageHashMap:GH_INT_STRING((int)isaHashKey) PageName:pageName] setObject:GH_GET_CURENT_TIME forKey:statisticsPageNameStartKey];
}

+ (void)endSetTimeForPage:(NSString *)pageName isaHashKey:(NSUInteger)isaHashKey
{
    [[[GHStatistics sharedstatistics] pageHashMap:GH_INT_STRING((int)isaHashKey) PageName:pageName] setObject:GH_GET_CURENT_TIME forKey:statisticsPageNameEndKey];
}

+ (void)event:(NSString *)eventId
{
    NSMutableDictionary * eventMap_ = [[GHStatistics sharedstatistics] eventMap];

    NSString * eventCount_ = [eventMap_ objectForKey:eventId];
    
    int count;
    if (eventCount_.isNoEmpty) {
        count = [eventCount_ intValue]+1;
    }else{
        count = 1;
    }
    [eventMap_ setObject:GH_INT_STRING(count) forKey:eventId];
}

+ (void)event:(NSString *)eventId prompt:(id)value
{
    //预留
}

+ (void)event:(NSString *)eventId label:(NSString *)labelId
{
    NSMutableDictionary *labelMap_ = [[GHStatistics sharedstatistics] labelEventMap:labelId];
    NSString * eventCount_ = [labelMap_ objectForKey:eventId];
    
    int count;
    if (eventCount_.isNoEmpty) {
        count = [eventCount_ intValue]+1;
    }else{
        count = 1;
    }
    [labelMap_ setObject:GH_INT_STRING(count) forKey:eventId];

}

+ (void)isEncrypt:(BOOL)encrypt
{
    //预留
}

@end

#pragma mark - private Class SEL
@implementation GHStatistics(private)

- (void)initialize
{
    self.isFristRun = YES;
    self.statisticsPageHashArr = [NSMutableArray array];
    
    //程序进入后台时调用通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hostDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //程序从后台进入前台时调用通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hostDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //程序被干掉时调用通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hostWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
    
    //开始纪录app使用时间
    [[self usedTimeMap] setValue:GH_GET_CURENT_TIME forKey:statisticsAppStartTimeKey];
}

//程序进入后台时
- (void)hostDidEnterBackground:(id)sender
{
    //持久化数据
    [[TMCache sharedCache] setObject:self.statisticsMap forKey:statisticsDefaultPathKey];
}

//程序进入前台后
- (void)hostDidBecomeActive:(id)sender
{
    //恢复数据(如果被错杀的话)
    if ([[[TMCache sharedCache] objectForKey:statisticsDefaultPathKey] isNoEmpty]) {
        [self setStatisticsMap:[[TMCache sharedCache] objectForKey:statisticsDefaultPathKey]];
    }
}

//程序被杀掉
- (void)hostWillTerminate:(id)sender
{
    //检查是否有不合法数据
    for (NSMutableDictionary * map_ in self.statisticsPageHashArr) {
        BOOL    isSafe = NO;
        if (![[map_ objectForKey:statisticsPageNameStartKey] isNoEmpty] || ![[map_ objectForKey:statisticsPageNameEndKey] isNoEmpty]) {
            isSafe = NO;
        }else isSafe=YES;
        if (!isSafe) {
            NSMutableArray  * notSafeArr_ = [self.residenctTimeMap objectForKey:[map_ objectForKey:statisticsPageNameKey]];
            for (NSMutableDictionary * notSafeMap_ in notSafeArr_) {
                if ([[notSafeMap_ objectForKey:statisticsHashMapHashKey] isEqualToString:[map_ objectForKey:statisticsHashMapHashKey]]) {
                    [notSafeArr_ removeObject:notSafeMap_];
                    [self.statisticsPageHashArr removeObject:map_];
                }
            }
        }
    }
    
    NSLog(@"%@",self.statisticsMap);
    //开始纪录app使用时间
    [[self usedTimeMap] setValue:GH_GET_CURENT_TIME forKey:statisticsAppEndTimeKey];
    [[TMCache sharedCache] setObject:self.statisticsMap forKey:statisticsDefaultPathKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (NSMutableDictionary *)statisticsMap
{
    NSMutableDictionary * map_ = objc_getAssociatedObject(self, _cmd);
    /*
     if (!map_) {
     map_ = [[NSMutableDictionary alloc] init];
     objc_setAssociatedObject([GHStatistics sharedstatistics], _cmd, map_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
     }
     */
    return map_;
}

- (void)setStatisticsMap:(NSMutableDictionary *)statisticsMap
{
    SEL key = @selector(statisticsMap);
    objc_setAssociatedObject(self, key, statisticsMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)statisticsPageHashArr
{
    NSMutableArray * arr_ = objc_getAssociatedObject(self, _cmd);
    return arr_;
}

- (void)setStatisticsPageHashArr:(NSMutableArray *)statisticsPageHashArr
{
    SEL key = @selector(statisticsPageHashArr);
    objc_setAssociatedObject(self, key, statisticsPageHashArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)appKey
{
    return objc_getAssociatedObject(self, _cmd);;
}

- (void)setAppKey:(NSString *)appKey
{
    if ([[[TMCache sharedCache] objectForKey:statisticsDefaultPathKey] isNoEmpty]) {
        [self setStatisticsMap:[[TMCache sharedCache] objectForKey:statisticsDefaultPathKey]];
    }else{
        [self setStatisticsMap:[[NSMutableDictionary alloc] init]];
    }
    
    if (![[self.statisticsMap objectForKey:appKey] isNoEmpty]) {
        [self.statisticsMap setValue:[NSMutableDictionary dictionary] forKey:appKey];
    }
    SEL key = @selector(appKey);
    objc_setAssociatedObject(self, key, appKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)isFristRun
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsFristRun:(BOOL)isFristRun
{
    SEL key = @selector(isFristRun);
    objc_setAssociatedObject(self, key, @(isFristRun), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableDictionary *)appKeyMap
{
    return [self.statisticsMap objectForKey:self.appKey];
}

- (NSMutableDictionary *)eventMap
{
    NSMutableDictionary * eventMap = [[self appKeyMap] objectForKey:statisticsMapEventKey];
    if (!eventMap.isNoEmpty) {
        eventMap = [NSMutableDictionary dictionary];
    }
    
    [[self appKeyMap] setObject:eventMap forKey:statisticsMapEventKey];
    
    return eventMap;
}

- (NSMutableDictionary *)labelEventMap:(NSString *)labelId
{
    NSMutableDictionary * eventMap_ = [self eventMap];
    NSMutableDictionary * labelMap_ = [eventMap_ objectForKey:labelId];
    
    if (![labelMap_ isNoEmpty]) {
        labelMap_ = [NSMutableDictionary dictionary];
        [eventMap_ setObject:labelMap_ forKey:labelId];
    }
    
    return labelMap_;
}

- (NSMutableDictionary *)residenctTimeMap
{
    NSMutableDictionary * residenctMap_ = [[self appKeyMap] objectForKey:statisticsResidenceTimeMapKey];
    if (!residenctMap_.isNoEmpty) {
        residenctMap_ = [NSMutableDictionary dictionary];
    }
    
    [[self appKeyMap] setObject:residenctMap_ forKey:statisticsResidenceTimeMapKey];
    
    return residenctMap_;
}

- (NSMutableDictionary *)usedTimeMap
{
    NSMutableArray * usedTimeArray_ = [[self appKeyMap] objectForKey:statisticsUsedTimeKey];
    NSMutableDictionary * userTimeMap;
    if (!usedTimeArray_.isNoEmpty) {
        usedTimeArray_ = [NSMutableArray array];
    }
    
    [[self appKeyMap] setObject:usedTimeArray_ forKey:statisticsUsedTimeKey];   
    
    if (self.isFristRun) {
        userTimeMap = [NSMutableDictionary dictionary];
        [usedTimeArray_ insertObject:userTimeMap atIndex:0];
        self.isFristRun = NO;
    }else
    {
        if (usedTimeArray_.count==0) {
            userTimeMap = [NSMutableDictionary dictionary];
            [usedTimeArray_ insertObject:userTimeMap atIndex:0];
        }
        userTimeMap = [usedTimeArray_ objectAtIndex:0];
    }
    
    return userTimeMap;
}

- (NSMutableDictionary *)pageHashMap:(NSString *)hash PageName:(NSString *)pageName
{
    NSMutableDictionary * hashMap;
    NSMutableArray      * pageNameArr_ = [self.residenctTimeMap objectForKey:pageName];
    
    if (!pageNameArr_.isNoEmpty) {
        pageNameArr_ = [NSMutableArray array];
        hashMap = [NSMutableDictionary dictionary];
        [hashMap setValue:hash forKey:statisticsHashMapHashKey];
        [hashMap setValue:pageName forKey:statisticsPageNameKey];
        [pageNameArr_ addObject:hashMap];
        [self.residenctTimeMap setObject:pageNameArr_ forKey:pageName];
    }
    
    for (NSMutableDictionary * map in pageNameArr_) {
        if ([[map objectForKey:statisticsHashMapHashKey] isEqualToString:hash]) {
            hashMap = map;
            break;
        }
    }
    if (!hashMap.isNoEmpty) {
        hashMap = [NSMutableDictionary dictionary];
        [hashMap setValue:hash forKey:statisticsHashMapHashKey];
        [hashMap setValue:pageName forKey:statisticsPageNameKey];
        [pageNameArr_ addObject:hashMap];
    }
    [self.statisticsPageHashArr addObject:hashMap];
    return hashMap;
}

@end

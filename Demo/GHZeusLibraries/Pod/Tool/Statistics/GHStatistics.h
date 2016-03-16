//
//  GHStatistics.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/25.
//  Copyright © 2016年 张冠华. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 
 
 
 
                    prompt:用户数据发送成功之后会删除所记录的用户操作数据，防止混淆.客户端使用时间为自动记录
                    本tool类生产的数据结构为:
                    {
                        "dc_student":
                        {
                             "appKey":"dc_student",
                             "residence_time":
                             {
                            "pageName":     ->该pageName为使用者命名的pageName
                             [
                             {
                             "hash":"xxxxxxxxx",
                             "began_time":"232132321L",
                             "end_time":"2323213123L"
                             }
                             ]
                             },
                             "event":
                             {
                             "eventId":321,     ->哀eventName为使用者命名的eventId
                             "eventId2":456,
                             "eventId3":"sadsdasdasdasd"
                             "labelId":
                             {
                             "eventId3":456,
                             "eventId4":983
                             }
                             },
                             "used_time":
                             [
                             {
                             "began_time":21323123L,
                             "end_time":323123123L
                             }
                             ],
                             "custom":
                             {
                                "eventId_string":
                                [
                                    {
                                        "that Demo":"prompt",
                                        "time":123123213L
                                    },
                                    {
                                        "that Demo2":"prompt2",
                                        "time":123123213L

                                    }
                                ],
                                "eventId_map":
                                [
                                    {
                                        "key1":"value1",
                                        "key2":"value2"
                                        ...
                                    }
                                ]
                             }
                        },
                        "dc_student2":
                        {
                             "appKey":"dc_student2",
                             "residence_time":
                             {
                             "pageName":     ->该pageName为使用者命名的pageName
                             [
                             {
                             "began_time":"232132321L",
                             "end_time":"2323213123L"
                             }
                             ]
                             },
                             "event":
                             {
                             "eventId":321,     ->哀eventName为使用者命名的eventId
                             "eventId2":456,
                             "labelId":
                             {
                             "eventId3":456,
                             "eventId4":983
                             }
                             },
                             "used_time":
                             [
                             {
                             "began_time":21323123L,
                             "end_time":323123123L
                             }
                             ]
                        }
                    }
                    *有可能出现数据改动，因为可能会有用户退出用别的用户登录上来的场景，所以json会为{"appKey1":{},"appkey2":{}}结构
 
*/

#import <Foundation/Foundation.h>

#define XcodeAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

typedef enum {
    
    GHRealTimePolicy    =   1 ,         //实时发送,不推荐使用,并且现在也没有去实现
    GHBatchPolicy       =   2 ,         //启动时发送,默认
    GHWifiBatchPolicy   =   3 ,         //启动时若在Wifi环境下才发送
    GHSentOnExitPolicy  =   4           //退出或处于后台时发送
    
}GHReportPolicy;


@interface GHStatistics : NSObject

/**
 *  需要配置正确的appKey，该处的appKey可以使用UserId或者能代替用户身份的唯一标识来代替，若有不需要用户身份的逻辑，则也可使用设备ID代替
 *  需设置发送策略，需设置服务端接收接口,接收key值,json数据表单会以字符串形势传递给服务端,需要注意的是该方法整个程序生命周期中只允许使用一次
 */

+ (void)statisticsStartWithAppkey:(NSString *)appKey
                     reportPolicy:(GHReportPolicy)reportPolicy
                        reportUrl:(NSString *)reportUrl
                        reportKey:(NSString *)reportKey;

/**
 *  新纪录appKey用户纪录,用户登录登出
 *  或者需要新纪录用户时，应调用该方法,json结构会多出一个结点
 */

+ (void)setAppkey:(NSString *)appKey;

/*
 *  记录停留在某页的页面时间，必需配合endSetTimeForPage:来使用，若只使用一个，则无效.该方法应在viewWillAppear中调用,需要传递
 *  该viewController指针hash值
 */

+ (void)beganSetTimeForPage:(NSString *)pageName isaHashKey:(NSUInteger)isaHashKey;

/*
 *  记录停留在某页的页面时间，必需配合beganSetTimeForPage:来使用，若只使用一个，则无效.该方法应在viewWillDisappear中调用,需要传递
 *  该viewController指针hash值
 */

+ (void)endSetTimeForPage:(NSString *)pageName isaHashKey:(NSUInteger)isaHashKey;

/*
 *  事件统计:不同的事件可任意编辑ID，该事件统计记录事件ID点击次数并且上传至服务器,eventId可为任何有意义的Key值
 */

+ (void)event:(NSString *)eventId;

/*
 *  自定义事件统计:不同的事件可任意编辑ID，该事件统计记录事件ID点击次数并且上传至服务器,eventId可为任何有意义的Key值,value只可传map与string
 */

+ (void)event:(NSString *)eventId prompt:(id)value;

/*
 *  事件统计:增加了分类处理，如:在A类逻辑中的事件需要统计，B类逻辑中相同的事件也需要统计，为了分解A类与B类，则可在label中传入A类Name，或B类Name
 */

+ (void)event:(NSString *)eventId label:(NSString *)labelId;

/*
 *  预留接口:是否数据需要加密以及加密方式,该接口暂不实现
 */

+ (void)isEncrypt:(BOOL)encrypt;

@end

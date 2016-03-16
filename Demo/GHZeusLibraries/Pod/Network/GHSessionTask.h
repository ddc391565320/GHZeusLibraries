//
//  GHSessionTask.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHNetworkConfig.h"
//#import "GHDataModelObjType.h"

@class GHSessionTask;
typedef NS_OPTIONS(NSUInteger, SessionTaskState) {
    SessionTaskStateRunable            = 1 <<  0,//初始状态
    SessionTaskStateRunning            = 1 <<  1,//执行状态
    SessionTaskStateCancel             = 1 <<  2,//任务取消
    SessionTaskStateSuccess            = 1 <<  3,//任务成功
    SessionTaskStateFail               = 1 <<  4,//业务错误||请求失败
    SessionTaskStateNoReach            = 1 <<  5,//无法连接
    SessionTaskStateCacheSuccess       = 1 <<  6,//获取到正确数据的缓存
    SessionTaskStateCacheFail          = 1 <<  7,//无缓存数据
    SessionTaskStateCacheNoTry         = 1 <<  8,//不尝试导入缓存
};

/**
 底部配置实现层采用delegate call back机制,viewModel层采用block call back机制
 */

//请求数据的状态回调
@protocol SessionTaskDelegate<NSObject>

/**
 *  请求完成后调用，state:SessionTaskStateSuccess 或 SessionTaskStateFail
 */
- (void)taskConnected:(GHSessionTask *)task;

/**
 *  请求过程中调用 state:SessionTaskStateRunning|SessionTaskStateCacheSuccess 或 SessionTaskStateRunning|SessionTaskStateCacheFail 或 SessionTaskStateRunning|SessionTaskStateCacheNoTry 或 SessionTaskStateCancel
 */
- (void)taskSending:(GHSessionTask *)task;

/**
 *  无网情况下调用 state:SessionTaskStateNoReach|SessionTaskStateCacheSuccess 或 SessionTaskStateNoReach| SessionTaskStateCacheFail 或 SessionTaskStateNoReach| SessionTaskStateCacheNoTry
 */
- (void)taskLosted:(GHSessionTask *)task;



@end


@interface GHSessionTask : NSObject

+ (instancetype)taskWithMethod:(NSString *)method
                          path:(NSString *)path
                        params:(NSMutableDictionary *)params
                      delegate:(id<SessionTaskDelegate>)delegate
                   requestType:(NSString *)type;

+ (instancetype)taskWithMethod:(NSString *)method
                          path:(NSString *)path
                        params:(NSMutableDictionary *)params
                      pathKeys:(NSArray *)keys
                      delegate:(id<SessionTaskDelegate>)delegate
                   requestType:(NSString *)type;

@property(nonatomic, weak) id<SessionTaskDelegate> delegate;

/**
 *  不设置则每个session默认为NetworkConfig的baseURL为基本的路径
 */
@property(nonatomic, copy) NSString *baseURL;

/**
 *  baseURL+path+params构成完整的请求
 *  如baseURL:http://abc path:/a paramas(拼接成查询字符串的形式):?key=value
 */
@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *method;

/**
 *  pathKeys不为空则表示为http://abc/a/value1/value2/...的格式。pathkeys=@[key1,key2....]
 */
@property(nonatomic, copy) NSArray *pathkeys;

/**
 *  请求参数
 */
@property(nonatomic, strong) NSMutableDictionary *params;

/**
 *  需要嵌套解析的数据结构类名，如需要解析json:
 *  {
 *      "key":"xxxxxxxxx"
 *  }
 *  对应数据结构为:
 *  @interface JsonData : NSObject
 *  @property(nonatomic, copy) NSString *key;
 *  @end
 *  则命名为JsonData
 */
@property(nonatomic, copy) NSString *dataClassName;

/**
 *  分页模型中的快捷参数
 */
@property(nonatomic, assign) NSUInteger page;
@property(nonatomic, assign) NSUInteger pageSize;

/**
 *  是否对正确返回数据缓存 deafult YES,upload no
 */
@property(nonatomic, assign, getter=isCached) BOOL cached;

/**
 *  是否尝试导入缓存,是否有缓存由cached的判断
 *  默认为YES,分页时应设置成NO来解决上拉加载来导入缓存
 */
@property(nonatomic, assign) BOOL importCacheOnce;

/**
 *  判断请求成功的业务逻辑是否正确,deafult YES,适用于有返回code码(断言使用)
 */
@property(nonatomic, assign, getter=isCached) BOOL shouldCheckCode;

/**
 *  任务标识
 */
@property(nonatomic, copy) NSString *requestType;

/**
 *  返回的数据模型
 */
@property(nonatomic, strong, readonly) NSDictionary *responseObject;

/**
 *  返回的解析好的嵌套数据模型
 */
@property(nonatomic, strong) id responseObj;

/**
 *  下载好的文件二进制储存地址
 */
@property(nonatomic, copy) NSString *downloadDataPath;

/**
 *  请求时发生的错误，无网有数据情况下也有缓存。
 */
@property(nonatomic, strong, readonly) NSError *error;      //(无网情况下有error)

/**
 *  请求反馈消息,在设置Error或者responseObject设置
 */
@property(nonatomic, copy, readonly) NSString *message;

/**
 *  GET的请求格式 每次准备请求时刷新
 */
@property(nonatomic, copy, readonly) NSString *absoluteURL;

/**
 *  absoluteURL的MD5值
 */
@property(nonatomic, copy, readonly) NSString *cacheKey;

/**
 *  状态码，由服务器返回(如0表示没有错误)
 */
@property(nonatomic, assign, readonly) NSInteger codeKey;

/**
 *  请求状态
 */
@property(nonatomic, assign, readonly) SessionTaskState state;

/**
 *  请求头设置，或者在NetworkConfig设置全局的
 */
- (void)setValue:(id)value forHeaderField:(NSString *)key;
- (NSDictionary *)httpRequestFields;

- (BOOL)runable;
- (BOOL)succeed;                //网络请求数据成功
- (BOOL)failed;                 //网络请求数据失败
- (BOOL)running;                //正在运行状态
- (BOOL)cacheSuccess;           //缓存数据成功
- (BOOL)cacheFail;             //缓存数据失败
- (BOOL)isCancel;

/**
 *  在每次请求时调用，清空输出
 */
- (void)restAllOutput;

/**
 *  开始请求调用
 *  1.设置基本数据:state
 *  2.导入缓存
 */
- (void)startSession;   //任务开始

/**
 *  请求任务结束调用
 *  1.设置基本数据:responseObject|error|state
 *  2.缓存数据
 *  3.通知
 */
- (void)responseSessionWithResponseObject:(NSDictionary *)responseObject error:(NSError *)error;

/**
 *  配置任务无法连接的输出
 *  1.基本输出:state,数据结果(message,error,responseObject)
 *  2.通知完用户后并准备重新运行
 */
- (void)noReach;


@end

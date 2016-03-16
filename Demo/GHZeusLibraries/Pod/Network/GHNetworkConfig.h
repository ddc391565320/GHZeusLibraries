//
//  GHNetworkConfig.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHMacros.h"
#define kNetworkPage @"page"
#define kNetworkPageSize @"pageSize"

/**
 *  与下Type相对应
 */

static NSString *const GHNetworkErrorCodeReconnect             = @"GHNetworkErrorCodeReconnect";
static NSString *const GHNetworkErrorCodeLimitedConnections    = @"GHNetworkErrorCodeLimitedConnections";
static NSString *const GHNetworkErrorCodeDontConnect           = @"GHNetworkErrorCodeDontConnect";
static NSString *const GHNetworkErrorCodeNotificationServer    = @"GHNetworkErrorCodeNotificationServer";
static NSString *const GHNetworkErrorCodeUsedCacheData         = @"GHNetworkErrorCodeUserCacheData";

typedef enum {
    GHNetworkErrorCodeReconnectType             = 1 << 0,       // 出现错误代码后始终重新连接
    GHNetworkErrorCodeLimitedConnectionsType    = 1 << 1,       // 出现错误代码后重新连接2次
    GHNetworkErrorCodeDontConnectType           = 1 << 2,       // 出现错误代码后不尝试重新连接
    GHNetworkErrorCodeNotificationServerType    = 1 << 3,       // 出现错误代码后调用接口通知服务器(服务端发生重大BUG)
    GHNetworkErrorCodeUsedCacheDataType         = 1 << 4        // 出现错误代码以后，调用缓存数据
}GHNetworkErrorCodeSolutionType;

@interface GHNetworkConfig : NSObject
GH_SINGLETON_NAME(Config);

/**
 *  错误处理机制枚举，该处预留
 */
@property(nonatomic, assign, readonly) GHNetworkErrorCodeSolutionType   solutionType;

/**
 *  错误处理机制处理方案Map
 */
@property(nonatomic, strong, readonly) NSDictionary   *solutionMap;

/**
 *  公共的相同URL部分
 */
@property(nonatomic, copy, readonly) NSString *baseURL;

/**
 *  状态码路径,供task取得数据
 */
@property(nonatomic, copy, readonly) NSString *codeKeyPath;

/**
 *  消息码路径,供task取得数据
 */
@property(nonatomic, copy, readonly) NSString *msgKeyPath;

/**
 *  客户端标识，用于设置请求头
 */
@property(nonatomic, copy, readonly) NSString *userAgent;

/**
 *  正确的状态码
 */
@property(nonatomic, assign, readonly) NSUInteger rightCode;

/**
 *  默认的公共请求头
 */
@property(nonatomic, copy, readonly) NSDictionary *defaultHeaderFields;

/**
 *  网络是否通(程序启动时有0.02左右的延迟,故需延迟0.02秒请求)
 */
@property(nonatomic, assign, readonly) BOOL reachable;

/**
 *  出现错误代码后，报告服务器，服务器出现重大BUG
 */
@property(nonatomic, copy, readonly) NSString * errorFeedbackServerUrl;

/**
 *  配置公共参数 solutionMap设置为@{@"20000":GHNetworkErrorCodeReconnect,@"20001":@"GHNetworkErrorCodeLimitedConnections"}
 */
- (void)setupBaseURL:(NSString *)baseURL
         codeKeyPath:(NSString *)codeKeyPath
          msgKeyPath:(NSString *)msgKeyPath
           userAgent:(NSString *)userAgent
           rightCode:(NSUInteger)rightCode
    errorFeedBackUrl:(NSString *)feedBackUrl
ErrorCodeAndSolution:(NSDictionary *)solutionMap;

/**
 *  添加公共请求头
 */
- (void)addDefaultHeaderFields:(NSDictionary *)headerFields;

@end

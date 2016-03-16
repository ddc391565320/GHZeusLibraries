//
//  GHNetworkConfig.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHNetworkConfig.h"
#import "AFNetworking.h"
#import "NSDictionary+GHExtend.h"
#import "NSString+GHExtend.h"

@interface GHNetworkConfig ()

@property(nonatomic, copy) NSMutableDictionary *headerFields;

@end

@implementation GHNetworkConfig
GH_SYNTHESIZE_SINGLETON_FOR_CLASS_M(Config)

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _headerFields = [NSMutableDictionary dictionary];
        });
    }
    return self;
}

-  (void)setupBaseURL:(NSString *)baseURL
          codeKeyPath:(NSString *)codeKeyPath
           msgKeyPath:(NSString *)msgKeyPath
            userAgent:(NSString *)userAgent
            rightCode:(NSUInteger)rightCode
     errorFeedBackUrl:(NSString *)feedBackUrl
 ErrorCodeAndSolution:(NSDictionary *)solutionMap;
{
    _baseURL        = baseURL;
    _codeKeyPath    = codeKeyPath;
    _msgKeyPath     = msgKeyPath;
    _rightCode      = rightCode;
    _userAgent      = userAgent;
    _errorFeedbackServerUrl = feedBackUrl;
    _solutionMap    = solutionMap;
    
    if (userAgent.isNoEmpty)
        [self.headerFields setObject:userAgent forKey:@"User-Agent"];
}

- (void)addDefaultHeaderFields:(NSDictionary *)headerFields
{
    if (headerFields.isNoEmpty)
        [self.headerFields addEntriesFromDictionary:headerFields];
}

- (NSDictionary *)defaultHeaderFields
{
    return self.headerFields;
}

- (BOOL)reachable
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}



@end

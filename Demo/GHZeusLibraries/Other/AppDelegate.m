//
//  AppDelegate.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "AppDelegate.h"
#import "GHNetworkConfig.h"
#import "AFNetworkReachabilityManager.h"
#import "GHViewModel.h"
#import "GHStatistics.h"
#import "GHErrorHandler.h"
#import "GHErrorHandlerUpload.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"unkonw");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无法连接");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi");
                break;
                
            default:
                break;
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    /**
     *  {
     message = "\U64cd\U4f5c\U6210\U529f";
     status = 100;
     }
     */
    [[GHNetworkConfig sharedConfig] setupBaseURL:@"http://v5.api.maichong.me"
                                     codeKeyPath:@"status"
                                      msgKeyPath:@"message"
                                       userAgent:@"IOS"
                                       rightCode:100
                                errorFeedBackUrl:@"http://127.0.0.1"
                            ErrorCodeAndSolution:@{@"20000":GHNetworkErrorCodeUsedCacheData,
                                                   @"30000":GHNetworkErrorCodeNotificationServer}];
    
    [GHStatistics statisticsStartWithAppkey:@"zgh~~~"
                               reportPolicy:GHBatchPolicy
                                  reportUrl:@"http://127.0.0.1"
                                  reportKey:@"report"];
    
    // ErrorHandle
    [[GHErrorHandlerUpload sharedErrorHandler] validateErrorTypeWithGHErrorHandlerReportType:GHErrorHandlerReportTypeSaveTXTAndUploadToServer txtLogFeedBackURLString:@"http://182.92.243.56/nbsc/txtUpload.do"];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

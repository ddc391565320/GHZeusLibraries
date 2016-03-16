//
//  GHShake.h
//  GHShake
//
//  Created by 张冠华 on 16/2/14.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHMacros.h"

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#endif

typedef enum {
    GHErrorHandlerReportTypeLog,                //记录输出错误Log日志模式
    GHErrorHandlerReportTypeShake,              //摇一摇反馈模式
    GHErrorHandlerReportTypeCompatibilityMode,   //兼容模式，同时兼容输出错误日至与摇一摇
    GHErrorHandlerReportTypeSaveTXTAndUploadToServer       //每次打开先检查上传上次错误日志 并保存
} GHErrorHandlerReportType;

@interface GHErrorHandler : NSObject
GH_SINGLETON_NAME(ErrorHandler)


- (void)validateErrorTypeWithGHErrorHandlerReportType:(GHErrorHandlerReportType)type feedBackEmailAddress:(NSString *)address feedBackServerHost:(NSString *)host;

- (void)validateErrorTypeWithGHErrorHandlerReportType:(GHErrorHandlerReportType)type txtLogFeedBackURLString:(NSString *)URLString;
/**
 *  输出错误日志信息
 */
- (NSDictionary *)exportErrorinfo;
@end

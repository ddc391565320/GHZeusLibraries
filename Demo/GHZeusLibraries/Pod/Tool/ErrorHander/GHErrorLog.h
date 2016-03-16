//
//  GHErrorLog.h
//  GHShake
//
//  Created by 张冠华 on 16/2/14.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const UncaughtExceptionHandlerSignalKey;
extern NSString *const SingalExceptionHandlerAddressesKey;
extern NSString *const ExceptionHandlerAddressesKey;

@interface GHErrorLog : NSObject

+ (void)installExceptionHandler;

/**
 *  记录并上传
 */
+ (void)installExceptionHandlerAndUpload;

+ (NSArray *)backtrace;

@end

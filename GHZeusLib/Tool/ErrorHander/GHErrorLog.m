//
//  GHErrorLog.m
//  GHShake
//
//  Created by 张冠华 on 16/2/14.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHErrorLog.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "NSDictionary+GHExtend.h"
#import "TMCache.h"

#import "GHUploadSessionTask.h"


#ifdef __OBJC__
#import <UIKit/UIKit.h>
#endif

NSString *const UncaughtExceptionHandlerSignalKey   = @"UncaughtExceptionHandlerSignalKey";
NSString *const SingalExceptionHandlerAddressesKey  = @"SingalExceptionHandlerAddressesKey";
NSString *const ExceptionHandlerAddressesKey        = @"ExceptionHandlerAddressesKey";



const int32_t _uncaughtExceptionMaximum = 20;

void signalHandler(int signal);
void exceptionHandler(NSException *exception);
void sendMail(NSString *errorInfo);

@interface GHErrorLog()


@end

@implementation GHErrorLog

void signalHandler(int signal)
{
    volatile int32_t _uncaughtExceptionCount = 0;
    int32_t exceptionCount = OSAtomicIncrement32(&_uncaughtExceptionCount);
    
    if (exceptionCount > _uncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [GHErrorLog backtrace];
    [userInfo  setObject:callStack  forKey:SingalExceptionHandlerAddressesKey];
}

void exceptionHandler(NSException *exception)
{
    volatile int32_t _uncaughtExceptionCount = 0;
    int32_t exceptionCount = OSAtomicIncrement32(&_uncaughtExceptionCount);
    
    if (exceptionCount > _uncaughtExceptionMaximum) {
        return;
    }
    
    NSArray *callStack = [GHErrorLog backtrace];
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:ExceptionHandlerAddressesKey];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfo forKey:@"ErrorDetailInfoKey"];
    
    NSArray *callStack_ = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack_ componentsJoinedByString:@"\n"]];
    NSLog(@"%@",content);
    
    NSLog(@"Exception Invoked: %@", userInfo);

}

void sendMail(NSString *errorInfo)
{
    NSString *crashLogInfo = [NSString stringWithFormat:@"\n call stack info : %@", errorInfo];
    NSString *urlStr = [NSString stringWithFormat:@"mailto://zhangguanhua@collegepre.com?subject=bug报告&body=感谢您的配合!,错误详情:%@",
                        crashLogInfo];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    [[UIApplication sharedApplication] openURL:url];
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack,frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i=0;i<frames;i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

+ (void)installExceptionHandler
{
    // 程序初始化的时候保存一些设备信息
    
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    signal(SIGHUP, signalHandler);
    signal(SIGINT, signalHandler);
    signal(SIGQUIT, signalHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGFPE, signalHandler);
    signal(SIGBUS, signalHandler);
    signal(SIGPIPE, signalHandler);
}

+ (void)installExceptionHandlerAndUpload {
//    [self installExceptionHandler];
//    [self uploadLoginfo];
}


@end

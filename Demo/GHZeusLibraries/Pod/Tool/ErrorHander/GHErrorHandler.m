//
//  GHShake.m
//  GHShake
//
//  Created by 张冠华 on 16/2/14.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHErrorHandler.h"
#import <objc/runtime.h>
#import "GHErrorLog.h"
#import "GHViewModel.h"
#import "TMCache.h"
#import "NSDictionary+GHExtend.h"


static GHErrorHandlerReportType __ghErrorHandlerReportType = GHErrorHandlerReportTypeLog;
void __swizzle(Class c,SEL origSEL,SEL newSEL);

#pragma mark - hook 替换方法

void __swizzle(Class c,SEL origSEL,SEL newSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = nil;
    
    if (!origMethod){
        origMethod = class_getClassMethod(c, origSEL);
        newMethod = class_getClassMethod(c, newSEL);
    }else{
        newMethod = class_getInstanceMethod(c, newSEL);
    }
    
    if (!origMethod||!newMethod) {
        return;
    }
    
    if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}

#pragma mark - shake ViewController

NSString * const GHViewControllerFeedBack = @"__gh_feedback_shake";

@interface UIViewController(shake)

@end

@implementation UIViewController(shake)

- (void)gh_viewDidAppear:(BOOL)animated
{
    [self gh_viewDidAppear:animated];
    
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

- (void)gh_viewWillDisappear:(BOOL)animated
{
    [self gh_viewWillDisappear:animated];
    
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
    
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        NSLog(@"摇一摇～～～～");
        
        UILabel * label_ = [[UILabel alloc] initWithFrame:CGRectMake(.0f, 200.0f, self.view.bounds.size.width, 30.0f)];
        
        label_.backgroundColor = [UIColor redColor];
        
        [self.view addSubview:label_];
        
    }
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        [self.view setBackgroundColor:[UIColor colorWithRed:rand()%255/255.0f
                                                      green:rand()%255/255.0f
                                                       blue:rand()%255/255.0f
                                                      alpha:1.0f]];
    }
}

-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        NSLog(@"Shake Cancelled");
    }
}

@end

#pragma mark - GHErrorHandler
@interface GHErrorHandler()


@end
@implementation GHErrorHandler
GH_SYNTHESIZE_SINGLETON_FOR_CLASS_M(ErrorHandler)


- (void)validateErrorTypeWithGHErrorHandlerReportType:(GHErrorHandlerReportType)type feedBackEmailAddress:(NSString *)address feedBackServerHost:(NSString *)host
{
    __ghErrorHandlerReportType = type;
    
    //不支持IOS7
    if ([[[UIDevice currentDevice] systemVersion]floatValue]<7.0) {
        return;
    }
    // 保存设备信息
//    [self saveDeviceInfo];
    
    
    if (__ghErrorHandlerReportType == GHErrorHandlerReportTypeLog) {
        return;
    }else if(__ghErrorHandlerReportType == GHErrorHandlerReportTypeLog) {
        [GHErrorLog installExceptionHandler];
        return;
    }else if(__ghErrorHandlerReportType == GHErrorHandlerReportTypeCompatibilityMode) {
        [GHErrorLog installExceptionHandler];
    }else if(type == GHErrorHandlerReportTypeSaveTXTAndUploadToServer){
        [GHErrorLog installExceptionHandlerAndUpload];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //执行hook`
        __swizzle([UIViewController class],@selector(viewDidAppear:),@selector(gh_viewDidAppear:));
        __swizzle([UIViewController class],@selector(viewWillDisappear:),@selector(gh_viewWillDisappear:));
    });
}



@end

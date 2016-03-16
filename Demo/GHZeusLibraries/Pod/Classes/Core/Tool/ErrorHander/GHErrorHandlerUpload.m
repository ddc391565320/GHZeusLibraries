//
//  GHErrorHandlerUpload.m
//  GHZeusLibraries
//
//  Created by CollegePre on 16/3/2.
//  Copyright © 2016年 张冠华. All rights reserved.
//
#import <objc/runtime.h>
#import "GHErrorLog.h"
#import "GHViewModel.h"
#import "TMCache.h"
#import "NSDictionary+GHExtend.h"

// 保存设备信息Key值
NSString *const DeviceAndAppInfoKey = @"DeviceAndAppInfoKey";
// 保存error信息Key值
NSString *const ErrorDetailInfoKey = @"ErrorDetailInfoKey";
// 保存loginfo文件夹名称
NSString *const ErrorInfoFileNameKey = @"LogFile";

#define LogTxtInfosavePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:ErrorInfoFileNameKey]
#import "GHErrorHandlerUpload.h"

@interface GHErrorHandlerUpload()
@property (nonatomic,strong) GHViewModel  *viewModel;
// 文件管理器
@property (strong, nonatomic) NSFileManager *fileManager;
@end

@implementation GHErrorHandlerUpload

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

/**
 *  记录crash日志并将log信息上传到服务器
 *
 *  @param type      记录类型
 *  @param URLString 服务上传URL路径
 */
- (void)validateErrorTypeWithGHErrorHandlerReportType:(GHErrorHandlerReportType)type txtLogFeedBackURLString:(NSString *)URLString
{
    //不支持IOS7
    if ([[[UIDevice currentDevice] systemVersion]floatValue]<7.0) {
        return;
    }
    // 上传日志信息
    NSDictionary *errorinfo = [self exportErrorinfo];
    if (errorinfo) {
        [self exportTxtErrorInfo:errorinfo URLString:URLString];
    }
    
    // 保存设备信息
    [self saveDeviceInfo];
    
    if (type == GHErrorHandlerReportTypeLog) {
        return;
    }else if(type == GHErrorHandlerReportTypeLog) {
        [GHErrorLog installExceptionHandler];
        return;
    }else if(type == GHErrorHandlerReportTypeCompatibilityMode) {
        [GHErrorLog installExceptionHandler];
    }else if(type == GHErrorHandlerReportTypeSaveTXTAndUploadToServer) {
        [GHErrorLog installExceptionHandler];
    }
}

/**
 *  导出日志信息生成txt文本并上传服务器
 *
 *  @param errorInfo 错误信息字典
 *  @param URLString URL路径
 */
- (void)exportTxtErrorInfo:(NSDictionary *)errorInfo URLString:(NSString *)URLString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH-mm-ss";
    NSString *dateString = [fmt stringFromDate:date];
    
    NSDictionary *deviceInfo = errorInfo[@"deviceInfo"];
    NSString *appName = deviceInfo[@"appName"];
    NSString *username = deviceInfo[@"username"];
    
    NSString *fileName =@"";
    if (username.isNoEmpty) { // 文本命名规则
        fileName = [NSString stringWithFormat:@"%@%@%@.txt",appName,username,dateString];
    }else{
        fileName = [NSString stringWithFormat:@"%@%@.txt",appName,dateString];
    }
    
    if (![self.fileManager fileExistsAtPath:LogTxtInfosavePath]) { // 检查保存txt文本的文件夹路径是否存在
        BOOL isSuc = [self.fileManager createDirectoryAtPath:LogTxtInfosavePath withIntermediateDirectories:NO attributes:nil error:nil];
        if (isSuc) {
            NSString *txtPath = [LogTxtInfosavePath stringByAppendingPathComponent:fileName];
            BOOL isWriteSuc = [errorInfo writeToFile:txtPath atomically:YES];
            if (isWriteSuc) { // 写入txt成功
                NSLog(@"写入成功");
                [userDefaults removeObjectForKey:ErrorDetailInfoKey];
                
                // 上传log信息
                [self uploadLoginfoURLString:URLString errorInfo:errorInfo];
            }else{
                NSLog(@"写入失败");
            }
        }else{
            NSLog(@"创建filePath失败");
        }
    } else{ // 已存在保存路径
        NSString *txtPath = [LogTxtInfosavePath stringByAppendingPathComponent:fileName];
        BOOL isWriteSuc = [errorInfo writeToFile:txtPath atomically:YES];
        if (isWriteSuc) {
            NSLog(@"写入成功");
            // 上传log信息
            [self uploadLoginfoURLString:URLString errorInfo:errorInfo];
        }else{
            NSLog(@"写入失败");
        }
    }
}

/**
 *  txt上传到服务器
 *
 *  @param URLString URL路径
 *  @param errorinfo 错误信息字典
 */
- (void)uploadLoginfoURLString:(NSString *)URLString errorInfo:(NSDictionary *)errorinfo

{
    NSArray *subPaths = [self.fileManager subpathsAtPath:LogTxtInfosavePath];
    if (subPaths.count) {
        for (NSString *subPath in subPaths) {
            if ([[subPath pathExtension] isEqualToString:@"txt"]) { // 所有txt的文本都上传
                [self uploginfoWithFileName:subPath errorInfo:errorinfo URLString:URLString];
            }
        }
    }
}


/**
 *  根据文件名上传到服务器
 *
 *  @param fileName  文件名
 *  @param errorinfo 错误信息字典
 *  @param URLString URL路径
 */
- (void)uploginfoWithFileName:(NSString *)fileName errorInfo:(NSDictionary *)errorinfo  URLString:(NSString *)URLString
{
    NSString *filePath = [LogTxtInfosavePath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    self.viewModel = [GHViewModel shareViewModel];
    
    GHUploadSessionTask * dTask_ = [GHUploadSessionTask setFileData:data
                                                           formName:@"txtFile"
                                                           fileName:filePath
                                                           mimeType:@"text/plain"
                                                          urlString:URLString delegate:self.viewModel];
    
    [self.viewModel uploadTask:dTask_ progress:^(NSProgress *downloadProgress)
     {
         NSLog(@"%lld",downloadProgress.completedUnitCount);
     } Block:^(GHSessionTask *session, NSError *error){
         if (!error) {
             NSLog(@"上传成功");
             [self.fileManager removeItemAtPath:filePath error:nil];
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             [userDefaults removeObjectForKey:ErrorDetailInfoKey];
         }else{
             if (error.code == 1) {
                 NSLog(@"上传成功");
                 [self.fileManager removeItemAtPath:filePath error:nil];
                 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                 [userDefaults removeObjectForKey:ErrorDetailInfoKey];
                 
             }else {
                 NSLog(@"上传失败--%@",error);
             }
         }
     }];
}

/**
 *  根据数组上传文件
 *
 *  未实现
 */
- (void)uploginfoWithFileName:(NSArray *)FileDats ForNames:(NSArray *)ForNames FileNames:(NSArray *)fileNames mimeTypes:(NSArray *)mimeTypes errorInfo:(NSDictionary *)errorinfo  URLString:(NSString *)URLString
{
    self.viewModel = [GHViewModel shareViewModel];
    
    GHUploadSessionTask * dTask_ = [GHUploadSessionTask  setFileDats:fileNames ForNames:ForNames FileNames:fileNames mimeTypes:mimeTypes urlString:URLString delegate:self.viewModel];
    
    [self.viewModel uploadTask:dTask_ progress:^(NSProgress *downloadProgress)
     {
         NSLog(@"%lld",downloadProgress.completedUnitCount);
     } Block:^(GHSessionTask *session, NSError *error)
     {
         NSLog(@"Error:%@",error);
     }];
}



/**
 *  到处错误日志字典信息
 */
- (NSDictionary *)exportErrorinfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *deviceinfo =  [userDefaults valueForKey:DeviceAndAppInfoKey];
    NSDictionary *errorinfo =  [userDefaults valueForKey:ErrorDetailInfoKey];
    if (deviceinfo.isNoEmpty && errorinfo.isNoEmpty) {
        NSDictionary *loginfo = @{@"deviceInfo":deviceinfo,@"errorInfo":errorinfo};
        return loginfo;
    }else{
        return nil;
    }
}

/**
 *  保存设备信息字典 设备类型  设备ID 设备版本号  软件版本号  app名称
 */
- (void)saveDeviceInfo{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app版本号
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    NSString *appVersion = [NSString stringWithFormat:@"%@-%@",appCurVersion,appCurVersionNum];
    
    NSString *deviceId = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSString *deviceType = [[UIDevice currentDevice] model];
    NSString *deviceVersion = [UIDevice currentDevice].systemVersion;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [userDefaults valueForKey:@"Account"];
    NSString *remark = [userDefaults valueForKey:@"Password"];
    
    NSDictionary *deviceInfo;
    if (username.isNoEmpty &&remark.isNoEmpty) {
        deviceInfo = @{@"deviceID":deviceId,@"deviceType":deviceType,@"deviceVersion":deviceVersion,@"appVersion":appVersion,@"appName":app_Name,@"username":username,@"remark":remark};
    }else{
        deviceInfo =@{@"deviceID":deviceId,@"deviceType":deviceType,@"deviceVersion":deviceVersion,@"appVersion":appVersion,@"appName":app_Name};
    }
    
    [userDefaults setObject:deviceInfo forKey:DeviceAndAppInfoKey];
}

@end

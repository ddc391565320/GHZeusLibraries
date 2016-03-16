//
//  GHUploadSessionTask.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHUploadSessionTask.h"
#import "GHConst.h"

@implementation GHUploadSessionTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadInit];
    }
    return self;
}

- (void)loadInit
{
    self.cached = YES;
}

+ (id)setFileName:(NSString *)fileName
         formName:(NSString *)formName
         mimeType:(NSString *)mimeType
        urlString:(NSString *)urlString delegate:(id<SessionTaskDelegate>)delegate
{
    GHUploadSessionTask * task = [[GHUploadSessionTask alloc] init];
    task.formName = formName;
    task.fileName = fileName;
    task.mimeType = mimeType;
    task.fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
    task.urlString = urlString;
    task.delegate = delegate;
    return task;
}

+ (id)setFileData:(NSData *)fileData
         formName:(NSString *)formName
         fileName:(NSString *)fileName
         mimeType:(NSString *)mimeType
        urlString:(NSString *)urlString delegate:(id<SessionTaskDelegate>)delegate
{
    GHUploadSessionTask * task = [[GHUploadSessionTask alloc] init];
    task.fileData = fileData;
    task.formName = formName;
    task.fileName = fileName;
    task.mimeType = mimeType;
    task.urlString = urlString;
    task.delegate = delegate;
    return task;
}

/**
 *  多文件上传
 */

+ (id)setFileDats:(NSArray *)fileDatas
         ForNames:(NSArray *)formNames
        FileNames:(NSArray *)fileNames
        mimeTypes:(NSArray *)mimeTypes
        urlString:(NSString *)urlString delegate:(id<SessionTaskDelegate>)delegate
{
    GHUploadSessionTask * task = [[GHUploadSessionTask alloc] init];
    task.fileDatas = fileDatas;
    task.formNames = formNames;
    task.fileNames = fileNames;
    task.mimeTypes = mimeTypes;
    task.urlString = urlString;
    task.delegate = delegate;
    return task;
}

+ (id)taskForFileUrl:(NSString *)urlString
              savePath:(NSString *)savePath
              fileName:(NSString *)fileName sessisonDelegate:(id<SessionTaskDelegate>)delegate
{
    GHUploadSessionTask * task = [[GHUploadSessionTask alloc] init];
    
    task.urlString = urlString;
    task.savePath = savePath;
    task.fileName = fileName;
    task.delegate = delegate;
    
    return task;
}

- (void)dealloc
{
//    GHLog(@"%@释放了",self);
}

@end

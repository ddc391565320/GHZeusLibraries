//
//  GHUploadSessionTask.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHSessionTask.h"

@interface GHUploadSessionTask : GHSessionTask

@property(nonatomic, copy) NSString *mimeType;
@property(nonatomic, copy) NSString *fileName;
@property(nonatomic, copy) NSString *formName;
@property(nonatomic, strong) NSData *fileData;
@property(nonatomic, strong) NSURL *fileURL; //根据fileName生成

@property(nonatomic, strong) NSArray *fileDatas;
@property(nonatomic, strong) NSArray *formNames;
@property(nonatomic, strong) NSArray *fileNames;
@property(nonatomic, strong) NSArray *mimeTypes;

@property(nonatomic, copy)  NSString *urlString;
@property(nonatomic, copy)  NSString *savePath;


/**
 *  文件参数设置
 */
+ (id)setFileName:(NSString *)fileName
           formName:(NSString *)formName
           mimeType:(NSString *)mimeType urlString:(NSString *)urlString delegate:(id<SessionTaskDelegate>)delegate;

+ (id)setFileData:(NSData *)fileData
           formName:(NSString *)formName
           fileName:(NSString *)fileName
           mimeType:(NSString *)mimeType urlString:(NSString *)urlString delegate:(id<SessionTaskDelegate>)delegate;

/**
 *  多文件上传
 */

+ (id)setFileDats:(NSArray *)fileDatas
           ForNames:(NSArray *)formNames
          FileNames:(NSArray *)fileNames
          mimeTypes:(NSArray *)mimeTypes urlString:(NSString *)urlString delegate:(id<SessionTaskDelegate>)delegate;

/**
 *  文件下载
 */

+ (id)taskForFileUrl:(NSString *)urlString
              savePath:(NSString *)savePath
            fileName:(NSString *)fileName
    sessisonDelegate:(id<SessionTaskDelegate>)delegate;

@end

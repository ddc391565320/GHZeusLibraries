//
//  GHNewwork.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHNetwork.h"
#import "GHConst.h"
#import "NSDictionary+GHExtend.h"
#import "GHUploadSessionTask.h"
#import "AFNetworking.h"
#import "TMCache.h"
#import "NSString+GHExtend.h"

@interface GHNetwork ()

@property(nonatomic, strong) NSMutableDictionary *defaultFields;   //默认添加的请求头，以便还原
@property(nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property(nonatomic, strong) NSMutableDictionary *dataTasks;    //任务集合
@end

@implementation GHNetwork
#pragma mark - Init
GH_SYNTHESIZE_SINGLETON_FOR_CLASS_M(Network)

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sessionManager = [AFHTTPSessionManager manager];
            _dataTasks = [NSMutableDictionary dictionary];
            _defaultFields = [NSMutableDictionary dictionary];
            
            [self.defaultFields addEntriesFromDictionary:[GHNetworkConfig sharedConfig].defaultHeaderFields];
        });
    }
    return self;
}

- (void)httpSetup:(GHSessionTask *)sessionTask
{
    //1.重置自身数据
    [self rest];
    
    //2.配置新数据
    /**
     *  httpRequestFields
     */
    NSDictionary *fields = sessionTask.httpRequestFields;
    if (fields.isNoEmpty) {
        [fields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //3.清空原任务数据
    [sessionTask restAllOutput];
    [sessionTask absoluteURL];  //刷新absoluteURL
}

- (void)rest
{
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.defaultFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

#pragma mark- Action
/**
 *  发送GET/POST任务
 */
- (void)send:(GHSessionTask *)sessionTask
{
    NSString *path = sessionTask.path;
    GHAssertNoReturn(!path.isNoEmpty, @"path nil")
    GHAssertNoReturn(sessionTask.state != SessionTaskStateRunable, @"task has run already")
    
    //启动前还原配置
    [self httpSetup:sessionTask];
    
    if ([GHNetworkConfig sharedConfig].reachable) {
        NSString *method = sessionTask.method?:@"GET";
        if ([method caseInsensitiveCompare:@"GET"] == NSOrderedSame) {
            [self GET:sessionTask];
        }else if ([method caseInsensitiveCompare:@"POST"] == NSOrderedSame) {
            [self POST:sessionTask];
        }
    }else {
        [sessionTask noReach];
    }
}

/**
 *  GET
 */
- (void)GET:(GHSessionTask *)sessionTask
{
    /**************启动任务**************/
    BOOL pathSchema = sessionTask.pathkeys.isNoEmpty;
    id params = pathSchema?nil:sessionTask.params;
    NSString *urlstring = pathSchema?sessionTask.absoluteURL:sessionTask.absoluteURL.allPath;
    NSURLSessionDataTask *dataTask = [self.sessionManager GET:urlstring parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self sucess:sessionTask response:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self fail:sessionTask error:error];
    }];
    [dataTask resume];
    [self.dataTasks setObject:dataTask forKey:sessionTask.cacheKey];
    [sessionTask startSession];
}

/**
 *  POST
 */
- (void)POST:(GHSessionTask *)sessionTask
{
    /**************启动任务**************/
    NSString *urlstring = sessionTask.absoluteURL.allPath;
    self.sessionManager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/plain", @"text/html",@"text/json", @"application/json",nil];
    NSURLSessionDataTask *dataTask = [self.sessionManager POST:urlstring parameters:sessionTask.params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self sucess:sessionTask response:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self fail:sessionTask error:error];
    }];
    
    //开始请求
    [dataTask resume];
    [self.dataTasks setObject:dataTask forKey:sessionTask.cacheKey];
    [sessionTask startSession];
}

/**
 *  upload
 */
- (void)upload:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
{
    //    if (sessionTask.fileName.isEmpty || sessionTask.formName.isEmpty) return; AFN已经做了
    GHAssertNoReturn(sessionTask.state != SessionTaskStateRunable, @"task has run already")

    //启动前参数配置
    [self httpSetup:sessionTask];
    self.sessionManager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/plain", @"text/html",@"text/json", @"application/json",nil];
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:sessionTask.urlString parameters:sessionTask.params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (sessionTask.fileData) {
            [formData appendPartWithFileData:sessionTask.fileData name:sessionTask.formName fileName:sessionTask.fileName mimeType:sessionTask.mimeType];
        }else if (sessionTask.fileDatas.count>0) {
            if (sessionTask.fileDatas.count==sessionTask.fileNames.count==sessionTask.fileNames.count==sessionTask.mimeTypes.count) {
                for (int i=0; i<sessionTask.fileDatas.count; i++) {
                    [formData appendPartWithFileData:[sessionTask.fileDatas objectAtIndex:i]
                                                name:[sessionTask.formNames objectAtIndex:i]
                                            fileName:[sessionTask.fileNames objectAtIndex:i]
                                            mimeType:[sessionTask.mimeTypes objectAtIndex:i]];
                }
            }else {
                GHLog(@"上传策略不合法");
                return;
            }
            
        }else {
            [formData appendPartWithFileURL:sessionTask.fileURL name:sessionTask.formName fileName:sessionTask.fileName mimeType:sessionTask.mimeType error:nil];
        }
    } error:nil];
    
    NSURLSessionUploadTask *dataTask = [self.sessionManager uploadTaskWithStreamedRequest:request progress:uploadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [self fail:sessionTask error:error];
        }else {
            [self sucess:sessionTask response:responseObject];
        }
    }];
    
    //开始请求
    [dataTask resume];
    [self.dataTasks setObject:dataTask forKey:sessionTask.cacheKey];
    [sessionTask startSession];

}

- (void)download:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *downloadProgress))uploadProgressBlock
{
    GHAssertNoReturn(sessionTask.state != SessionTaskStateRunable, @"task has run already")
    
    //启动前参数配置
    [self httpSetup:sessionTask];
    
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:sessionTask.urlString parameters:sessionTask.params error:nil];
    
    NSURLSessionDownloadTask *dataTask = [self.sessionManager downloadTaskWithRequest:request
                                                                           progress:uploadProgressBlock
                                                                        destination:^NSURL *(NSURL *targetPath, NSURLResponse *response){
                                                                            NSString *downloadPath_ = [sessionTask.savePath stringByAppendingPathComponent:sessionTask.fileName];

                                                                            NSURL *fileURL = [NSURL fileURLWithPath:downloadPath_];
                                                                            
                                                                            return fileURL;
                                                                            
                                                                        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
    {
        if (error) {
            [self fail:sessionTask error:error];
        }else {
            sessionTask.downloadDataPath = [filePath absoluteString];
            
            [self sucess:sessionTask response:nil];
        }
    }];
    
    //开始请求
    [dataTask resume];
    [self.dataTasks setObject:dataTask forKey:sessionTask.cacheKey];
    [sessionTask startSession];
}


/**
 *  取消任务
 */
- (void)cancel:(GHSessionTask *)sessionTask
{
    NSURLSessionTask *task = [self.dataTasks objectForKey:sessionTask.cacheKey];
    if(task) [task cancel];
}

#pragma mark - CallBack
/**
 *  成功后的默认处理
 */
- (void)sucess:(GHSessionTask *)sessionTask response:(id)responseObject
{
    //移掉该任务
    [self.dataTasks removeObjectForKey:sessionTask.cacheKey];
    
    //配置输出
    [sessionTask responseSessionWithResponseObject:responseObject error:nil];
}

/**
 *  失败后的默认处理
 */
- (void)fail:(GHSessionTask *)sessionTask error:(NSError *)error
{
    GHLog(@"%@",error);
    [self.dataTasks removeObjectForKey:sessionTask.cacheKey];
    [sessionTask responseSessionWithResponseObject:nil error:error];
}



@end

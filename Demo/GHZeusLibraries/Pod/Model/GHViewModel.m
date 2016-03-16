//
//  GHViewModel.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHViewModel.h"
#import "GHUploadSessionTask.h"
#import "NSObject+GHExtend.h"

@interface GHViewModel ()
@property (nonatomic,strong) NSMutableDictionary  *blockManage;
@end

@implementation GHViewModel

#pragma mark - Init
+ (instancetype)viewModelWithDelegate:(id<HZViewModelDelegate>)delegate
{
    GHViewModel *viewModel = [[self alloc] init];
    viewModel.delegate = delegate;
    return viewModel;
}

+ (instancetype)shareViewModel
{
    GHViewModel *viewModel = [[self alloc] init];
    viewModel.blockManage = [[NSMutableDictionary alloc] init];
    return viewModel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadViewModel];
    }
    return self;
}

- (void)loadViewModel {}
- (void)loadDataWithTask:(GHSessionTask *)task type:(NSString *)type {
}
- (void)requestFailWithTask:(GHSessionTask *)task type:(NSString *)type {}

- (void)saveBlock:(void (^)(GHSessionTask *, NSError *error))block hashKey:(NSString *)hash
{
    if (self.blockManage) {
        [self.blockManage setValue:block forKey:hash];
    }
}

#pragma mark - Network
- (void)sendTask:(GHSessionTask *)sessionTask Block:(void (^)(GHSessionTask *, NSError *error))viewModelBlock
{
    [self saveBlock:viewModelBlock hashKey:GH_INT_STRING((int)[sessionTask hash])];
    [[GHNetwork sharedNetwork] send:sessionTask];
}

- (void)uploadTask:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *))uploadProgressBlock Block:(void (^)(GHSessionTask *, NSError *error))viewModelBlock
{
    [self saveBlock:viewModelBlock hashKey:GH_INT_STRING((int)[sessionTask hash])];
    return [[GHNetwork sharedNetwork] upload:sessionTask progress:uploadProgressBlock];
}

- (void)cancelTask:(GHSessionTask *)sessionTask
{
    [[GHNetwork sharedNetwork] cancel:sessionTask];
}

- (void)downloadTask:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock Block:(void (^)(GHSessionTask *, NSError *error))viewModelBlock
{
    [self saveBlock:viewModelBlock hashKey:GH_INT_STRING((int)[sessionTask hash])];
    return [[GHNetwork sharedNetwork] download:sessionTask progress:uploadProgressBlock];
}

#pragma mark - SessionTaskDelegate
/**
 *  主要实现了回调
 */
- (void)taskConnected:(GHSessionTask *)task
{
    if (task.succeed) {
        [self loadDataWithTask:task type:task.requestType];
    }else {
        [self requestFailWithTask:task type:task.requestType];
    }
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(viewModelConnetedNotifyForTask:type:)]) {
        [self.delegate viewModelConnetedNotifyForTask:task type:task.requestType];
    }else {
        if (self.blockManage.isNoEmpty) {
            if ([self.blockManage objectForKey:GH_INT_STRING((int)[task hash])]) {
                void (^callBackBlcok)(GHSessionTask *, NSError *error) = [self.blockManage objectForKey:GH_INT_STRING((int)[task hash])];
                callBackBlcok(task,nil);
            }
        }
    }
}

- (void)taskSending:(GHSessionTask *)task
{
    if (task.cacheSuccess) [self loadDataWithTask:task type:task.requestType];
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(viewModelSendingNotifyForTask:type:)]) {
        [self.delegate viewModelSendingNotifyForTask:task type:task.requestType];
    }else {
        //预留
    }
}

- (void)taskLosted:(GHSessionTask *)task
{
    if (task.cacheSuccess) {
        [self loadDataWithTask:task type:task.requestType];
    }else if(task.cacheFail) {
        [self requestFailWithTask:task type:task.requestType];
    }
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(viewModelLostedNotifyForTask:type:)]) {
        [self.delegate viewModelLostedNotifyForTask:task type:task.requestType];
    }else {
        if (self.blockManage.isNoEmpty) {
            if ([self.blockManage objectForKey:GH_INT_STRING((int)[task hash])]) {
                void (^callBackBlcok)(GHSessionTask *, NSError *error) = [self.blockManage objectForKey:GH_INT_STRING((int)[task hash])];
                callBackBlcok(task,task.error);
            }
        }
        
    }
}



@end

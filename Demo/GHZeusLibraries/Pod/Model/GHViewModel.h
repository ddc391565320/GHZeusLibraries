//
//  GHViewModel.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHNetwork.h"

@class GHViewModel;
@protocol HZViewModelDelegate<NSObject>

/**
 *  最终的请求结果到来调用(成功或失败)
 */
- (void)viewModelConnetedNotifyForTask:(GHSessionTask *)task type:(NSString *)type;

/**
 *  请求过程中调用(有缓存,无缓存,不尝试导入缓存,取消)
 */
- (void)viewModelSendingNotifyForTask:(GHSessionTask *)task type:(NSString *)type;

/**
 *  无网下调用(有缓存，无缓存，不尝试导入缓存)
 */
- (void)viewModelLostedNotifyForTask:(GHSessionTask *)task type:(NSString *)type;

@end

@interface GHViewModel : NSObject<SessionTaskDelegate>

@property(nonatomic, weak) id<HZViewModelDelegate> delegate;

+ (instancetype)viewModelWithDelegate:(id<HZViewModelDelegate>)delegate;

+ (instancetype)shareViewModel;

/**********发送请求**********/
- (void)sendTask:(GHSessionTask *)sessionTask Block:(void (^)(GHSessionTask *task,NSError *error))viewModelBlock;   //GET或POST
- (void)uploadTask:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock Block:(void (^)(GHSessionTask *task,NSError *error))viewModelBlock;   //upload
- (void)cancelTask:(GHSessionTask *)sessionTask;
- (void)downloadTask:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock Block:(void (^)(GHSessionTask *task,NSError *error))viewModelBlock; //download

/**********子类重写回调**********/
/**
 *  初始化ViewModel,可在这里初始化task
 */
- (void)loadViewModel;

/**
 *  加载数据模型，数据返回时会调用(请求数据，缓存数据)
 *  type:即task的任务标识，requestType
 */
- (void)loadDataWithTask:(GHSessionTask *)task type:(NSString *)type;

/**
 *  做一些失败处理,如页数减一,请求失败或者无网无缓存时调用
 */
- (void)requestFailWithTask:(GHSessionTask *)task type:(NSString *)type;



@end

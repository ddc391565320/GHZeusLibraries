//
//  GHNewwork.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHNetworkConfig.h"
#import "GHSessionTask.h"
#import "GHUploadSessionTask.h"
#import "GHMacros.h"

@class GHNetwork;
@interface GHNetwork : NSObject

GH_SINGLETON_NAME(Network)

/**
 *  GET或POST
 */
- (void)send:(GHSessionTask *)sessionTask;

/**
 *  上传任务
 */
- (void)upload:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock;

/**
 *  取消
 */
- (void)cancel:(GHSessionTask *)sessionTask;

/**
 *  下载任务
 */

- (void)download:(GHUploadSessionTask *)sessionTask progress:(void (^)(NSProgress *downloadProgress))uploadProgressBlock;


@end

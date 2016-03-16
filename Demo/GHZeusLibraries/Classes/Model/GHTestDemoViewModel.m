//
//  GHTestDemoViewModel.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/24.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHTestDemoViewModel.h"
#import "DatasObj.h"
@implementation GHTestDemoViewModel

- (void)loadViewModel
{
    _testSession=[GHSessionTask taskWithMethod:@"GET"
                             path:@"/subject/recommend/1/2"
                           params:nil
                         delegate:self
                      requestType:@"subject"];
    _testSession.importCacheOnce=NO;
    _testSession.dataClassName = @"GHTestJsonParserDataObjSample";
}

- (void)loadDataWithTask:(GHSessionTask *)task type:(NSString *)type
{
    _TestData = task.responseObj;
}

- (void)requestFailWithTask:(GHSessionTask *)task type:(NSString *)type
{
    _TestData = task.responseObj;
}

@end

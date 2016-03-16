//
//  GHTestDemoViewModel.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/24.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHViewModel.h"
@class DatasObj;
@interface GHTestDemoViewModel : GHViewModel

@property (nonatomic,strong) GHSessionTask  *testSession;
@property (nonatomic,strong) DatasObj       *TestData;

@end

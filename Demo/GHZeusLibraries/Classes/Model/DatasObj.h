//
//  DatasObj.h
//  HZExtend-Demo
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 xzh. All rights reserved.
//

#import "GHModel.h"
#import "SubjectList.h"

@interface DatasObj : GHModel

@property (nonatomic,assign) int code;
@property (nonatomic,strong) SubjectList    *data;

@end

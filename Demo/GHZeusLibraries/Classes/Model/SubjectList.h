//
//  SubjectList.h
//  HZExtend-Demo
//
//  Created by xzh on 16/2/13.
//  Copyright © 2016年 xzh. All rights reserved.
//

#import "GHModel.h"
#import "Pagination.h"
@interface SubjectList : GHModel
@property(nonatomic, strong) NSArray *list;
@property(nonatomic, strong) Pagination *pagination;    //分页模型

@end

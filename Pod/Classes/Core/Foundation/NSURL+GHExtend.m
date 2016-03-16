//
//  NSURL+HZExtend.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "NSURL+GHExtend.h"
#import "NSObject+GHExtend.h"
#import "NSString+GHExtend.h"

@implementation NSURL(GHExtend)

- (NSDictionary *)restDic
{
    return [self.absoluteString queryDic];
}

@end

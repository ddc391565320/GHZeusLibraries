//
//  NSMutableArray+HZExtend.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "NSMutableArray+GHExtend.h"
#import "GHConst.h"

@implementation NSMutableArray(GHExtend)

- (void)safeRemoveObjectAtIndex:(NSInteger)index
{
    if (index >(self.count-1) || index < 0)
    {
        GHLog(@"out of bound");
        return;
    }
    [self removeObjectAtIndex:index];
}

@end

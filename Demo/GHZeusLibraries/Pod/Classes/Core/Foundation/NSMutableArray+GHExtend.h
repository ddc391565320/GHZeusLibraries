//
//  NSMutableArray+HZExtend.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray(GHExtend)

//防止越界崩溃
- (void)safeRemoveObjectAtIndex:(NSInteger)index;

@end

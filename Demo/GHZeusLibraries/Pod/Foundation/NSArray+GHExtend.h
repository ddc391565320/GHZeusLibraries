//
//  GHExtend.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(GHExtend)

//防止越界
- (id)objectAtSafeIndex:(NSInteger)index;

//数字排序
- (NSArray *)sortedWithArray:(NSArray *)numbers;

//倒序数组
- (NSArray *)reverseForArray:(NSArray *)array;

//jsonString
- (NSString *)jsonString;

@end

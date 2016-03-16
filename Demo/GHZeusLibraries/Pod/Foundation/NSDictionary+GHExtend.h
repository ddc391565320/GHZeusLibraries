//
//  NSDictionary+GHExtend.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+GHExtend.h"

@interface NSDictionary(GHExtend)

- (id)objectAtKeyPath:(NSString *)keyPath;

- (id)objectAtKeyPath:(NSString *)path  otherwise:(NSObject *)other;

//查询字符串
- (NSString *)keyValueString;   //返回简单的查询字符串 如:?name=xzh&age=21

//jsonString
- (NSString *)jsonString;

@end

@interface NSMutableDictionary (GHExtend)

/*
 等待扩展
 */

@end

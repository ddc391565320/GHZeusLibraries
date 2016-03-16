//
//  NSString+GHExtend.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+GHExtend.h"

@interface NSString(GHExtend)

- (NSString *)md5;

//字符串相关、变化
- (NSString *)urlEncode;
- (NSString *)urlDecode;
- (NSString *)schema;
- (NSString *)host;
- (NSString *)allPath;
- (NSString *)path;
- (NSString *)keyValues;
- (NSDictionary *)queryDic;


@end

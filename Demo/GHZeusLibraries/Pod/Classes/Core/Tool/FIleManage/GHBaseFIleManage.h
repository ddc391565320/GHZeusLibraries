//
//  GHBaseFIleManage.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/3/2.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHBaseFIleManage : NSObject

/*
 *  获取设备剩余储存空间
 */

+ (long long)FreeDiskSpaceInBytes;

/*
 *  文件是否存在
 */

+ (BOOL)isFileOnPath:(NSString *)path;

/*
 *  文件删除与大小相关SEL
 */

// 根据路径返回目录或文件的大小
+ (double)sizeWithFilePath:(NSString *)path;
// 得到指定目录下的所有文件
+ (NSArray *)getAllFileNames:(NSString *)dirPath;
// 删除指定目录或文件
+ (BOOL)clearCachesWithFilePath:(NSString *)path;
// 清空指定目录下文件
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath;

/*
 * 以下均为沙盒文件夹根路径
 */

+ (NSString *)documentsPath;
+ (NSString *)tempPath;
+ (NSString *)cachePath;
+ (NSString *)libraryPath;

/*
 *  沙盒文件夹二级路经或文件路径
 */

+ (NSString *)documentFilePath:(NSString *)fileName;
+ (NSString *)tempPath:(NSString *)fileName;
+ (NSString *)cacgeFilePath:(NSString *)fileName;
+ (NSString *)libraryFilePath:(NSString *)fileName;

@end

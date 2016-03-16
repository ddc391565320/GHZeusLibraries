//
//  GHBaseFIleManage.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/3/2.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHBaseFIleManage.h"
#include <sys/param.h>
#include <sys/mount.h>

@interface GHBaseFIleManage()
+ (NSFileManager *)shareManage;
@end

@implementation GHBaseFIleManage

+ (NSFileManager *)shareManage
{
    return [NSFileManager defaultManager];
}

/*
 *  获取设备剩余储存空间
 */

+ (long long)FreeDiskSpaceInBytes
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}

/*
 *  文件是否存在
 */

+ (BOOL)isFileOnPath:(NSString *)path
{
    return [[GHBaseFIleManage shareManage] fileExistsAtPath:path];
}

+ (double)sizeWithFilePath:(NSString *)path{
    // 1.获得文件夹管理者
    NSFileManager *manger = [NSFileManager defaultManager];
    // 2.检测路径的合理性
    BOOL dir = NO;
    BOOL exits = [manger fileExistsAtPath:path isDirectory:&dir];
    if (!exits) return 0;
    // 3.判断是否为文件夹
    if (dir) { // 文件夹, 遍历文件夹里面的所有文件
        // 这个方法能获得这个文件夹下面的所有子路径(直接\间接子路径)
        NSArray *subpaths = [manger subpathsAtPath:path];
        int totalSize = 0;
        for (NSString *subpath in subpaths) {
            NSString *fullsubpath = [path stringByAppendingPathComponent:subpath];
            BOOL dir = NO;
            [manger fileExistsAtPath:fullsubpath isDirectory:&dir];
            if (!dir) { // 子路径是个文件
                NSDictionary *attrs = [manger attributesOfItemAtPath:fullsubpath error:nil];
                totalSize += [attrs[NSFileSize] intValue];
            }
        }
        return totalSize / (1024 * 1024.0);
    } else { // 文件
        NSDictionary *attrs = [manger attributesOfItemAtPath:path error:nil];
        return [attrs[NSFileSize] intValue] / (1024.0 * 1024.0);
    }
}
#pragma mark - 得到指定目录下的所有文件
+ (NSArray *)getAllFileNames:(NSString *)dirPath{
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dirPath error:nil];
    return files;
}
#pragma mark - 删除指定目录或文件
+ (BOOL)clearCachesWithFilePath:(NSString *)path{
    NSFileManager *mgr = [NSFileManager defaultManager];
    return [mgr removeItemAtPath:path error:nil];
}
#pragma mark - 清空指定目录下文件
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath{
    //获得全部文件数组
    NSArray *fileAry =  [GHBaseFIleManage getAllFileNames:dirPath];
    //遍历数组
    BOOL flag = NO;
    for (NSString *fileName in fileAry) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        flag = [GHBaseFIleManage clearCachesWithFilePath:filePath];
        if (!flag)
            break;
    }
    return flag;
}

+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)tempPath
{
    return NSTemporaryDirectory();
}

+ (NSString *)cachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)libraryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)documentFilePath:(NSString *)fileName
{
    return [[GHBaseFIleManage documentsPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)tempPath:(NSString *)fileName
{
    return [[GHBaseFIleManage tempPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)cacgeFilePath:(NSString *)fileName
{
    return [[GHBaseFIleManage cachePath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)libraryFilePath:(NSString *)fileName
{
    return [[GHBaseFIleManage libraryPath] stringByAppendingPathComponent:fileName];
}

@end

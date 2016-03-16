//
//  GHModel.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface GHModel : NSObject

/**
 *  是否存在数据库中
 */
@property(nonatomic, assign, readonly) BOOL isInDB;

/**
 *  主键值,0表示不存在
 */
@property(nonatomic, assign, readonly) NSUInteger primaryKey;

/**
 *  dic->model
 */
+ (instancetype)modelWithDic:(NSDictionary *)dic;

/**
 *  切换成不备份的数据库
 */
+ (void)swtichNormalRoute;

/**
 *  备份的数据库,默认存储数据库
 */
+ (void)swtichImportantRoute;

/**
 *  数据库地址
 */
+ (NSString *)dbPath;

/**
 *  数据库基本操作
 */
+ (void)open;
+ (void)close;
+ (BOOL)executeUpdate:(NSString *)sql withParams:(NSArray *)data;
+ (NSArray *)excuteQuery:(NSString *)sql withParams:(NSArray *)data;
+ (long)longForQuery:(NSString *)sql;

+ (NSArray *)excuteStatement:(NSString *)sql flag:(BOOL)isReturn;   //执行多条语句

/**
 *  元组操作
 */
- (void)safeSave;   //safe代表执行之前先open数据库，执行完毕后再close数据库
- (void)safeDelete;

+ (instancetype)modelWithSql:(NSString *)sql withParameters:(NSArray *)parameters;
+ (NSArray *)findByColumn:(NSString *)column value:(id)value;
+ (NSArray *)findWithSql:(NSString *)sql withParameters:(NSArray *)parameters;
+ (NSArray *)findAll;

- (void)save;
- (void)deleteSelf;
+ (void)deleteAll;

/**
 *  删除数组中的全部元组
 */
+ (void)deleteWithArray:(NSArray *)array;

/**
 *  子类重写
 */
- (void)loadModel;  //初始化配置(成员变量，或数组对象类设置)
- (void)beforeSave;
- (void)afterSave;
- (void)beforeUpdateSelf;
- (void)afterUpdateSelf;
- (void)beforeDeleteSelf;
- (void)afterDeleteSelf;


@end

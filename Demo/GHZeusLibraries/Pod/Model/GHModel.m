//
//  GHModel.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/23.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "GHModel.h"
#import "GHConst.h"
#import "NSObject+GHExtend.h"

#import <objc/runtime.h>
#import "FMDB.h"
#import <sqlite3.h>
#define DBText  @"text"
#define DBInt   @"integer"
#define DBFloat @"real"
#define DBData  @"blob"
#define DBArray @"array"
#define DBObject @"object"
static NSString * kDatabasePath = @"Documents/HzDatabase.db";
static NSMutableDictionary *TABLE_CACHE;   //使用[self TABLE_CACHE]获取
static FMDatabase *DATA_BASE;


@interface GHModel ()
@end

@implementation GHModel

#pragma mark - Init
+ (instancetype)modelWithDic:(NSDictionary *)dic
{
    GHModel *model = [[[self alloc] init] mj_setKeyValues:dic];
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadModel];
    }
    return self;
}

- (void)loadModel {}

#pragma mark - 数据库信息
+ (void)swtichNormalRoute
{
    kDatabasePath = @"Library/Caches/HzDatabase.db";
}

+ (void)swtichImportantRoute
{
    kDatabasePath = @"Documents/HzDatabase.db";
    ;
}

+ (NSString *)dbPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:kDatabasePath];
}

- (NSMutableDictionary *)TABLE_CACHE
{
    if (!TABLE_CACHE) {
        TABLE_CACHE = [NSMutableDictionary dictionary];
    }
    return TABLE_CACHE;
}

+ (BOOL)isOpen
{
    BOOL result = DATA_BASE?YES:NO;
    //    if (!result) HZLog(@"数据库未打开");
    return result;
}

+ (NSString *)tableName
{
    return NSStringFromClass([self class]);
}

- (NSArray *)tableNames
{
    NSArray *tableNames = [[self TABLE_CACHE] objectForKey:@"tableNames"];
    if (!tableNames.isNoEmpty) {
        NSString *sql = @"SELECT * FROM sqlite_master WHERE type = 'table'";
        NSArray *array = [[self class] excuteStatement:sql flag:YES];
        tableNames = [array valueForKey:@"name"]?:@[];
        [[self TABLE_CACHE] setObject:tableNames forKey:@"tableNames"];
    }
    return tableNames;
}

- (BOOL)isTableExist
{
    return [DATA_BASE tableExists:[[self class]tableName]];
}

- (NSArray *)columns
{
    NSArray *columns = [[self TABLE_CACHE] objectForKey:@"columns"];
    if (!columns.isNoEmpty) {
        NSString *sql = [NSString stringWithFormat:@"pragma table_info(%@)",[[self class] tableName]];
        NSArray *results = [[self class] excuteStatement:sql flag:YES];  //返回
        columns = [results valueForKey:@"name"]?:@[];
        
        [[self TABLE_CACHE] setObject:columns forKey:@"columns"];
    }
    
    return columns;
    
}

- (NSArray *)columnsWithoutPK
{
    NSMutableArray *columnsWithoutPK = [NSMutableArray arrayWithArray:[self columns]];
    [columnsWithoutPK removeObjectAtIndex:0];
    return columnsWithoutPK;
}

- (NSArray *)getPropertyList
{
    NSMutableArray *propertyNamesArray = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        NSString * attributes = [self dbTypeConvertFromObjc_property_t:property];
        if(![attributes isEqualToString:DBObject] && ![attributes isEqualToString:DBArray]
           ){
            [propertyNamesArray addObject:[NSString stringWithFormat:@"%@ %@",[NSString stringWithUTF8String:name],attributes]];
        }
    }
    free(properties);
    return propertyNamesArray;
}

- (NSString *)dbTypeConvertFromObjc_property_t:(objc_property_t)property
{
    @synchronized(self){
        char * type = property_copyAttributeValue(property, "T");
        
        switch(type[0]) {
            case 'f' : //float
            case 'd' : //double
            {
                return DBFloat;
            }
                break;
            case 'c':   // char
            case 's' : //short
            case 'i':   // int
            case 'l':   // long
            case 'q' : // long long
            case 'I': // unsigned int
            case 'S': // unsigned short
            case 'L': // unsigned long
            case 'Q' :  // unsigned long long
            case 'B': // BOOL
            {
                return DBInt;
            }
                break;
                
            case '*':   // char *
                break;
                
            case '@' : //ObjC object
                //Handle different clases in here
            {
                NSString *cls = [NSString stringWithUTF8String:type];
                cls = [cls stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                cls = [cls stringByReplacingOccurrencesOfString:@"@" withString:@""];
                cls = [cls stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSString class]]) {
                    return DBText;
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSNumber class]]) {
                    return DBText;
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSDictionary class]] || [NSClassFromString(cls) isSubclassOfClass:[NSMutableDictionary class]]) {
                    return DBObject;
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSArray class]] ||[NSClassFromString(cls) isSubclassOfClass:[NSMutableArray class]] ||
                    [cls hasPrefix:@"NSMutableArray"] ||
                    [cls hasPrefix:@"NSArray"]) {
                    return DBArray;
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSDate class]]) {
                    return DBText;
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[NSData class]]) {
                    return DBData;
                }
                
                if ([NSClassFromString(cls) isSubclassOfClass:[GHModel class]]) {
                    return DBObject;
                }
            }
                break;
        }
        
        return DBText;
    }
}

- (NSArray *)propertyValues
{
    NSMutableArray *values = [NSMutableArray array];
    
    for (NSString *columnName in [self columnsWithoutPK]) {
        id value = [self valueForKey:columnName];
        
        if (value != nil) {
            [values addObject:value];
        } else {
            [values addObject:[NSNull null]];
        }
    }
    return values;
}

#pragma mark - SQL操作
#pragma mark 基本执行

+ (void)open
{
    if (DATA_BASE) return;    //数据库已开启
    
    NSString *dbPath = [NSHomeDirectory() stringByAppendingPathComponent:kDatabasePath];
    DATA_BASE = [FMDatabase databaseWithPath:dbPath];
    [DATA_BASE open];
    GHLog(@"%@",dbPath);
}

+ (void)close
{
    if (!DATA_BASE) return;    //数据库已关闭
    
    [DATA_BASE close];
    DATA_BASE = nil;
}

+ (BOOL)executeUpdate:(NSString *)sql withParams:(NSArray *)data
{
    
    if (!sql.isNoEmpty) {
        NSLog(@"%s SQL语句为空",__FUNCTION__);
        return NO;
    }
    
    BOOL result = NO;
    if (data.isNoEmpty) {
        result = [DATA_BASE executeUpdate:sql withArgumentsInArray:data];
    }
    else
    {
        result = [DATA_BASE executeUpdate:sql];
    }
    
    if (!result) {
        NSLog(@"update 失败 错误信息-----%@",DATA_BASE.lastErrorMessage);
    }
    return result;
}

+ (NSArray *)excuteQuery:(NSString *)sql withParams:(NSArray *)data
{
    return [self excuteQuery:sql withParams:data isModel:NO];
}

+ (NSArray *)excuteQuery:(NSString *)sql withParams:(NSArray *)data isModel:(BOOL)isModel
{
    
    if (!sql.isNoEmpty) {
        NSLog(@"%s SQL语句为空",__FUNCTION__);
        return nil;
    }
    
    FMResultSet *rs = nil;
    NSMutableArray *array = [NSMutableArray array];
    if (data.isNoEmpty)
    {
        rs = [DATA_BASE executeQuery:sql withArgumentsInArray:data];
    }
    else
    {
        rs = [DATA_BASE executeQuery:sql];
    }
    
    if (!rs)
    {
        NSLog(@"sql 查询失败:%@",DATA_BASE.lastErrorMessage);
        return nil;
    }
    
    while ([rs next]) {
        
        NSMutableDictionary *dic = (NSMutableDictionary *)rs.resultDictionary;
        if ([dic objectForKey:@"primarykey"]) {
            [dic removeObjectForKey:@"primarykey"];
        }
        
        if (isModel)
        {
            id obj = [[self alloc] init];
            [obj setValuesForKeysWithDictionary:dic];
            [array addObject:obj];
        }
        else
        {
            [array addObject:dic];
        }
        
    }
    
    return array;
}

+ (NSArray *)excuteStatement:(NSString *)sql flag:(BOOL)isReturn
{
    if (!sql.isNoEmpty)
    {
        GHLog(@"%s sql为空",__FUNCTION__);
        return nil;
    }
    
    NSMutableArray *array = nil;
    FMDBExecuteStatementsCallbackBlock blcok = nil;
    if (isReturn)
    {
        array = [NSMutableArray array];
        blcok = ^int(NSDictionary *resultsDictionary){
            [array addObject:resultsDictionary];
            return SQLITE_OK;
        };
    }
    BOOL result = [DATA_BASE executeStatements:sql withResultBlock:blcok];
    if (!result)
    {
        GHLog(@"sql 批处理失败:%@",DATA_BASE.lastErrorMessage);
        return nil;
    }
    
    return array;
    
}

+ (long)longForQuery:(NSString *)sql
{
    if (!sql.isNoEmpty)
    {
        NSLog(@"%s sql为空",__FUNCTION__);
        return 0;
    }
    
    return [DATA_BASE longForQuery:sql];
}

#pragma mark 元组操作

- (void)createTable
{
    if(!self.isTableExist)
    {
        NSArray *propertyList = [self getPropertyList];
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (primaryKey integer primary key autoincrement, %@)", [[self class] tableName], [propertyList componentsJoinedByString:@","]];
        
        if (![[self class] executeUpdate:sql withParams:nil]) GHLog(@"创建表失败");
        
    }
}

+ (NSUInteger)lastInsertRowId
{
    return (NSUInteger)[DATA_BASE lastInsertRowId];
}

- (void)insert
{
    NSArray *columnsWithoutPK = [self columnsWithoutPK]; //@[name,age]
    NSMutableArray *parameterList = [NSMutableArray arrayWithCapacity:columnsWithoutPK.count];
    
    for (int i=0; i<[columnsWithoutPK count]; i++) {
        [parameterList addObject:@"?"]; //@[?,?];
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) values(%@)", [[self class] tableName], [columnsWithoutPK componentsJoinedByString:@","], [parameterList componentsJoinedByString:@","]];
    
    if (![[self class] executeUpdate:sql withParams:[self propertyValues]]) return;
    
    _isInDB = YES;
    _primaryKey = [[self class] lastInsertRowId];
}

- (void)updateSelf
{
    NSDictionary *data = [self dictionaryWithValuesForKeys:[self columnsWithoutPK]];
    if (![[self class] isOpen] || !data.isNoEmpty) return;
    
    [self beforeUpdateSelf];
    
    NSString *setValues = [[[data allKeys] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE primaryKey = ?", [[self class] tableName], setValues];
    NSArray *parameters = [[data allValues] arrayByAddingObject:@(self.primaryKey)];
    [[self class] executeUpdate:sql withParams:parameters];
    _isInDB = YES;
    
    [self afterUpdateSelf];
}

- (void)deleteSelf
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE primaryKey = ?", [[self class] tableName]];
    [DATA_BASE executeUpdate:sql withArgumentsInArray:@[@(self.primaryKey)]];
    _isInDB = NO;
    _primaryKey = 0;
}

+ (void)deleteAll
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", [[self class] tableName]];
    
    [DATA_BASE executeUpdate:sql withArgumentsInArray:nil];
}

+ (void)deleteWithArray:(NSArray *)array
{
    if (!array.isNoEmpty) return;
    
    NSMutableString *collection = [NSMutableString stringWithString:@"("];
    for (GHModel *model in array) {
        [collection appendFormat:@"%ld,",model.primaryKey];
    }
    [collection deleteCharactersInRange:NSMakeRange(collection.length-1, 1)];
    [collection appendString:@")"];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where primaryKey in %@",[[self class] tableName],collection];
    [DATA_BASE executeUpdate:sql withArgumentsInArray:nil];
}

- (void)save
{
    if (![[self class] isOpen]) return ;
    
    [self createTable];
    [self beforeSave];
    
    if (!_isInDB) {
        [self insert];
    }
    else {
        [self updateSelf];
    }
    
    [self afterSave];
}

- (void)safeSave
{
    if (![[self class] isOpen]) [[self class] open];
    [self save];
    
    [[self class] close];
}

- (void)safeDelete
{
    if (![[self class] isOpen]) [[self class] open];
    [self deleteSelf];
    
    [[self class] close];
}

+ (instancetype)modelWithSql:(NSString *)sql withParameters:(NSArray *)parameters
{
    return [[self findWithSql:sql withParameters:parameters] firstObject];
}

+ (NSArray *)findWithSql:(NSString *)sql withParameters:(NSArray *)parameters
{
    if (![self isOpen]) return nil;
    
    NSArray *results= [self excuteQuery:sql withParams:parameters isModel:YES];
    [results setValue:[NSNumber numberWithBool:YES] forKey:@"isInDB"];
    return results;
}

+ (NSArray *)findByColumn:(NSString *)column value:(id)value
{
    if (!column.isNoEmpty || value == nil) return nil;
    return [self findWithSql:[NSString stringWithFormat:@"SELECT * FROM %@ where %@ = ?",[[self class] tableName],column] withParameters:@[value]];
}

+ (NSArray *)findAll
{
    return [self findWithSql:[NSString stringWithFormat:@"SELECT * FROM %@", [[self class] tableName]] withParameters:nil];
}

#pragma mark - CallBack
- (void)beforeSave{}
- (void)afterSave{}
- (void)beforeUpdateSelf {}
- (void)afterUpdateSelf {}
- (void)beforeDeleteSelf{}
- (void)afterDeleteSelf{}


@end

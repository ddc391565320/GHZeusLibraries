//
//  NSObject.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GHParserModel)

+ (instancetype)GHParser_modelWithJSON:(id)json;

+ (instancetype)GHParser_modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)GHParser_modelSetWithJSON:(id)json;

- (BOOL)GHParser_modelSetWithDictionary:(NSDictionary *)dic;

- (id)GHParser_modelToJSONObject;

- (NSData *)GHParser_modelToJSONData;

- (NSString *)GHParser_modelToJSONString;

- (id)GHParser_modelCopy;

- (void)GHParser_modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)GHParser_modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)GHParser_modelHash;

- (BOOL)GHParser_modelIsEqual:(id)model;

- (NSString *)GHParser_modelDescription;

@end



/**
 Provide some data-model method for NSArray.
 */
@interface NSArray (GHParserModel)

+ (NSArray *)GHParser_modelArrayWithClass:(Class)cls json:(id)json;

@end



/**
 Provide some data-model method for NSDictionary.
 */
@interface NSDictionary (GHParserModel)

+ (NSDictionary *)GHParser_modelDictionaryWithClass:(Class)cls json:(id)json;
@end

@protocol GHParserModel <NSObject>
@optional

+ (NSDictionary *)modelCustomPropertyMapper;

+ (NSDictionary *)modelContainerPropertyGenericClass;

+ (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary;

+ (NSArray *)modelPropertyBlacklist;

+ (NSArray *)modelPropertyWhitelist;

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end


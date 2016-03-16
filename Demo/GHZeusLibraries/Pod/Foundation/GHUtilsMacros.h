//
//  GHUtilsMacros.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef GHUtilsMacros_h
#define GHUtilsMacros_h


#endif /* GHUtilsMacros_h */

//System version utils

#define GH_SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define GH_SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define GH_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define GH_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define GH_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//color快速设置颜色宏函数
#define GH_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define GH_RGB(r,g,b) RGBA(r,g,b,1.0f)

//16->10
#define GH_COLOR_FROM_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//屏幕是否Portrait
#define GH_ISPORTRAIT ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)

#define GH_IS_NIL_OR_NULL(_ref)   (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))

//角度转弧度
#define GH_DEGREES_TO_RADIANS(d) (d * M_PI / 180)

//获取系统时间戳
#define GH_GET_CURENT_TIME [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]

//加载资源图片
#define GH_LOADIMAGE(file,type) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:type]]

//连接单例的字符串和参数
#define GH_SINGLETON_NAME(name) + (instancetype)shared##name;

//int型转换字符串
#define GH_INT_STRING(int_type) [NSString stringWithFormat:@"%d",int_type]

//float型转换字符串
#define GH_FLOAT_STRING(float_type) [NSString stringWithFormat:@"%f",float_type]

//封装单例

#define GH_SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = ［self alloc] init]; \
} \
} \
\
return shared##classname; \
} \
\

#if __has_feature(objc_arc) // ARC

#define GH_SYNTHESIZE_SINGLETON_FOR_CLASS_M(name) \
static id _instance; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
});\
return _instance; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instance; \
}

#else // 非ARC

#define GH_SYNTHESIZE_SINGLETON_FOR_CLASS_M(name) \
static id _instance; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (oneway void)release \
{ \
\
} \
\
- (id)autorelease \
{ \
return _instance; \
} \
\
- (id)retain \
{ \
return _instance; \
} \
\
- (NSUInteger)retainCount \
{ \
return 1; \
} \
\
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instance; \
}

#endif





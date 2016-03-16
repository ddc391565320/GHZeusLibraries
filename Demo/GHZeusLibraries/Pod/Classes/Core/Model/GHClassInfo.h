//
//  GHClassInfo.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, GHEncodingType) {
    GHEncodingTypeMask       = 0xFF, ///< mask of type value
    GHEncodingTypeUnknown    = 0, ///< unknown
    GHEncodingTypeVoid       = 1, ///< void
    GHEncodingTypeBool       = 2, ///< bool
    GHEncodingTypeInt8       = 3, ///< char / BOOL
    GHEncodingTypeUInt8      = 4, ///< unsigned char
    GHEncodingTypeInt16      = 5, ///< short
    GHEncodingTypeUInt16     = 6, ///< unsigned short
    GHEncodingTypeInt32      = 7, ///< int
    GHEncodingTypeUInt32     = 8, ///< unsigned int
    GHEncodingTypeInt64      = 9, ///< long long
    GHEncodingTypeUInt64     = 10, ///< unsigned long long
    GHEncodingTypeFloat      = 11, ///< float
    GHEncodingTypeDouble     = 12, ///< double
    GHEncodingTypeLongDouble = 13, ///< long double
    GHEncodingTypeObject     = 14, ///< id
    GHEncodingTypeClass      = 15, ///< Class
    GHEncodingTypeSEL        = 16, ///< SEL
    GHEncodingTypeBlock      = 17, ///< block
    GHEncodingTypePointer    = 18, ///< void*
    GHEncodingTypeStruct     = 19, ///< struct
    GHEncodingTypeUnion      = 20, ///< union
    GHEncodingTypeCString    = 21, ///< char*
    GHEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    GHEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    GHEncodingTypeQualifierConst  = 1 << 8,  ///< const
    GHEncodingTypeQualifierIn     = 1 << 9,  ///< in
    GHEncodingTypeQualifierInout  = 1 << 10, ///< inout
    GHEncodingTypeQualifierOut    = 1 << 11, ///< out
    GHEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    GHEncodingTypeQualifierByref  = 1 << 13, ///< byref
    GHEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    GHEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    GHEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    GHEncodingTypePropertyCopy         = 1 << 17, ///< copy
    GHEncodingTypePropertyRetain       = 1 << 18, ///< retain
    GHEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    GHEncodingTypePropertyWeak         = 1 << 20, ///< weak
    GHEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    GHEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    GHEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};


GHEncodingType GHEncodingGetType(const char *typeEncoding);


@interface GHClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) ptrdiff_t offset;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) GHEncodingType type;


- (instancetype)initWithIvar:(Ivar)ivar;
@end


@interface GHClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) SEL sel;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;
@property (nonatomic, strong, readonly) NSArray *argumentTypeEncodings;

- (instancetype)initWithMethod:(Method)method;
@end

@interface GHClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) GHEncodingType type;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *ivarName;
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, strong, readonly) NSString *getter;
@property (nonatomic, strong, readonly) NSString *setter;

- (instancetype)initWithProperty:(objc_property_t)property;
@end

@interface GHClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls;      ///< class object
@property (nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, assign, readonly) BOOL isMeta;
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nonatomic, strong, readonly) GHClassInfo *superClassInfo; ///< super class's class info
@property (nonatomic, strong, readonly) NSDictionary *ivarInfos;     ///< key:NSString(ivar),     value:GHClassIvarInfo
@property (nonatomic, strong, readonly) NSDictionary *methodInfos;   ///< key:NSString(selector), value:GHClassMethodInfo
@property (nonatomic, strong, readonly) NSDictionary *propertyInfos; ///< key:NSString(property), value:GHClassPropertyInfo

- (void)setNeedUpdate;

+ (instancetype)classInfoWithClass:(Class)cls;

+ (instancetype)classInfoWithClassName:(NSString *)className;

@end

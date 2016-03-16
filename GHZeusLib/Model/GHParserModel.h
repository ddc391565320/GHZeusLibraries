//
//  GHParserModel.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#ifndef GHParserModel_h
#define GHParserModel_h


#endif /* GHParserModel_h */

#import <Foundation/Foundation.h>

#if __has_include(<GHParserModel/GHParserModel.h>)
FOUNDATION_EXPORT double GHParserModelVersionNumber;
FOUNDATION_EXPORT const unsigned char GHParserModelVersionString[];
#import <GHParserModel/NSObject+GHParserModel.h>
#import <GHParserModel/GHClassInfo.h>
#else
#import "NSObject+GHParserModel.h"
#import "GHClassInfo.h"
#endif

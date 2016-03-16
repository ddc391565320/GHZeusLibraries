//
//  GHMacros.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#ifndef GHMacros_h
#define GHMacros_h


#endif /* GHMacros_h */

#import <Foundation/Foundation.h>

#if __has_include(<GHMacros/GHMacros.h>)
#import <GHMacros/GHConst.h>
#import <GHMacros/GHPathMacros.h>
#import <GHMacros/GHUtilsMacros.h>
#else
#import "GHConst.h"
#import "GHPathMacros.h"
#import "GHUtilsMacros.h"
#endif
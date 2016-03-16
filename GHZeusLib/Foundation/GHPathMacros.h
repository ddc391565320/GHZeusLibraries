//
//  GHPathMacros.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#ifndef GHPathMacros_h
#define GHPathMacros_h


#endif /* GHPathMacros_h */

#define GHPathTemp                   NSTemporaryDirectory()
#define GHPathDocument               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define GHPathCache                  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

/*  设置后再开放，此处不知文件名

#define GHPathSearch                 [GHPathDocument stringByAppendingPathComponent:@"??.plist"]
#define GHPathMagazine               [GHPathDocument stringByAppendingPathComponent:@"??"]
#define GHPathDownloadedMgzs         [GHPathMagazine stringByAppendingPathComponent:@"??.db"]

*/
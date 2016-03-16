//
//  GHConst.h
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG  // 调试状态
// 打开LOG功能
#define GHLog(...) NSLog(__VA_ARGS__)
#else // 发布状态
// 关闭LOG功能
#define GHLog(...)
#endif

#define GHAssertNoReturn(condition, msg) \
if (condition) {\
GHLog(@"%@",msg);\
return;\
}

#define GHAssertReturn(condition, msg, returnValue) \
if (condition) {\
GHLog(@"%@",msg);\
return returnValue;\
}

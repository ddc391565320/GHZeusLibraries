//
//  GHExtend.m
//  GHZeusLibraries
//
//  Created by 张冠华 on 16/2/19.
//  Copyright © 2016年 张冠华. All rights reserved.
//

#import "NSArray+GHExtend.h"
#import "GHConst.h"

@implementation NSArray(GHExtend)

- (id)objectAtSafeIndex:(NSInteger)index
{
    if (index >(self.count-1) || index < 0)
    {
        GHLog(@"out of bound");
        return nil;
    }
    
    return [self objectAtIndex:index];
}

- (NSArray *)sortedWithArray:(NSArray *)numbers
{
    return  [numbers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = NSOrderedSame;
        NSInteger value1 = [obj1 floatValue];
        NSInteger value2 = [obj2 floatValue];
        if (value1 > value2) {
            result =  NSOrderedDescending;
        } else if (value1 > value2) {
            result = NSOrderedSame;
        } else if (value1 > value2) {
            result =  NSOrderedDescending;
        }
        return result;
    }];
    
}

- (NSArray *)reverseForArray:(NSArray *)array
{
    return array.reverseObjectEnumerator.allObjects;
}

- (NSString *)jsonString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end

//
//  PersonModel.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/5.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "PersonModel.h"

@implementation PersonModel

- (NSMutableArray *) modelTransToArr
{
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:@(_weight)];
    [arr addObject:@(_stride)];
    [arr addObject:@((_wake_t=1))];
    [arr addObject:@(_corr_rmr*100)];//需要乘以100再转换
    
    return arr;

}
@end

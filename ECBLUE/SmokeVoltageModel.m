//
//  SmokeVoltageModel.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/5.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "SmokeVoltageModel.h"

@implementation SmokeVoltageModel

- (NSMutableArray *) modelTransToArr
{
    NSMutableArray *arr = [NSMutableArray array];

    [arr addObject:@(_voltage*10)];//需要乘以10再转换
    
    return arr;
    
}

@end

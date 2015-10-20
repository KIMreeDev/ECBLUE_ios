//
//  SmokeTimeModel.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/5.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "SmokeTimeModel.h"

@implementation SmokeTimeModel

- (NSMutableArray *) modelTransToArr
{
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:@(_seconds)];
    
    return arr;
}
@end

//
//  SmokeCntModel.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/5.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "SmokeCntModel.h"

@implementation SmokeCntModel

- (NSMutableArray *) modelTransToArr
{
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:@(_times)];
    
    return arr;
}

@end

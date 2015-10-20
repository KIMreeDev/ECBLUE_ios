//
//  TimeModel.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/5.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "TimeModel.h"

@implementation TimeModel

- (NSMutableArray *) modelTransToArr
{
    NSMutableArray *arr = [NSMutableArray array];
    NSDictionary *dic =[DateTimeHelper getsEveryOneFromDate:_date];
    [arr addObject:[dic objectForKey:@"second"]];
    [arr addObject:[dic objectForKey:@"minute"]];
    [arr addObject:[dic objectForKey:@"hour"]];
    [arr addObject:[dic objectForKey:@"day"]];
    [arr addObject:[dic objectForKey:@"month"]];
    [arr addObject:[NSNumber numberWithInteger:[[dic objectForKey:@"year"] integerValue]%100]];
    return arr;
}
@end

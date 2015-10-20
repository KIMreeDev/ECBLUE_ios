//
//  MemoryModel.h
//  ECBLUE
//
//  Created by JIRUI on 14/12/29.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRModel.h"

@interface MemoryModel : JRModel

//运动的天数
@property (assign, nonatomic) NSInteger daysOfStep;
//睡眠几次
@property (assign, nonatomic) NSInteger timesOfSleep;
//吸烟几天
@property (assign, nonatomic) NSInteger daysOfSmoke;
//电池电量
@property (assign, nonatomic) NSInteger numbersOfBattery;

@end

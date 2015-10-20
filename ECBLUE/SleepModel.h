//
//  SleepModel.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/2.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "JRModel.h"

@interface SleepModel : JRModel

//表示第几次的记录
@property (assign, nonatomic) NSInteger indexOfSleep;
//年、月、日、时、分(开始时间)
@property (strong, nonatomic) NSDate *startDate;
//年、月、日、时、分(结束时间)
@property (strong, nonatomic) NSDate *endDate;
//睡觉时长（分钟）
@property (assign, nonatomic) NSUInteger minutes;
//蓝牙UUID
@property (nonatomic, retain) NSString * blueUUID;
@end

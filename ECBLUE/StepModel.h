//
//  StepModel.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/2.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "JRModel.h"

@interface StepModel : JRModel

//表示第几天的记录
@property (assign, nonatomic) NSInteger indexOfDay;
//年、月、日
@property (strong, nonatomic) NSDate *date;
//运动总时长(分钟)
@property (assign, nonatomic) NSUInteger minutes;
//运动总步数
@property (assign, nonatomic) NSUInteger steps;
//总卡路里
@property (assign, nonatomic) NSUInteger kcals;
//运动总距离(千米)
@property (assign, nonatomic) float distances;
//蓝牙UUID
@property (nonatomic, retain) NSString * blueUUID;

@end

//
//  SmokeModel.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/2.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "JRModel.h"

@interface SmokeModel : JRModel

//表示第几天的记录
@property (assign, nonatomic) NSInteger indexOfDay;
//年、月、日
@property (strong, nonatomic) NSDate *date;
//吸烟总口数
@property (assign, nonatomic) NSUInteger mouths;
//吸烟的总时长
@property (assign, nonatomic) NSUInteger seconds;
//蓝牙UUID
@property (nonatomic, retain) NSString * blueUUID;
@end

//
//  PersonModel.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/5.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "JRModel.h"

@interface PersonModel : JRModel

//体重 （kg）
@property (assign, nonatomic) NSInteger weight;
//步长 （cm）
@property (assign, nonatomic) NSInteger stride;
//固定为1 (0x01)
@property (assign, nonatomic) NSInteger wake_t;
/*
 RMR (kcal/day)计算公式:
 For men: (10 x weight) + (6.25 x height) – (5 x age) + 5
 For women: (10 x weight) + (6.25 x height) – (5 x age) - 161
 */
//静态卡路里参数（ 1.15 x RMR / 24 / 60）
@property (assign, nonatomic) float corr_rmr;


@end

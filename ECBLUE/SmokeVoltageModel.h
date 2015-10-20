//
//  SmokeVoltageModel.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/5.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "JRModel.h"

@interface SmokeVoltageModel : JRModel

//设置吸烟电压给产品(0.1v-9.9v)
@property (assign, nonatomic) float voltage;

@end

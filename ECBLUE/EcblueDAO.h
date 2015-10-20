//
//  EcblueDAO.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/12.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "CoreDataDAO.h"

@interface EcblueDAO : CoreDataDAO
+ (EcblueDAO *)sharedManager;

//增
- (int) createStep:(StepModel *) model;
- (int) createSleep:(SleepModel *) model;
- (int) createSmoke:(SmokeModel *) model;

//删
- (void) removeAllInfo;

//查
- (NSMutableArray *) findAllOfStep;
- (NSMutableArray *) findAllOfSleep;
- (NSMutableArray *) findAllOfSmoke;
- (StepModel *) findStepByID:(StepModel *)model;
- (SleepModel *) findSleepByID:(SleepModel *)model;
- (SmokeModel *) findSmokeByID:(SmokeModel *)model;

//改
- (int) modifyStep:(StepModel *) model;
- (int) modifySleep:(SleepModel *) model;
- (int) modifySmoke:(SmokeModel *) model;

@end

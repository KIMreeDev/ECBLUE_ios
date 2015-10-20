//
//  SleepEntity.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/10.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SleepEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * indexOfSleep;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * minutes;
@property (nonatomic, retain) NSString * blueUUID;

@end

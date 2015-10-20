//
//  StepEntity.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/10.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StepEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * distances;
@property (nonatomic, retain) NSNumber * kcals;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSNumber * minutes;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * indexOfDay;
@property (nonatomic, retain) NSString * blueUUID;

@end

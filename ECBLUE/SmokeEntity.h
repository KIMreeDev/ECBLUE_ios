///
//  SmokeEntity.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/10.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SmokeEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * indexOfDay;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * mouths;
@property (nonatomic, retain) NSNumber * seconds;
@property (nonatomic, retain) NSString * blueUUID;
@end

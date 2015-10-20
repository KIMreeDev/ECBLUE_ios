//
//  ACAttitude.h
//  ecblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>


typedef struct ACAttitude {
    double pitch;
    double roll;
    double yaw;
} ACAttitude;

extern ACAttitude const ACAttitudeZero;
extern ACAttitude const ACAttitudeInvalid;

NSString *NSStringFromACAttitude(ACAttitude attitude);
ACAttitude ACAttitudeWithCMAttitude(CMAttitude *attitude);
ACAttitude ACAttitudeDifference(ACAttitude attitude1, ACAttitude attitude2);
ACAttitude ACAttitudeClamp(ACAttitude attitude, double pitchMax, double rollMax, double yawMax);
ACAttitude ACAttitudeOffset(ACAttitude attitude, double pitchOffset, double rollOffset, double yawOffset);
BOOL ACAttitudeEqualToAttitude(ACAttitude attitude1, ACAttitude attitude2);
BOOL ACAttitudeIsInvalid(ACAttitude attitude);


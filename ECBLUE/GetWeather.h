//
//  GetWeather.h
//  ECBLUE
//
//  Created by renchunyu on 15/1/21.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetWeather : NSObject
+ (GetWeather *) sharedInstance;
-(NSDictionary*)getWeatherXml;
@end

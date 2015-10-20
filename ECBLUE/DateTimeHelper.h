//
//  DateTimeHelper.h
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-18.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeHelper : NSObject
+ (NSString *)formatStringWithDate:(NSDate *)date;
//是否同一天
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;
//date->nsstring
+ (NSString *)formatDate:(NSDate *)date toString:(NSString *)format;
//中间持续天数
+ (NSInteger)daysFromDate:(NSDate *) startDate toDate:(NSDate *) endDate;
//把标准时间转换成正常时间
+ (NSDate *)getLocalDateFormateUTCDate:(NSDate *)date;
//把正常时间转换成标准时间
+ (NSString *)getUTCFormateLocalDate:(NSDate *)localDate;
//year、month、day、hour、minute、second
+ (NSDictionary *) getsEveryOneFromDate:(NSDate *)date;
//构建日期对象
+ (NSDate *) dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute seconds:(NSInteger)seconds;
//是否零点(00:00:01)
+ (BOOL)isZeroTime;
//获取当前系统的时间戳
+ (long long int)getTimeSp;
//获取本地语言
+ (NSString*)getPreferredLanguage;
//默认设置
+ (void)defaultProperty;
@end

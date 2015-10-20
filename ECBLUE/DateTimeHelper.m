//
//  DateTimeHelper.m
//  ECIGARFAN
//
//  Created by JIRUI on 14-4-18.
//  Copyright (c) 2014年 JIRUI. All rights reserved.
//

#import "DateTimeHelper.h"

@implementation DateTimeHelper
//（获得时间的长短）
+ (NSString *)formatStringWithDate:(NSDate *)date {

  NSString *result;
  NSTimeInterval interval = -[date timeIntervalSinceNow];
  if (interval<0 || !date) {
    result = @"just";//不同国家，不同时区，会造成本地时间比较为负，则为刚刚
  }else if (interval<60) {
    result =NSLocalizedString(@"just", nil);
  }else if (interval/60<60) {
    //小于60分钟
    result = [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", nil),(NSInteger)interval/60];
  }else if(interval/60/60<24){
    //小于24小时
    result = [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", nil),(NSInteger)interval/60/60];
  }else{
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      result = [formatter stringFromDate:date];
  }
  
  return result;
}

//中间持续天数
+ (NSInteger)daysFromDate:(NSDate *) startDate toDate:(NSDate *) endDate {
    NSTimeInterval start = [startDate timeIntervalSince1970];
    NSTimeInterval over = [endDate timeIntervalSince1970];
    NSInteger days = ceil((over - start)/(24*60*60));
    return days;
}

//获取年、月、日、小时、分钟、秒
+ (NSDictionary *) getsEveryOneFromDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    
    return [NSDictionary dictionaryWithObjects:@[@([dateComponent year]), @([dateComponent month]),
                                                 @([dateComponent day]), @([dateComponent hour]),
                                                 @([dateComponent minute]), @([dateComponent second])]
                                       forKeys:@[@"year", @"month",
                                                 @"day", @"hour",
                                                 @"minute", @"second"]];
}

//是否零点(00:00:01)
+ (BOOL)isZeroTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    return  ([dateComponent hour]==0)&&
            ([dateComponent minute]==0)&&
            ([dateComponent second]==0) ;
}

//转换指定格式的字符串日期(yyyy-MM-dd HH:mm:ss)
+ (NSString *)formatDate:(NSDate *)date toString:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

//是否同一天
+(BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return  [comp1 day]  == [comp2 day] &&
            [comp1 month] == [comp2 month] &&
            [comp1 year]  == [comp2 year];
}

//获取当前系统的时间戳
+ (long long int)getTimeSp
{
    long long time;
    NSDate *fromdate=[NSDate date];
    time=(long long int)[fromdate timeIntervalSince1970]*10;//单位100毫秒
    return time;
}

+ (NSString*)getPreferredLanguage

{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    NSLog(@"当前语言:%@", preferredLang);
    
    return preferredLang;
    
}

//把标准时间转换成正常时间
+ (NSDate *)getLocalDateFormateUTCDate:(NSDate *)date
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return destinationDateNow;
}

//把正常时间转换成标准时间
+(NSString *)getUTCFormateLocalDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}


//构建日期对象
+ (NSDate *) dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute seconds:(NSInteger)seconds
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setSecond:seconds];
    [components setMinute:minute];
    [components setHour:hour];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:components];
    
    return date;
}

//默认属性设置
+ (void)defaultProperty
{
    if ([S_USER_DEFAULTS boolForKey:F_OPENED_SECOND]) {
        return;
    }
    //获取软件版本号
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
    [S_USER_DEFAULTS setObject:versionNum forKey:F_SMOKE_VERSION];
    if (![[GGDiscover sharedInstance]isConnectted]) {
        [S_USER_DEFAULTS setObject:NOT_CONNECTED_IDENTI forKey:F_FIRMWARE_VERSION];
    }
    
    //第一次打开软件，初始化戒烟起始时间
    //Ecig
    [S_USER_DEFAULTS setObject:@"6" forKey:F_NICOTINE_VALUE];//默认尼古丁mg值
    [S_USER_DEFAULTS setObject:@"1000" forKey:F_PUFFS_LIMIT];//口数限制 dafault 55  (1-1000)
    //Sport
    [S_USER_DEFAULTS setObject:@"10000" forKey:F_GOAL_RUNNING];//跑步目标
    [S_USER_DEFAULTS setObject:@"370" forKey:F_GOAL_CALORIES];//卡路里目标
    //Message
    [S_USER_DEFAULTS setObject:@"16" forKey:F_CIGARETTES_DAY];//每天吸的传统烟数
    [S_USER_DEFAULTS setObject:@"9.50" forKey:F_PRICE_PACK];//每包传统烟多少钱
    [S_USER_DEFAULTS setObject:@"5.00" forKey:F_PRICE_ML];//每毫升烟油多少钱
    [S_USER_DEFAULTS setObject:@"€(EUR)" forKey:F_CURRENCY];//货币符号
    [S_USER_DEFAULTS setObject:@"Ultra Light(<0.5mg/cig.)" forKey:F_NICOTINE_RANGE];//默认尼古丁mg范围
    //Health
    [S_USER_DEFAULTS setObject:[NSDate date] forKey:F_NON_SMOKING];
    //个人信息初始化
    NSMutableArray *personInfo = [NSMutableArray arrayWithObjects:  @"",
                                  @"",
                                  @0,
                                  @"",
                                  [NSString stringWithFormat:@"170 %@", KEY_LIMI],
                                  [NSString stringWithFormat:@"60 %@",KEY_GONJIN], nil];
    NSTimeInterval timeInterval = -30*365*24*60*60;
    NSDate *birthDay = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    [personInfo replaceObjectAtIndex:3 withObject:birthDay];
    [S_USER_DEFAULTS setObject:personInfo forKey:F_PERSON_INFO];
    
    [S_USER_DEFAULTS setObject:@"https://itunes.apple.com/us/app/ecigarfan/id893547382?mt=8&uo=4" forKey:STORE_URL];//在appstore的地址
    [S_USER_DEFAULTS synchronize];
    
}
@end













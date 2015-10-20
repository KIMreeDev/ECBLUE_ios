//
//  GetWeather.m
//  ECBLUE
//
//  Created by renchunyu on 15/1/21.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "GetWeather.h"

@implementation GetWeather

+ (id)sharedInstance
{
    static GetWeather *instance	= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken , ^{
        instance = [[GetWeather alloc]init];
    });
    
    return instance;
}



//获取天气
-(NSDictionary*)getWeatherXml{
    NSError *error;
    NSURLResponse *response;
    NSData *dataReply;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://m.weather.com.cn/data/%@.html", [self getCityCode]]]];
    [request setHTTPMethod: @"GET"];
   
    dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *dicReply = [NSJSONSerialization JSONObjectWithData:dataReply options:NSJSONReadingMutableContainers error:nil];
  
    
  //  stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
    
    //NSLog(stringReply);
   
    return dicReply;
}

//获取城市代码
-(NSString*)getCityCode
{
    //解析网址通过ip 获取城市天气代码
    NSURL *url = [NSURL URLWithString:@"http://61.4.185.48:81/g/"];
    NSError *error;
    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    //NSLog(@"------------%@",jsonString);
    // 得到城市代码字符串，截取出城市代码
    NSString *Str;
    NSString *intString;
    for (int i = 0; i<=[jsonString length]; i++)
    {
        for (int j = i+1; j <=[jsonString length]; j++)
        {
            Str = [jsonString substringWithRange:NSMakeRange(i, j-i)];
            if ([Str isEqualToString:@"id"]) {
                if (![[jsonString substringWithRange:NSMakeRange(i+3, 1)] isEqualToString:@"c"]) {
                    intString = [jsonString substringWithRange:NSMakeRange(i+3, 9)];
                   // NSLog(@"***%@***",intString);
                }
            }
        }
    }

    return intString;

}



@end

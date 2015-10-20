//
//  GGDataConversion.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/29.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "GGDataConversion.h"
#define MEMORY_HEADER @"91"
#define STEP_HEADER @"92"
#define SLEEP_HEADER @"93"
#define SMOKE_HEADER @"94"

@implementation GGDataConversion


//转换请求到的数据
- (GGDataConversion *) initWithReciveData:(NSString *)data validate:(NSString *)header
{
    self = [super init];
    if (self) {
        [self receiveData:data validate:header];
    }
    return self;
}

- (void) receiveData:(NSString *)data validate:(NSString *)header
{
    if ([header  isEqual: MEMORY_HEADER]) {
        
        //内存状态
        [self memoryDataConvert:data];
        
    }
    else if ([header isEqualToString: STEP_HEADER]) {
        
        //计步数据
        [self stepDataConvert:data];
        
    }
    else if ([header isEqualToString:SLEEP_HEADER]){
        
        //睡眠数据
        [self sleepDataConvert:data];
        
    }
    else if ([header isEqualToString:SMOKE_HEADER]){
     
        //吸烟数据
        [self smokeDataConvert:data];
        
    }
}

#pragma mark ----------------------------------- 解析数据

//记录内存数据
- (void) memoryDataConvert:(NSString *)data
{
    NSMutableArray *arr = [self dataTransformToDecimal:data];
    _memoryModel = [[MemoryModel alloc]init];
    _memoryModel.daysOfStep = [[arr objectAtIndex:0]integerValue];
    _memoryModel.timesOfSleep = [[arr objectAtIndex:1]integerValue];
    _memoryModel.daysOfSmoke = [[arr objectAtIndex:2]integerValue];
    _memoryModel.numbersOfBattery = [[arr objectAtIndex:3]integerValue];
    
}

//记录计步数据
- (void) stepDataConvert:(NSString *)data
{
    _stepModel = [[StepModel alloc]init];
    NSMutableString *mutableStr = [NSMutableString stringWithString:data];

    //第几天、日、月、年
    NSMutableArray *arr = [self dataTransformToDecimal:[mutableStr substringWithRange:NSMakeRange(0, 10)]];
    _stepModel.indexOfDay = [[arr objectAtIndex:0]integerValue];
    NSInteger day = [[arr objectAtIndex:1]integerValue];
    NSInteger month = [[arr objectAtIndex:2]integerValue];
    NSInteger year = [[arr objectAtIndex:3]integerValue]+2000;
    NSInteger hour = 0, minute = 0, seconds = 0;
    _stepModel.date = [DateTimeHelper dateFromYear:year month:month day:day hour:hour minute:minute seconds:seconds];
    
    //运动时长、运动步数、卡路里、运动距离
    _stepModel.minutes = [self allDataTransformToDecimal:[self reserveseString:[mutableStr substringWithRange:NSMakeRange(10, 4)]]];
    _stepModel.steps = [self allDataTransformToDecimal:[self reserveseString:[mutableStr substringWithRange:NSMakeRange(14, 8)]]];
    _stepModel.kcals = [self allDataTransformToDecimal:[self reserveseString:[mutableStr substringWithRange:NSMakeRange(22, 4)]]];
    _stepModel.distances = [self allDataTransformToDecimal:[self reserveseString:[mutableStr substringWithRange:NSMakeRange(26, 4)]]]/100;
    _stepModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    
}

//睡眠数据记录
- (void) sleepDataConvert:(NSString *)data
{
    _sleepModel = [[SleepModel alloc]init];
    NSMutableString *mutableStr = [NSMutableString stringWithString:data];
    NSMutableArray *arr = [self dataTransformToDecimal:[mutableStr substringWithRange:NSMakeRange(0, mutableStr.length-4)]];
    
    //次数、开始时间
    _sleepModel.indexOfSleep = [[arr objectAtIndex:0]integerValue];
    NSInteger seconds = 0;
    NSInteger minute = [[arr objectAtIndex:1]integerValue];
    NSInteger hour = [[arr objectAtIndex:2]integerValue];
    NSInteger day = [[arr objectAtIndex:3]integerValue];
    NSInteger month = [[arr objectAtIndex:4]integerValue];
    NSInteger year = [[arr objectAtIndex:5]integerValue]+2000;
    _sleepModel.startDate = [DateTimeHelper dateFromYear:year month:month day:day hour:hour minute:minute seconds:seconds];

    //结束时间
    minute = [[arr objectAtIndex:6]integerValue];
    hour = [[arr objectAtIndex:7]integerValue];
    day = [[arr objectAtIndex:8]integerValue];
    month = [[arr objectAtIndex:9]integerValue];
    year = [[arr objectAtIndex:10]integerValue];
    _sleepModel.endDate = [DateTimeHelper dateFromYear:year month:month day:day hour:hour minute:minute seconds:seconds];
    
    //睡眠时长
    _sleepModel.minutes = [self allDataTransformToDecimal:[self reserveseString:[mutableStr substringWithRange:NSMakeRange(mutableStr.length-4, 4)]]];
    _sleepModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
}

//吸烟数据记录
- (void) smokeDataConvert:(NSString *)data
{
    _smokeModel = [[SmokeModel alloc]init];
    NSMutableString *mutableStr = [NSMutableString stringWithString:data];
    NSMutableArray *arr = [self dataTransformToDecimal:[mutableStr substringWithRange:NSMakeRange(0, 10)]];
    
    //第几天、年、月、日
    _smokeModel.indexOfDay = [[arr objectAtIndex:0]integerValue];
    NSInteger day = [[arr objectAtIndex:1]integerValue];
    NSInteger month = [[arr objectAtIndex:2]integerValue];
    NSInteger year = [[arr objectAtIndex:3]integerValue]+2000;
    NSInteger hour = 0, minute = 0, seconds = 0;
    _smokeModel.date = [DateTimeHelper dateFromYear:year month:month day:day hour:hour minute:minute seconds:seconds];
    
    //吸烟总口数
    _smokeModel.mouths = [self allDataTransformToDecimal:[self reserveseString:[mutableStr substringWithRange:NSMakeRange(10, 4)]]];
    
    //吸烟总时长
    _smokeModel.seconds = [self allDataTransformToDecimal:[self reserveseString:[mutableStr substringWithRange:NSMakeRange(14, 4)]]];
    _smokeModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    
}

#pragma mark ---------------------------------- 转换工具

//16进制字符串转10进制  （全部一起转）
- (float) allDataTransformToDecimal:(NSString *)data
{
    unsigned long long nowTime = 0.0;
    NSScanner* scan = [NSScanner scannerWithString:data];
    [scan scanHexLongLong:&nowTime];
    
    return nowTime;
}

//16进制字符串转10进制  (两位转)
- (NSMutableArray *) dataTransformToDecimal:(NSString *)data
{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 2; i < [data length] - 1; i += 2) {
        unsigned long long nowTime = 0.0;
        NSString * hexCharStr = [data substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexLongLong:&nowTime];
        [arr addObject:@(nowTime)];
    }
    return arr;
}

//16进制字符串转二进制
- (NSData *)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

//组合请求命令
- (NSMutableString *) componentOfCmd:(NSString *)cmd index:(NSUInteger)index
{
    if (index > 14) {
        index = 14;
    }
    
    NSMutableString *mutableStr = [self dataConversion:index];
    [mutableStr insertString:cmd atIndex:0];
    
    return mutableStr;
}

//把一个整形值转换成16进制字符串（占位两个字节）
- (NSMutableString *) dataConversion:(NSUInteger) hex
{
    NSMutableString *mutableStr = [NSMutableString string];
    NSString *hexStr = [self ToHex:hex];
    
    if (hexStr.length == 1) {
        [mutableStr appendString:@"0"];
        [mutableStr appendString:hexStr];
    }
    
    if (hexStr.length >= 2) {
        [mutableStr appendString:[hexStr substringFromIndex:hexStr.length-2]];
    }
    
    return mutableStr;
    
}

//10进制转16进制
- (NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }

    return str;
    
}

//反转字符串
- (NSMutableString *) reserveseString:(NSString *)string
{
    NSMutableString * outputString = [NSMutableString string];

    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationLocalized | NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        if (substringRange.location%2 == 1) {
            [outputString insertString:substring atIndex:1];
        }else{
            [outputString insertString:substring atIndex:0];
        }
        
    }];
    return outputString;
}

//数组转可变字符串(没有高低位)
- (NSMutableString *) stringFromArr:(NSMutableArray *)arr
{
    NSMutableString *mutString = [NSMutableString string];
    if (arr) {
        for (NSInteger i = 0; i < arr.count; i ++) {
            NSUInteger hex = [[arr objectAtIndex:i]unsignedIntegerValue];
            [mutString appendString:[self dataConversion:hex]];
        }
    }
    return  mutString;
}

//数组中只有一个数据，且分高低位
- (NSMutableString *) stringFromArrOfHighAndLow:(NSMutableArray *)arr
{
    NSMutableString *mutString = [NSMutableString string];
    if (arr) {
        NSString *hexStr = [self ToHex:[[arr lastObject] unsignedIntegerValue]];
        [mutString appendString:hexStr];
        
        for (NSInteger i = 0; i < 4-hexStr.length; i ++) {
            [mutString insertString:@"0" atIndex:0];
        }
    }
    return  [self reserveseString:mutString];
}

@end

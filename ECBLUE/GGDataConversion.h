//
//  GGDataConversion.h
//  ECBLUE
//
//  Created by JIRUI on 14/12/29.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoryModel.h"
#import "StepModel.h"
#import "SleepModel.h"
#import "SmokeModel.h"

@interface GGDataConversion : NSObject

@property (strong, nonatomic) MemoryModel *memoryModel;
@property (strong, nonatomic) StepModel *stepModel;
@property (strong, nonatomic) SleepModel *sleepModel;
@property (strong, nonatomic) SmokeModel *smokeModel;
//转换请求到的数据
- (GGDataConversion *) initWithReciveData:(NSString *)data  validate:(NSString *)header;
//组合请求命令
- (NSMutableString *)componentOfCmd:(NSString *)cmd index:(NSUInteger)index;
//把一个整形值转换成16进制字符串（占位两个字节）
- (NSMutableString *) dataConversion:(NSUInteger) hex;
//反转字符串
- (NSMutableString *) reserveseString:(NSString *)string;
//16进制数－>Byte数组->NSData
- (NSData *) stringToByte:(NSString*)string;
//10进制转16进制
- (NSString *) ToHex:(long long int)tmpid;
//数组数据转16进制字符串
- (NSMutableString *) stringFromArr:(NSMutableArray *)arr;
//数组中只有一个数据，且分高低位
- (NSMutableString *) stringFromArrOfHighAndLow:(NSMutableArray *)arr;
//16进制字符串转10进制  （全部一起转）
- (float) allDataTransformToDecimal:(NSString *)data;
//16进制字符串转10进制  (2个一转)
- (NSMutableArray *) dataTransformToDecimal:(NSString *)data;

@end

//
//  JRObject.h
//  ECIGARFAN
//
//  Created by JIRUI on 14/12/29.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DateTimeHelper.h"
@interface JRModel : NSObject<NSCoding>
- (void)loadData:(NSDictionary *)dict;
- (NSMutableArray *) modelTransToArr;

/*
 *@brief 归档
 */

 - (void)encodeWithCoder:(NSCoder *)encoder;
 
/*
 *@brief 解归档
 */

 - (id)initWithCoder:(NSCoder *)decoder;


@end



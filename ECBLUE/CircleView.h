//
//  CircleView.h
//  ECBLUE
//
//  Created by renchunyu on 14/12/17.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleView : UIView
{
    //半径,线宽度
    float radius,width;

}
@property (assign,nonatomic) float percentage;
@property (assign,nonatomic) NSInteger circleType;//用来判断哪个视图，0为电子烟，1为计步器
@end

//
//  colorCircle.h
//  ECBLUE
//
//  Created by renchunyu on 14/12/17.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface colorCircle : UIView
//中心点坐标
@property(nonatomic)CGPoint point;
//半径，底层半径，上层半径，中间层半径
@property(nonatomic)float bg;
//宽度，线的宽度
@property(nonatomic)float width;

@property(nonatomic)float z1,z2;
//渐变层坐标大小
@property(nonatomic)CGRect rect1,rect2;

@property(nonatomic)float value;

@property(nonatomic)CAGradientLayer * gradientlayer1,*gradientlayer2;

@property(nonatomic)CALayer * layer_d;

@property(nonatomic)CAShapeLayer * shapelayer;

@property(nonatomic)NSArray * array1,*array2;

@property(nonatomic)UIBezierPath * apath;

@property(nonatomic)CABasicAnimation *animation;

//定义三个渐变颜色，也可以设定一样
@property(strong,nonatomic)UIColor *colorOne;
@property(strong,nonatomic)UIColor *colorTwo;
@property(strong,nonatomic)UIColor *colorThree;

@end

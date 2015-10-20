//
//  TimeLineView.m
//  ECBLUE
//
//  Created by renchunyu on 14/11/24.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "TimeLineView.h"
#import <math.h>
#import <objc/runtime.h>
@implementation TimeLineView
#define HEIGHTVALUE (self.frame.size.height-15)*value/maxValue
#define WEIGTHVALUE (i*60+60)
#define WIDTH 60
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    float height=self.frame.size.height;
    float maxValue=[self getMaxValue:_array];
    NSInteger value = 0.0;
    
    timeLineContext = UIGraphicsGetCurrentContext();

    //线的宽度
    CGContextSetLineWidth(timeLineContext, 1);
    
    //线的颜色
    CGContextSetRGBStrokeColor(timeLineContext, 10/255.0, 1234/255.0 , 223/255.0, 0.55);
    
    //背景方块
    CGRect rectZ = CGRectMake(0, 0, 60, self.frame.size.height);
    [self backGroundColor:timeLineContext andIndex:1];
    CGContextFillRect(timeLineContext, rectZ);
    float backgroundX = 0.0;
    NSInteger count = _array.count;
    if (count < 5) {
        count = 5;
    }
    for (int i=0; i < count; i++) {
        rectZ = CGRectMake(WEIGTHVALUE, 0, WEIGTHVALUE-backgroundX, self.frame.size.height);
        [self backGroundColor:timeLineContext andIndex:i];
        CGContextFillRect(timeLineContext, rectZ);
        backgroundX = WEIGTHVALUE;
    }
    if (!maxValue) {
        return;
    }
    //画线
    CGContextMoveToPoint(timeLineContext, 0, height);
    for (int i=0; i<_array.count; i++) {
        
        value=[(NSString*)[_array objectAtIndex:i] integerValue];
        CGContextAddLineToPoint(timeLineContext, WEIGTHVALUE, (height-HEIGHTVALUE));

        if (i == _array.count-1) {
            CGContextAddLineToPoint(timeLineContext, self.frame.size.width, (height-HEIGHTVALUE));
            CGContextAddLineToPoint(timeLineContext, self.frame.size.width, height);
        }
    }
    
    //填充
    CGContextSetFillColorWithColor(timeLineContext, [UIColor colorWithRed:110/255.0 green:195/255.0 blue:189/255.0 alpha:0.5].CGColor);
    
    
    CGContextDrawPath(timeLineContext, kCGPathFillStroke);
    
    //水平线
    [self horizontalLine:timeLineContext Max:maxValue];
    
    //画圆
    CGContextSetLineWidth(timeLineContext, 2.8);
    for (int i=0; i<_array.count; i++) {
        
        value=[(NSString*)[_array objectAtIndex:i] integerValue];
        if (!value) {
            continue;
        }
        
        //填充
        [self addColorToArc:timeLineContext andPercent:(value/maxValue)];
        CGContextAddArc(timeLineContext, WEIGTHVALUE, height-HEIGHTVALUE, 5.0, 0, 2*M_PI, 0);
        CGContextDrawPath(timeLineContext, kCGPathFillStroke);
    }
    
    

}

- (void) horizontalLine:(CGContextRef)context Max:(float)maxValue {
    
    //最多5份，少于5时，跟随变动
    float maxNumber = 5;
    if (maxValue < 5) {
        maxNumber = maxValue;
    }
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetRGBStrokeColor(context, 201/255.0, 205/255.0 , 206/255.0, 0.5);
    
    for (int i = 0; i < maxNumber; i++) {
        CGContextMoveToPoint(context, 45, 15+(maxNumber-i-1)*((self.frame.size.height-15)/maxNumber));
        CGContextAddLineToPoint(context, self.frame.size.width, 15+(maxNumber-i-1)*((self.frame.size.height-15)/maxNumber));
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    
}

- (void) backGroundColor:(CGContextRef)context andIndex:(NSInteger)index {
    
    if (index%2 == 0) {
        CGContextSetRGBFillColor(context, 70/255.0 ,184/255.0 , 226/255.0, 1.0);
    }else {
        CGContextSetRGBFillColor(context, 59/255.0 ,174/255.0 , 215/255.0, 1.0);
    }
}

//设置圆的颜色
- (void)addColorToArc:(CGContextRef)context andPercent:(float)percentValue
{
    if (percentValue>0.6 && percentValue<0.8)
    {
        //CGContextSetRGBStrokeColor(context, 255/255.0 ,193/255.0 , 30/255.0, 1.0);
        CGContextSetRGBStrokeColor(context, 255/255.0 ,255/255.0 , 255/255.0, 1.0);
    }
    else if (percentValue > 0.8)
    {
        //CGContextSetRGBStrokeColor(context, 255/255.0 ,99/255.0 ,71/255.0, 1.0);
        CGContextSetRGBStrokeColor(context, 255/255.0 ,255/255.0 , 255/255.0, 1.0);
        
    }
    else
    {
        //CGContextSetRGBStrokeColor(context, 0/255.0, 201/255.0 ,87/255.0, 1.0);
        CGContextSetRGBStrokeColor(context, 255/255.0 ,255/255.0 , 255/255.0, 1.0);
    }
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:56/255.0 green:182/255.0 blue:225/255.0 alpha:1.0].CGColor);//填充颜色

}

//获取最大值
-(float)getMaxValue:(NSMutableArray*)array
{
    float maxValue = 0;
    for (int i=0; i<array.count; i++) {
        if ([[_array objectAtIndex:i] integerValue]>maxValue) {
            maxValue=[[_array objectAtIndex:i] integerValue];
        }
    }
    return maxValue;
}

//添加圆点的点击事件
- (void)addImageGesture
{
    float height=self.frame.size.height;
    float maxValue=[self getMaxValue:_array];
    if (!maxValue) {
        return;
    }
    float value=0.0;
    CGPoint point;   
    
    for (int i=0; i < _array.count; i++) {
        value=[(NSString*)[_array objectAtIndex:i] integerValue];
        
        point = CGPointMake(WEIGTHVALUE, height-HEIGHTVALUE);
        
        //点
        UIImageView *imagePointView = [[UIImageView alloc]initWithFrame:CGRectMake(point.x - 20, point.y - 20, 40, 40)];
        imagePointView.userInteractionEnabled = YES;
        imagePointView.tag = i+100;
        //竖线
        UIImageView *imageCenterlineView = [[UIImageView alloc]initWithFrame:CGRectMake(point.x, point.y+6, 1, HEIGHTVALUE-6)];
        imageCenterlineView.userInteractionEnabled = NO;
        imageCenterlineView.tag = imagePointView.tag+1000;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clicked:)];
        [imagePointView addGestureRecognizer:singleTap];
        imagePointView.userInteractionEnabled = YES;
        [self addSubview:imagePointView];
        [self addSubview:imageCenterlineView];
        
        if (i == _array.count-1) {
  
            //默认选中今天
            [self setPointImageNeed:value/maxValue andImageVIew:imagePointView];
            [self setPointImageNeed:value/maxValue andImageVIew:imageCenterlineView];
        }
    }
    
    //添加本视图手势
    UITapGestureRecognizer *selfViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchView:)];
    selfViewTap.numberOfTouchesRequired = 1; //手指数
    selfViewTap.numberOfTapsRequired = 1; //tap次数
    [self addGestureRecognizer:selfViewTap];

}

#pragma mark-   触摸事件
- (void)touchView:(UITapGestureRecognizer *)gesture
{

    CGPoint point = [gesture locationInView:self];
    
    float maxValue=[self getMaxValue:_array];
    if (!maxValue) {
        return;
    }
    
    //值
    NSInteger tag = floor((point.x-30)/WIDTH)+100;
    
    
    if (point.x > (_array.count-1)*WIDTH+60) {
        tag = _array.count-1+100;
    }

    if (point.x < 45) {
        tag = 100;
    }
    
    NSInteger value = [[_array objectAtIndex:(tag-100)] integerValue];
    float percentValue = value/maxValue;
    
    //选中
    UIImageView *pointView = (UIImageView *)[self viewWithTag:tag];
    UIImageView *centLineView = (UIImageView *)[self viewWithTag:tag+1000];
    if (!pointView.image) {
        [self allPointImageToNil];
        [self setPointImageNeed:percentValue andImageVIew:pointView];
        [self setPointImageNeed:percentValue andImageVIew:centLineView];
        //通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMEPOINT_TOUCH object:self userInfo:@{@"index":@(tag-100), @"percent":@(value/maxValue), @"offset":@(point.x-kScreen_Width)}];
    }

}

- (void)clicked:(UIGestureRecognizer *)sender
{
    //该点已选中就直接返回
    UIImageView *pointView = (UIImageView *)sender.view;
    UIImageView *centLineView = (UIImageView *)[self viewWithTag:pointView.tag+1000];
    
    if (pointView.image) {
        return;
    }
    
    NSUInteger tag = pointView.tag;
    float maxValue=[self getMaxValue:_array];
    if (!maxValue) {
        return;
    }
    float value= [(NSString*)[_array objectAtIndex:tag-100] integerValue];
    float percentValue = value/maxValue;
    
    //取消所有选中点
    [self allPointImageToNil];
    
    //选中一个点
    [self setPointImageNeed:percentValue andImageVIew:pointView];
    [self setPointImageNeed:percentValue andImageVIew:centLineView];

    //通知
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMEPOINT_TOUCH object:self userInfo:@{@"index":@(tag-100), @"percent":@(percentValue), @"offset":@(pointView.center.x-kScreen_Width)}];
    
    
}

//后退或前进一天时，触发
- (void)changeDateToUpdateThePointImageView :(NSUInteger)tag {

    //选中
    UIImageView *pointView = (UIImageView *)[self viewWithTag:tag+100];
    UIImageView *centLineView = (UIImageView *)[self viewWithTag:pointView.tag+1000];
    
    float maxValue=[self getMaxValue:_array];
    if (!maxValue) {
        return;
    }
    float value= [(NSString*)[_array objectAtIndex:tag] integerValue];
    float percentValue = value/maxValue;
    
    if (!pointView.image) {
        //取消所有选中点
        [self allPointImageToNil];
        
        //选中一个点
        [self setPointImageNeed:percentValue andImageVIew:pointView];
        [self setPointImageNeed:percentValue andImageVIew:centLineView];
        //通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMEPOINT_TOUCH object:self userInfo:@{@"index":@(tag), @"percent":@(percentValue),  @"offset":@(pointView.center.x-kScreen_Width)}];
    }

}

//tag值 < 1100 为点， 否则为中间竖线
- (void)setPointImageNeed:(float)percentValue andImageVIew:(UIImageView *)pointView
{
    if (percentValue>0.6 && percentValue<0.8)
    {
        [pointView setImage:(pointView.tag < 1100) ? ([UIImage imageNamed:@"p_yellow"]) : ([UIImage imageNamed:@"yellowLine"])];
    }
    else if (percentValue > 0.8)
    {
        [pointView setImage:(pointView.tag < 1100) ? ([UIImage imageNamed:@"p_red"]) : ([UIImage imageNamed:@"redLine"])];
    }
    else
    {
        [pointView setImage:(pointView.tag < 1100) ? ([UIImage imageNamed:@"p_green"]) : ([UIImage imageNamed:@"greenLine"])];
    }
}

- (void)allPointImageToNil
{
    NSArray *subViews = [self subviews];
    for (id sView in subViews) {
        if ([sView isKindOfClass:[UIImageView class]]) {
            UIImageView *pointView = sView;
            if (pointView.image) {
                pointView.image = nil;
                pointView.highlightedImage = nil;
            }
        }

    }
}

@end

//
//  RunView.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "RunView.h"
#import "VerticalTopLabel.h"
#define RUNVIEW_WEIGHT self.frame.size.width
#define RUNVIEW_HEIGHT self.frame.size.height

@implementation RunView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //标尺
    [self configView];
    //绘图
    [self drawRectangulars];
}

- (void)configView
{
    float x = 0;
    for (NSInteger i = 0; i < _timesArr.count; i++) {
        VerticalTopLabel *label = [[VerticalTopLabel alloc] initWithFrame:CGRectMake(x, RUNVIEW_HEIGHT-20, 100, 15)];
        label.textColor = COLOR_THEME_ONE;
        label.text = [_timesArr objectAtIndex:i];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.verticalAlignment = VerticalAlignmentMiddle;
        [self addSubview:label];
        x += 100;
    }
}

- (void)drawRectangulars {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectZero;
    float maxValue=[self maxValue];	
    float x = 5;
    for (int i = 0; i < _dataArr.count; i ++) {
        float value = [[_dataArr objectAtIndex:i] floatValue];
        
        CGContextSetRGBFillColor(context, (185-133*value/maxValue)/255.0, (245-56*value/maxValue)/255.0, (111+32*value/maxValue)/255.0, 1.0);
        
        //矩形
        rect = CGRectMake(x,15+(110-110*value/maxValue),90,110*value/maxValue);
        CGContextFillRect(context, rect);
        
        //文字
        UILabel *label = [self addLabelFrame:CGRectMake(x,5+(110-110*value/maxValue),90,10) text:[NSString stringWithFormat:@"%.1fh", value] color:COLOR_MIDDLE_GRAY];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        x += 100;
    }
}

- (float)maxValue
{

    float max = 0;
    for (NSNumber *obj in _dataArr) {
        if (max < [obj floatValue]) {
            max = [obj floatValue];
        }
    }
    return max?max:1;
}

//添加UILabel（集成）
- (UILabel*)addLabelFrame:(CGRect)frame text:(NSString*)string color:(UIColor *)textColor
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.text=string;
    label.textAlignment=NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:16];
    return label;
}

@end

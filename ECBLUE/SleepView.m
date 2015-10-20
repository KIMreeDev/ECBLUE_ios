//
//  SleepView.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/15.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "SleepView.h"
#import "VerticalTopLabel.h"
#define SLEEP_WEIGHT (self.frame.size.width-16)
#define SLEEP_HEIGHT (self.frame.size.height-15)
#define RECT_HEIGHT (SLEEP_HEIGHT-15-30)
@implementation SleepView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    _dataArr = [NSMutableArray arrayWithObjects:@(2.2), @(5.5), @(4.4), @(3.6), nil];
    //标尺
    [self subviewsInit];
    
    //绘图
    [self drawRectangulars];
}

- (void) subviewsInit{
    float numb = SLEEP_WEIGHT/2.0;
    float sum = [self sumValue];
    
    _sleepValue = [self addLabelFrame:CGRectMake(0, 0, numb, 25) text:[NSString stringWithFormat:@"%.1f", sum] color:COLOR_THEME];
    _sleepValue.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_sleepValue];
    
    UILabel *step = [self addLabelFrame:CGRectMake(numb, 0, numb, 25) text:@"小时睡眠" color:COLOR_THEME];
    step.textAlignment = NSTextAlignmentLeft;
    step.font = [UIFont systemFontOfSize:13];
    [self addSubview:step];
    
    //标尺（小时）
    [self configView];
}


- (void)configView
{
    
    for (NSInteger i = 0; i < 5; i++) {
        VerticalTopLabel *label = [[VerticalTopLabel alloc] initWithFrame:CGRectMake(8+i*(SLEEP_WEIGHT/5.0), SLEEP_HEIGHT-15, SLEEP_WEIGHT/5.0, 15)];
        label.textColor = [UIColor darkGrayColor];
        label.text = [NSString stringWithFormat:@"%lih", (long)i*6];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.verticalAlignment = VerticalAlignmentBottom;
        [self addSubview:label];
        
    }
}

- (void)drawRectangulars {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    float max = [self maxValue];
    CGRect rect = CGRectZero;
    
    for (int i = 0; i < 4; i ++) {
        
        //矩形
        float value = [[_dataArr objectAtIndex:i]floatValue];
        rect = CGRectMake(8+(SLEEP_WEIGHT/5.0)/2.0+i*(SLEEP_WEIGHT/5.0), 30+(RECT_HEIGHT-RECT_HEIGHT*((float)value/max)), SLEEP_WEIGHT/5.0, RECT_HEIGHT*((float)value/max));
        [self drawColors:context andValue:value];
        CGContextFillRect(context, rect);
        
        //文字
        UILabel *label = [self addLabelFrame:rect text:[NSString stringWithFormat:@"%.1f", value] color:COLOR_WHITE_NEW];
        label.font = [UIFont systemFontOfSize:10];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
    }
    
}

- (void)drawColors:(CGContextRef)context andValue:(float)value {
    
    //绿、黄、红
    if (value < 0.6*6) {
        CGContextSetRGBFillColor(context, 154/255.0, 205/255.0, 50/255.0, 1.0);
    } else if(value < 0.8*6) {
        CGContextSetRGBFillColor(context, 255/255.0, 193/255.0, 30/255.0, 1.0);
    } else {
        CGContextSetRGBFillColor(context, 238.0/255.0, 99.0/255.0, 99.0/255.0, 1.0);
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
    return max;
}

- (float)sumValue {
    
    float sum = 0;
    
    for (NSNumber *obj in _dataArr) {
        sum += [obj floatValue];
    }
    
    return sum;
    
}

//添加UILabel（集成）
- (UILabel*)addLabelFrame:(CGRect)frame text:(NSString*)string color:(UIColor *)textColor
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.text=string;
    label.textAlignment=NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:18];
    return label;
}

@end

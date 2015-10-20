//
//  MonthsView.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/1.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "DatesView.h"
#define WIDTH 60

@implementation DatesView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)configView:(NSInteger)count
{
    //标识每天
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d"];
    NSInteger day = [[formatter stringFromDate:[NSDate date]] integerValue];
    
    for (NSInteger i = count-1; i >= 0; i--) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30+i*WIDTH, 0, WIDTH, self.frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat:@"%li", (long)day--];
        label.font = [UIFont boldSystemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        UIImageView *lineView = [[UIImageView alloc]initWithFrame:CGRectMake(label.center.x-4, 0, label.frame.size.height/3, label.frame.size.height)];
        lineView.tag = i+100;
        [self addSubview:lineView];
        
        //换到上一个月
        if (day <= 0) {
            day = [[formatter stringFromDate:[NSDate date]] integerValue];
            NSTimeInterval secondsPerDay = day*24 * 60 * 60;
            NSDate *yesterMonth = [NSDate dateWithTimeInterval:-secondsPerDay sinceDate:[NSDate date]];
            day = [[formatter stringFromDate:yesterMonth] integerValue];
        }
    }

}

//设置竖线
- (UIImageView *)lineViewsFromTag:(NSUInteger)tag PercentValue:(float)percentValue
{
    UIImageView *centLineView = (UIImageView *)[self viewWithTag:tag+100];
    [self allLineImageViewToNil];
    [self setLineImageView:percentValue andImageVIew:centLineView];
    return nil;
}

//竖线图片
- (void)setLineImageView:(float)percentValue andImageVIew:(UIImageView *)lineView
{
    if (percentValue>0.6 && percentValue<0.8)
    {
        [lineView setImage:[UIImage imageNamed:@"yellowVerticalBar"]];
    }
    else if (percentValue > 0.8)
    {
        [lineView setImage:[UIImage imageNamed:@"redVerticalBar"]];
    }
    else
    {
        [lineView setImage:[UIImage imageNamed:@"greenVerticalBar"]];
    }
}


- (void)allLineImageViewToNil
{
    NSArray *subViews = [self subviews];
    for (id sView in subViews) {
        if ([sView isKindOfClass:[UIImageView class]]) {
            UIImageView *lineImageVIew = sView;
            if (lineImageVIew.image) {
                lineImageVIew.image = nil;
            }
        }
        
    }
}

@end

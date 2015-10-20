//
//  DaysCircularView.m
//  ECBLUE
//
//  Created by renchunyu on 14/11/24.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "DaysCircularView.h"
#define PI 3.1415926535
#define RADIUS ((self.frame.size.width)*1.5/5.0)
@implementation DaysCircularView

float radians(float degrees) {
    return degrees * M_PI;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,1,1,1,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    
    //数据(黄、红、绿)
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"0.4", @"0.3", @"0.3", nil];
    }

    NSArray *percentArr = [self arrOfPercent];
    NSArray *colorArray = [self arrOfColor];
    NSArray *labelArray = [self arrOfLabel:percentArr andColor:colorArray];
    
    //画扇形(YES)
    [self drawIng:context DataArray:_dataArray ColorArray:colorArray LabelArray:labelArray isArc:YES];

    //注释、标注(NO)
    [self drawIng:context DataArray:_dataArray ColorArray:colorArray LabelArray:labelArray isArc:NO];
    
//渲染
//    [self.layer renderInContext:context];
}

- (void)drawIng:(CGContextRef)context DataArray:(NSArray *)dataArray ColorArray:(NSArray *)colorArray LabelArray:(NSArray *)labelArray isArc:(BOOL)isArc
{
    float angle_end = 0.0;
    float angle_start = 0;
    float percent = 0.0;
    float width=self.frame.size.width;
    float height=self.frame.size.height;
    CGPoint centXY = CGPointMake(width*0.35, height*0.45);
    int zeroNum = 0;
    
    for (NSInteger i = 0; i < dataArray.count; i ++) {
        
        percent = [[dataArray objectAtIndex:i]floatValue];
        if (percent == 0) {
            zeroNum ++;
        }
        
        if (i == 0) {
            angle_end = radians(2*percent);
        }else{
            angle_start = angle_end;
            angle_end = angle_start+radians(2*percent);
        }
        
        if (isArc) {
            [self drawArc:context Point:centXY AngleStart:angle_start AngleEnd:angle_end Color:[colorArray objectAtIndex:i]];
        } else {
            [self drawRect:context andLabel:[labelArray objectAtIndex:i]];
        }
    }
    
    //数据全为0，就画一个灰圈圈
    if (isArc && (zeroNum==dataArray.count)) {
        [self drawArc:context Point:centXY AngleStart:0 AngleEnd:2*M_PI Color:COLOR_LIGHT_GRAY];
    }
}

//添加UILabel（集成）
- (UILabel*)addLabelFrame:(CGRect)frame text:(NSString*)string color:(UIColor *)textColor
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.text=string;
    label.textAlignment=NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15];
    return label;
}

//百分比注释
- (void)drawRect:(CGContextRef)context andLabel:(UILabel *)textLabel
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    CGRect rect = textLabel.frame;
    rect.origin.x = width*0.71;
    rect.origin.y += 0.005*height;
    rect.size.width = width*0.1;
    
    //分解RGB
    NSString *RGBValue = [NSString stringWithFormat:@"%@",textLabel.textColor];    //获得RGB值描述
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];                 //将RGB值描述分隔成字符串
    float red = [[RGBArr objectAtIndex:1] floatValue];    //红
    float green = [[RGBArr objectAtIndex:2] floatValue];  //绿
    float blue = [[RGBArr objectAtIndex:3] floatValue];   //蓝
    
    //矩形
    CGContextSetRGBFillColor(context, red, green, blue, 1.0);
    CGContextFillRect(context, rect);
    CGContextStrokePath(context);

    //文字
    NSDictionary* attrs =@{NSForegroundColorAttributeName:textLabel.textColor,
                           NSFontAttributeName:textLabel.font,
                           };
    [textLabel.text drawInRect:textLabel.frame withAttributes:attrs];
}

//画圆
- (void)drawArc:(CGContextRef)context Point:(CGPoint)point AngleStart:(float)angle_start AngleEnd:(float)angle_end Color:(UIColor *)color
{
    CGContextMoveToPoint(context, point.x, point.y);
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextAddArc(context, point.x, point.y, RADIUS,  angle_start, angle_end, 0);
    CGContextFillPath(context);
}

//数据
- (NSArray *)arrOfPercent{

    return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%.0f%%",[[_dataArray objectAtIndex:0] floatValue]*100],
                                    [NSString stringWithFormat:@"%.0f%%",[[_dataArray objectAtIndex:1] floatValue]*100],
                                    [NSString stringWithFormat:@"%.0f%%",[[_dataArray objectAtIndex:2] floatValue]*100],nil];
}

- (NSArray *)arrOfColor{
    
    return [NSArray arrayWithObjects:[UIColor colorWithRed:255/255.0 green:193/255.0 blue:30/255.0 alpha:1],
                                    [UIColor colorWithRed:238/255.0 green:99/255.0 blue:99/255.0 alpha:1],
                                    [UIColor colorWithRed:154/255.0 green:205/255.0 blue:50/255.0 alpha:1],nil];
}

- (NSArray *)arrOfLabel:(NSArray *)percentArr andColor:(NSArray *)colorArray{
    
    float width=self.frame.size.width;
    float height=self.frame.size.height;
    
    return [NSArray arrayWithObjects:
           [self addLabelFrame:CGRectMake(width*0.85, 0.65*height, 80, 16) text:[percentArr objectAtIndex:0] color:[colorArray objectAtIndex:0]],
           [self addLabelFrame:CGRectMake(width*0.85, 0.45*height, 80, 16) text:[percentArr objectAtIndex:1] color:[colorArray objectAtIndex:1]],
           [self addLabelFrame:CGRectMake(width*0.85, 0.25*height, 80, 16) text:[percentArr objectAtIndex:2] color:[colorArray objectAtIndex:2]],nil];
}


@end

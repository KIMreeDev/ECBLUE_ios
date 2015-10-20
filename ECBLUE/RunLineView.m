//
//  RunLineView.m
//  ECBLUE
//
//  Created by renchunyu on 14/12/24.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "RunLineView.h"


@implementation RunLineView

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self viewInit];
    }
    
    return self;

}


-(void)viewInit
{
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 60)];
    imageView.image=[UIImage imageNamed:@"run"];
    [self addSubview:imageView];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //设置目标
    UILabel *targetLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-35, 20, 30, 20)];
    targetLabel.textColor=COLOR_BLUE_NEW;
    targetLabel.font=[UIFont systemFontOfSize:8];
    targetLabel.text=[NSString stringWithFormat:@"%ld",(long)_target];
    [self addSubview:targetLabel];
    
    //划线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0/255.0, 153/255.0, 1204/255.0, 1.0);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
    CGContextMoveToPoint(context, 60, 40);
    CGContextAddLineToPoint(context, 60,50);
    CGContextAddLineToPoint(context, self.bounds.size.width-20,50);
    CGContextAddLineToPoint(context, self.bounds.size.width-20,40);
    CGContextStrokePath(context);
    
    //当前值
    UILabel *currentLabel=[[UILabel alloc] initWithFrame:CGRectMake(60+(self.bounds.size.width-80)*(float)_value/(float)_target, 20, 30, 20)];
    currentLabel.textColor=COLOR_BLUE_NEW;
    currentLabel.textAlignment=NSTextAlignmentCenter;
    currentLabel.font=[UIFont systemFontOfSize:8];
    currentLabel.text=[NSString stringWithFormat:@"%ld",(long)_value];
    [self addSubview:currentLabel];
    
    //标记
    CGContextSetRGBStrokeColor(context, 52/255.0, 189/255.0, 143/255.0, 1.0);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
    CGContextMoveToPoint(context, 75+(self.bounds.size.width-80)*(float)_value/(float)_target, 40);
    CGContextAddLineToPoint(context, 75+(self.bounds.size.width-80)*(float)_value/(float)_target,50);
    CGContextStrokePath(context);

}

@end

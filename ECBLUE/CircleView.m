//
//  CircleView.m
//  ECBLUE
//
//  Created by renchunyu on 14/12/17.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "CircleView.h"
#import <math.h>

@implementation CircleView

-(void)awakeFromNib
{


}



- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    /*画圆*/
    //边框圆
    
    //设置半径及宽度
    radius=0.35741*rect.size.height+0.5;
    width=0.087*rect.size.height;

    
    //114,200,235
    
    //画渐变，立体效果
    for (int i=0;i<80;i++) {
        
        int x=abs(40-i);
        
        if (_circleType==0) {
            
            CGContextSetRGBStrokeColor(context,(114-67*x/40.0)/255.0,(168-32*x/40.0)/255.0,(223-12*x/40.0)/255.0,1.0);//画笔线的颜色
            
        }else{
            CGContextSetRGBStrokeColor(context,255/255.0,(157-62*x/40.0)/255.0,0/255.0,1.0);
            
        }
        
        //0.7+0.3*x/40.0
        
        
        CGContextSetLineWidth(context, 2*width/80);//线的宽度
        CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.height/2, radius+i*width/80, 0, _percentage*2*M_PI, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathStroke); //绘制路径
        
        
    }
    

    
    
    

}

@end

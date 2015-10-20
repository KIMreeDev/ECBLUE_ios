//
//  PuffsView.m
//  ECBLUE
//
//  Created by JIRUI on 14/11/28.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "PuffsView.h"
#import "VerticalTopLabel.h"
@implementation PuffsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)configView:(float)maxValue
{
    //0 另外配置
    if (maxValue == 0) {
        VerticalTopLabel *label = [[VerticalTopLabel alloc] initWithFrame:CGRectMake(0, 9+4*((self.frame.size.height-15)/5), self.frame.size.width, (self.frame.size.height-15)/5)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = NSLocalizedString(@"0 puff", nil);
        label.font = [UIFont systemFontOfSize:9];
        label.textAlignment = NSTextAlignmentCenter;
        [label setVerticalAlignment:VerticalAlignmentMiddle];
        [self addSubview:label];
        return;
    }
    
    //最多5份，少于5时，跟随变动
    float maxNumber = 5;
    if (maxValue < 5) {
        maxNumber = maxValue;
    }
    for (int i = 0; i < maxNumber; i++) {
        VerticalTopLabel *label = [[VerticalTopLabel alloc] initWithFrame:CGRectMake(0, 9+(maxNumber-i-1)*((self.frame.size.height-15)/maxNumber), self.frame.size.width, (self.frame.size.height-15)/maxNumber)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat: NSLocalizedString(@"%.0f puffs", nil), maxValue*((i+1)/maxNumber)];
        label.font = [UIFont boldSystemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [label setVerticalAlignment:VerticalAlignmentTop];
        [self addSubview:label];
    }

}

@end

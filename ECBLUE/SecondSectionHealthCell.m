//
//  SecondSectionHealthCell.m
//  ECBLUE
//
//  Created by JIRUI on 14/11/21.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "SecondSectionHealthCell.h"

@implementation SecondSectionHealthCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configView
{
    CGRect rect = CGRectZero;
    rect.origin.x = 10;
    rect.origin.y = 40;
    rect.size.width = (kScreen_Width-20)*_percent;
    rect.size.height = 16;
    self.topImage.frame = rect;
    
    _topImage = [[UIImageView alloc]initWithFrame:rect];
    [_topImage setImage:[UIImage imageNamed:@"progress_top.png"]];
    [self addSubview:_topImage];
}

@end

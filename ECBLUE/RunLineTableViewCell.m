//
//  RunLineTableViewCell.m
//  ECBLUE
//
//  Created by renchunyu on 14/12/23.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "RunLineTableViewCell.h"

@implementation RunLineTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    if (IPHONE6) {
        _width=375.0;
    }else if(IPHONE6PLUS)
    {
        _width=414.0;
    }else{
        _width=320.0;
    }

}

- (void) configView
{
    _runLineView=[[RunLineView alloc] initWithFrame:CGRectMake(0, 0, _width, 80)];
    _runLineView.backgroundColor=COLOR_WHITE_NEW;
    _runLineView.target=_targetValue;
    _runLineView.value = _value;
    [self addSubview:_runLineView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}






@end

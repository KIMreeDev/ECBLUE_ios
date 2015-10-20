//
//  FirstSectionHealthCell.m
//  ECBLUE
//
//  Created by JIRUI on 14/11/21.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "FirstSectionHealthCell.h"

@implementation FirstSectionHealthCell

- (void)awakeFromNib {
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)isSmoked:(id)sender {

    if ([_delegate respondsToSelector:@selector(tapSwitchOfIsSmoke:)]) {
        
        UISwitch *swith = sender;
        [_delegate tapSwitchOfIsSmoke:swith];
    }
}

@end

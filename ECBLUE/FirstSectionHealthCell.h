//
//  FirstSectionHealthCell.h
//  ECBLUE
//
//  Created by JIRUI on 14/11/21.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FirstSectionHealthCellDelegate <NSObject>

- (void)tapSwitchOfIsSmoke:(UISwitch *)swit;

@end

@interface FirstSectionHealthCell : UITableViewCell
@property (weak, nonatomic) id<FirstSectionHealthCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *sinceDateLab;
@property (weak, nonatomic) IBOutlet UILabel *progressLab;
@property (weak, nonatomic) IBOutlet UILabel *increaseLab;
@property (weak, nonatomic) IBOutlet UISwitch *recoverSwith;

@end

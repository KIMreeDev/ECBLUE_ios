//
//  SleepTableViewCell.h
//  ECBLUE
//
//  Created by JIRUI on 14/12/11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SleepView.h"
@interface SleepTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *sleepImageView;
@property (weak, nonatomic) IBOutlet SleepView *sleepView;
@end

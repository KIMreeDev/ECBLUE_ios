//
//  SecondSectionHealthCell.h
//  ECBLUE
//
//  Created by JIRUI on 14/11/21.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondSectionHealthCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *percentLab;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImage;
@property (strong, nonatomic) UIImageView *topImage;
@property (assign) float percent;
- (void) configView;
@end

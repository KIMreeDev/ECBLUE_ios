//
//  MainViewController.h
//  ECBLUE
//
//  Created by renchunyu on 14/12/17.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IrregularImageView.h"
#import "CircleView.h"
#import "ACParallaxView.h"

@interface MainViewController : UIViewController<ACParallaxViewDelegate>

//同步数据
- (IBAction)dataUpdate:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

//头像
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
//名字显示
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//时间显示
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

//信息按钮
@property (weak, nonatomic) IBOutlet UIImageView *messageImageVIew;
//设置按钮
@property (weak, nonatomic) IBOutlet UIImageView *settingImageView;
//健康按钮
@property (weak, nonatomic) IBOutlet UIImageView *healthImageView;

//电量显示
@property (weak, nonatomic) IBOutlet UIImageView *battaryImageView;
//状态显示
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
//电子烟进度圈
@property (weak, nonatomic) IBOutlet IrregularImageView *cigImageView;
//计步器进度圈
@property (weak, nonatomic) IBOutlet IrregularImageView *runImageView;
@property (weak, nonatomic) IBOutlet CircleView *cigView;

@property (weak, nonatomic) IBOutlet CircleView *runView;

//吸烟圆环label
@property (weak, nonatomic) IBOutlet UILabel *smokingTitle;
@property (weak, nonatomic) IBOutlet UILabel *smokingUnit;
@property (weak, nonatomic) IBOutlet UILabel *smokingPuffs;
//跑步圆环
@property (weak, nonatomic) IBOutlet UILabel *runningTitle;
@property (weak, nonatomic) IBOutlet UILabel *runningUnit;
@property (weak, nonatomic) IBOutlet UILabel *runningSteps;

//背景
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet ACParallaxView *parallaxView;

@end

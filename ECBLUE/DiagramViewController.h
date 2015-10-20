//
//  DiagramViewController.h
//  ECBLUE
//
//  Created by renchunyu on 14/11/24.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaysCircularView.h"
#import "TimeLineView.h"


@interface DiagramViewController : UIViewController
@property (strong, nonatomic) TimeLineView *timelineView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//日期
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
//电子烟口数
@property (weak, nonatomic) IBOutlet UILabel *ecigPuffsLabel;
//尼古丁含量
@property (weak, nonatomic) IBOutlet UILabel *nicotineLabel;

//目前无法记录吸烟时长
//@property (strong, nonatomic) DaysCircularView *daysCircularVIew;


@end

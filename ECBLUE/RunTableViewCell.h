//
//  RunTableViewCell.h
//  ECBLUE
//
//  Created by JIRUI on 14/12/11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunView.h"

@interface RunTableViewCell : UITableViewCell
@property (strong, nonatomic)  RunView *runView;
@property (strong, nonatomic)  UIScrollView *scrollView;
//内容
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *timeArray;
@property (assign, nonatomic) float width;
- (void) configView;
@end

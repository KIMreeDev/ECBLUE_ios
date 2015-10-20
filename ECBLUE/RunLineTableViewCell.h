//
//  RunLineTableViewCell.h
//  ECBLUE
//
//  Created by renchunyu on 14/12/23.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunLineView.h"

@interface RunLineTableViewCell : UITableViewCell
@property (strong,nonatomic)RunLineView *runLineView;
@property (assign,nonatomic) float width;
//内容
@property (assign, nonatomic) NSInteger targetValue;
@property (assign, nonatomic) NSInteger value;
- (void) configView;

@end

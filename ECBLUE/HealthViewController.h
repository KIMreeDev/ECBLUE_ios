//
//  HealthViewController.h
//  ECBLUE
//
//  Created by renchunyu on 14/11/19.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunningAndHealthView.h"

@interface HealthViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (strong, nonatomic)  RunningAndHealthView *runningAndHealthView;
- (IBAction)changeView:(id)sender;
@end

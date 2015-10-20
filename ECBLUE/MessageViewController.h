//
//  MessageViewController.h
//  ECBLUE
//
//  Created by renchunyu on 14/11/19.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)changeContent:(id)sender;

@end

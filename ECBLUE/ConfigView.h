//
//  ConfigView.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/7.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailView.h"

@interface ConfigView : UIView

@property (assign,nonatomic) BOOL show;
- (instancetype)initWithType:(ConfigViewControllerType)type withFrame:(CGRect)rect;

@end

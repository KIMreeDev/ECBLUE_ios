//
//  DetailView.h
//  ECBLUE
//
//  Created by JIRUI on 15/1/7.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    SMOKING = 0,
    RUNNING,
    MESSAGE,
    HEALTH
} ConfigViewControllerType;

@protocol DetailViewDelegate <NSObject>
- (void) backToConfigView;
@end

@interface DetailView : UIView
@property (strong, nonatomic) id<DetailViewDelegate> delegate;
- (instancetype)initWithType:(ConfigViewControllerType)type withIndex:(NSUInteger)index withFrame:(CGRect)rect withData:(id)obj withTitle:(NSString *)title;

@end

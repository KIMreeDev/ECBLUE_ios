//
//  MonthsView.h
//  ECBLUE
//
//  Created by JIRUI on 14/12/1.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatesView : UIView
- (void)configView:(NSInteger)count;
- (UIImageView *)lineViewsFromTag:(NSUInteger)tag PercentValue:(float)percentValue;
@end

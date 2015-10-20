//
//  TimeLineView.h
//  ECBLUE
//
//  Created by renchunyu on 14/11/24.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineView : UIView{
    CGContextRef timeLineContext;
}
@property(strong,nonatomic) NSMutableArray *array;
- (void)addImageGesture;
-(float)getMaxValue:(NSMutableArray*)array;
- (void)changeDateToUpdateThePointImageView :(NSUInteger)tag;
@end

//
//  ACParallaxView.h
//  ecblue
//
//  Created by renchunyu on 14-7-8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "ACAttitude.h"

@class ACParallaxView;

@protocol ACParallaxViewDelegate <NSObject>
@optional
- (void)parallaxViewWillBeginParallax:(ACParallaxView*)parallaxView;
- (void)parallaxViewDidBeginParallax:(ACParallaxView*)parallaxView;
- (void)parallaxViewWillEndParallax:(ACParallaxView*)parallaxView;
- (void)parallaxViewDidEndParallax:(ACParallaxView*)parallaxView;
- (void)parallaxView:(ACParallaxView*)parallaxView didChangeRelativeAttitude:(ACAttitude)attitude;
@end

@interface ACParallaxView : UIView

@property (nonatomic, weak) id<ACParallaxViewDelegate> parallaxDelegate;
@property (nonatomic, assign, getter = isParallax) BOOL parallax;
@property (nonatomic, assign) BOOL refocusParallax;

@property (nonatomic, strong, readonly) CMMotionManager *sharedMotionManager;
@property (nonatomic, assign) ACAttitude referenceAttitude;
@property (nonatomic, assign, readonly) ACAttitude relativeAttitude;

@end

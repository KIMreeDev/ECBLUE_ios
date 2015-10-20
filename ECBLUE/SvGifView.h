//
//  SvGifView.h
//  darkblue
//
//  Created by renchunyu on 15-1-2.
//  Copyright (c) 2013 ecigarfan. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface SvGifView : UIView


/*
 * @brief desingated initializer
 */
- (id)initWithCenter:(CGPoint)center fileURL:(NSURL*)fileURL;

/*
 * @brief start Gif Animation
 */
- (void)startGif;

/*
 * @brief stop Gif Animation
 */
- (void)stopGif;

/*
 * @brief get frames image(CGImageRef) in Gif
 */
+ (NSArray*)framesInGif:(NSURL*)fileURL;


@end

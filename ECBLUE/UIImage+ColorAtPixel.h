//
//  UIImage+ColorAtPixel.h
//  ECBLUE
//
//  Created by renchunyu on 14/11/21.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 A category on UIImage that enables you to query the color value of arbitrary
 pixels of the image.
 */
@interface UIImage (ColorAtPixel)

- (UIColor *)colorAtPixel:(CGPoint)point;

@end

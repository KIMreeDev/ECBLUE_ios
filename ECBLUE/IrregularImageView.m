//
//  IrregularImageView.m
//  ECBLUE
//
//  Created by renchunyu on 14/11/22.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "IrregularImageView.h"
#import "UIImage+ColorAtPixel.h"

@interface IrregularImageView ()
{


}
@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;

@end


@implementation IrregularImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{

    [self resetHitTestCache];
}




#pragma mark - touch testing

- (BOOL)isAlphaVisibleAtPoint:(CGPoint)point forImage:(UIImage *)image
{
    // Correct point to take into account that the image does not have to be the same size
    CGSize iSize = image.size;
    CGSize bSize = self.bounds.size;
    point.x *= (bSize.width != 0) ? (iSize.width / bSize.width) : 1;
    point.y *= (bSize.height != 0) ? (iSize.height / bSize.height) : 1;
    
    UIColor *pixelColor = [image colorAtPixel:point];
    
    CGFloat alpha = 0.0;
    
    if ([pixelColor respondsToSelector:@selector(getRed:green:blue:alpha:)])
    {
        // available from iOS 5.0
        [pixelColor getRed:NULL green:NULL blue:NULL alpha:&alpha];
    }
    else
    {
        // for iOS < 5.0
        // In iOS 6.1 this code is not working in release mode, it works only in debug
        // CGColorGetAlpha always return 0.
        CGColorRef cgPixelColor = [pixelColor CGColor];
        alpha = CGColorGetAlpha(cgPixelColor);
    }
    return alpha >= kAlphaVisibleThreshold;
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Return NO if even super returns NO (i.e., if point lies outside our bounds)
    BOOL superResult = [super pointInside:point withEvent:event];
    if (!superResult) {
        return superResult;
    }
    
    // Don't check again if we just queried the same point
    // (because pointInside:withEvent: gets often called multiple times)
    if (CGPointEqualToPoint(point, self.previousTouchPoint)) {
        return self.previousTouchHitTestResponse;
    } else {
        self.previousTouchPoint = point;
    }
    
    BOOL response = NO;
    
    if (self.image == nil) {
        response = YES;
    }
    else if (self.image != nil) {
        response = [self isAlphaVisibleAtPoint:point forImage:self.image];
    }
    
    else {
        if ([self isAlphaVisibleAtPoint:point forImage:self.image]) {
            response = YES;
        } else {
            response = [self isAlphaVisibleAtPoint:point forImage:self.image];
        }
    }
    
    self.previousTouchHitTestResponse = response;
    return response;
}




- (void)resetHitTestCache
{
    self.previousTouchPoint = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
    self.previousTouchHitTestResponse = NO;
}





@end

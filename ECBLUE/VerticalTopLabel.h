//
//  VerticalTopLabel.h
//  ECBLUE
//
//  Created by JIRUI on 14/11/28.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface VerticalTopLabel : UILabel
{
@private
    VerticalAlignment _verticalAlignment;
}


@property (nonatomic) VerticalAlignment verticalAlignment;


@end

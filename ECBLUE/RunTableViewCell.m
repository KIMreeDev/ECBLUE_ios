//
//  RunTableViewCell.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/11.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//
#define CELL_X 60
#import "RunTableViewCell.h"
@implementation RunTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    
    if (IPHONE6) {
        _width=375.0;
    }else if(IPHONE6PLUS)
    {
        _width=414.0;
    }else{
        _width=320.0;
    }
    _width -= CELL_X;
    //NSLog(@"%@",NSStringFromCGRect(_scrollView.frame));
}

- (void) configView
{
    
    [self dataOfSleep];
//    _dataArray = [NSMutableArray arrayWithObjects:@(1),@(2),@(3),@(4),@(5),@(6),@(7), nil];
//    _timeArray = [NSMutableArray arrayWithObjects:@"00:00-00:00", @"00:00-00:00", @"00:00-00:00", @"00:00-00:00", @"00:00-00:00", @"00:00-00:00", @"00:00-00:00", nil];
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(CELL_X, 0, _width, 150)];
    _scrollView.contentSize=CGSizeMake(_dataArray.count*100+CELL_X, 150);
    _scrollView.showsHorizontalScrollIndicator=NO;
    [self addSubview:_scrollView];
    if (![_dataArray count]||![_timeArray count]) {
        return;
    }
    _runView=[[RunView alloc] init];
    _runView.backgroundColor=[UIColor clearColor];
    _runView.dataArr = _dataArray;
    _runView.timesArr = _timeArray;
    [_runView setFrame:CGRectMake(0, 0, _dataArray.count*100+CELL_X, 150)];
    [_scrollView addSubview:_runView];
}

- (void) dataOfSleep
{
    //分钟
    _dataArray = [NSMutableArray array];
    _timeArray = [NSMutableArray array];
    NSMutableArray *sleeps = [[EcblueDAO sharedManager] findAllOfSleep];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"startDate < %@ AND endDate >= %@", _date, _date];
    [sleeps filterUsingPredicate:predicate];
    
    if ([sleeps count]) {
        SleepModel *model = [sleeps lastObject];
        NSTimeInterval time = [model.endDate timeIntervalSinceDate:_date];
        
        //开始时间在昨天(h)
        [_dataArray addObject:@((long long int)time/3600.0)];
        NSString *endHour = [DateTimeHelper formatDate:model.endDate toString:@"HH:mm"];
        [_timeArray addObject:[NSString stringWithFormat:@"00:00-%@", endHour]];
        
        sleeps = [[EcblueDAO sharedManager] findAllOfSleep];
        predicate = [NSPredicate predicateWithFormat:@"startDate >= %@", _date];
        [sleeps filterUsingPredicate:predicate];
        for (NSInteger i = 0; i < sleeps.count; i ++) {
            SleepModel *model = [sleeps objectAtIndex:i];
            time = [model.endDate timeIntervalSinceDate:_date];
            //终止时间在后一天
            if(((long long int)time/3600.0)>24){
                time = [model.startDate timeIntervalSinceDate:_date];
                [_dataArray addObject:@((long long int)time/3600.0)];
                NSString *startHour = [DateTimeHelper formatDate:model.startDate toString:@"HH:mm"];
                [_dataArray addObject:[NSString stringWithFormat:@"%@-00:00",startHour]];
                break;
            }
            //在这天内
            [_dataArray addObject:@(model.minutes/60.0)];
            NSString *sHour = [DateTimeHelper formatDate:model.startDate toString:@"HH:mm"];
            NSString *eHour = [DateTimeHelper formatDate:model.endDate toString:@"HH:mm"];
            [_timeArray addObject:[NSString stringWithFormat:@"%@-%@", sHour, eHour]];
            
        }
        
    }else{
        NSTimeInterval time = 0;
        predicate = [NSPredicate predicateWithFormat:@"startDate >= %@", _date];
        sleeps = [[EcblueDAO sharedManager] findAllOfSleep];
        [sleeps filterUsingPredicate:predicate];
        for (NSInteger i = 0; i < sleeps.count; i ++) {
            SleepModel *model = [sleeps objectAtIndex:i];
            time = [model.endDate timeIntervalSinceDate:_date];
            //终止时间在后一天
            if(((long long int)time/3600.0)>24){
                time = [model.startDate timeIntervalSinceDate:_date];
                [_dataArray addObject:@((long long int)time/3600.0)];
                NSString *startHour = [DateTimeHelper formatDate:model.startDate toString:@"HH:mm"];
                [_dataArray addObject:[NSString stringWithFormat:@"%@-00:00",startHour]];
                break;
            }
            //在这天内
            [_dataArray addObject:@(model.minutes/60.0)];
            NSString *sHour = [DateTimeHelper formatDate:model.startDate toString:@"HH:mm"];
            NSString *eHour = [DateTimeHelper formatDate:model.endDate toString:@"HH:mm"];
            [_timeArray addObject:[NSString stringWithFormat:@"%@-%@", sHour, eHour]];
            
        }
    }

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

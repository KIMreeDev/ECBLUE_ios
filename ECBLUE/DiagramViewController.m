//
//  DiagramViewController.m
//  ECBLUE
//
//  Created by renchunyu on 14/11/24.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "DiagramViewController.h"
#import "PuffsView.h"
#import "DatesView.h"
#import "ConfigView.h"
#define WIDTH 60


@interface DiagramViewController (){
    NSUInteger data_index;
}

@property (weak, nonatomic) IBOutlet UIImageView *rightToDate;
@property (weak, nonatomic) IBOutlet UIImageView *leftToDate;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) PuffsView *puffsView;//口数标尺
@property (strong, nonatomic) DatesView *datesView;//日期
@property (strong, nonatomic) NSMutableArray *timeLineArray;
@property (strong, nonatomic) ConfigView *figView;
@end

@implementation DiagramViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=NSLocalizedString(@"Ecig", nil);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightSettingDown"] style:UIBarButtonItemStylePlain target:self action:@selector(configApp:)];
    
    //数据
    [self dataInit];
    
    //通知
    [self notifations];
    
    //手势
    [self gesturesOfviews];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_datesView) {
        return;
    }

    //折线图
    [self initTimeLineView];
    
    //标尺（单位）
    [self initPuffsView];
    
    //天（单位）
    [self initDatesView];
    
}

- (NSDate *)dateFromNow
{
    NSDictionary *dic = [DateTimeHelper getsEveryOneFromDate:[NSDate date]];
    NSInteger year = [[dic objectForKey:@"year"]integerValue];
    NSInteger month = [[dic objectForKey:@"month"]integerValue];
    NSInteger day = [[dic objectForKey:@"day"]integerValue];
    NSDate *date = [DateTimeHelper dateFromYear:year month:month day:day hour:0 minute:0 seconds:0];
    return date;
}

#pragma mark- 折线 、标尺 、月份
- (void)dataInit{
    _timeLineArray = [NSMutableArray array];
    NSMutableArray *smokes = [[EcblueDAO sharedManager] findAllOfSmoke];
    if ([smokes count]) {
        NSTimeInterval timInter = 29*24*60*60;
        NSDate *befor30 = [NSDate dateWithTimeInterval:-timInter sinceDate:[self dateFromNow]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"date >= %@", befor30];
        [smokes filterUsingPredicate:predicate];
        SmokeModel *model = [[SmokeModel alloc]init];
        model.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
        for (NSInteger i = 0; i < 30; i++) {
            timInter = i*24*60*60;
            NSDate *yesterday = [NSDate dateWithTimeInterval:-timInter sinceDate:[self dateFromNow]];
            model.date = yesterday;
            SmokeModel *smoke = [[EcblueDAO sharedManager] findSmokeByID:model];

            if (smoke) {
                [_timeLineArray addObject:[NSString stringWithFormat:@"%i", model.mouths]];
            }else{
                [_timeLineArray addObject:@"0"];
            }
            
            //结束
            if ([((SmokeModel *)[smokes firstObject]).date isEqualToDate:yesterday]) {
                break;
            }
        }
    }else{
        return;
    }
    
    //电子烟口数
    [_ecigPuffsLabel setText:[_timeLineArray lastObject]];
    
    //默认显示今天
    [_dayLabel setText:[DateTimeHelper formatDate:[NSDate date] toString:@"yyyy-MM-dd"]];

    _selectedDate = [NSDate date];
    data_index = [_timeLineArray count]-1;
}

//通知
- (void) notifations{
    
    //改变时间
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timePointTouch:) name:NOTIFICATION_TIMEPOINT_TOUCH object:nil];

}

- (void) gesturesOfviews{
    
    //添加本视图手势
    UITapGestureRecognizer *leftViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftDate:)];
    leftViewTap.numberOfTouchesRequired = 1; //手指数
    leftViewTap.numberOfTapsRequired = 1; //tap次数
    [_leftToDate addGestureRecognizer:leftViewTap];
    _leftToDate.userInteractionEnabled = YES;
    
    //添加本视图手势
    UITapGestureRecognizer *rightViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rightDate:)];
    rightViewTap.numberOfTouchesRequired = 1; //手指数
    rightViewTap.numberOfTapsRequired = 1; //tap次数
    [_rightToDate addGestureRecognizer:rightViewTap];
    _rightToDate.userInteractionEnabled = YES;
    
}

//配置界面
- (void)configApp:(UIBarButtonItem *)item
{

   self.navigationItem.rightBarButtonItem.enabled=NO;
    [_figView endEditing:YES];
    if (_figView) {
     
            [UIView animateWithDuration:0.4 animations:^{
                _figView.backgroundColor = [UIColor clearColor];
                _figView.frame = CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height);
            } completion:^(BOOL finished) {
                _figView = nil;
                
                self.navigationItem.rightBarButtonItem.image=[UIImage imageNamed:@"rightSettingDown"];
                self.navigationItem.rightBarButtonItem.enabled=YES;
                
                //更新尼古丁
                NSInteger nicotine = [[S_USER_DEFAULTS objectForKey:F_NICOTINE_VALUE]integerValue];
                NSInteger puffs = [_ecigPuffsLabel.text integerValue];
                float mg = (nicotine/300.0)*puffs;
                [_nicotineLabel setText:[NSString stringWithFormat:@"%.2f", mg]];
               
            }];
    
        
    } else {

        _figView = [[ConfigView alloc]initWithType:SMOKING withFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height)];
        [self.view addSubview:_figView];
        [UIView animateWithDuration:0.4 animations:^{
            _figView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        } completion:^(BOOL finished) {
            
             self.navigationItem.rightBarButtonItem.image=[UIImage imageNamed:@"rightSettingUp"];
            self.navigationItem.rightBarButtonItem.enabled=YES;

        }];
    
    }
}

- (void)initTimeLineView{
    
    _scrollView.contentSize=CGSizeMake(kScreen_Width, _scrollView.frame.size.height);
    _scrollView.bounces = NO;

    //视图大小
    _timelineView=[[TimeLineView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, _scrollView.bounds.size.height-20)];

    if ((_timeLineArray.count*WIDTH+50) >= kScreen_Width) {
        _scrollView.contentSize=CGSizeMake(_timeLineArray.count*WIDTH+60, _scrollView.frame.size.height);
        [_timelineView setFrame:CGRectMake(0, 0, _timeLineArray.count*WIDTH+60, _scrollView.bounds.size.height-20)];
    }
    _timelineView.array=_timeLineArray;
    [_scrollView addSubview:_timelineView];
    
    //默认背景（无数据，数据最值为0）
    if (([self getMaxValue:_timeLineArray]==0)||([_timeLineArray count]==0)) {
        _timelineView.backgroundColor=[UIColor colorWithRed:160/255.0 green:102/255.0 blue:211/255.0 alpha:0.1];
    }else{
        _timelineView.backgroundColor=[UIColor clearColor];
    }
    
    //折线图上的手势
    [_timelineView addImageGesture];
    
    //偏移到最右边
    int offsetX = _scrollView.contentSize.width-_scrollView.frame.size.width;
    if (offsetX>0) {
        CGPoint offsetPoint = CGPointMake(offsetX, 0);
        [_scrollView setContentOffset:offsetPoint];
    }
    
}

- (void)initPuffsView
{
    _puffsView = [[PuffsView alloc]initWithFrame:CGRectMake(0, _scrollView.frame.origin.y, 45, _scrollView.frame.size.height-20)];
    [_puffsView setBackgroundColor:[UIColor clearColor]];
    _puffsView.userInteractionEnabled = NO;
    [self.view addSubview:_puffsView];
    [_puffsView configView:[_timelineView getMaxValue:_timeLineArray]];
}

- (void)initDatesView
{
    _datesView = [[DatesView alloc]initWithFrame:CGRectMake(0, _scrollView.frame.size.height-30, _scrollView.contentSize.width, 30)];
    [_datesView setBackgroundColor:[UIColor colorWithRed:1/255.0 green:91/255.0 blue:134/255.0 alpha:1.0]];
    [_scrollView addSubview:_datesView];
    [_datesView configView:_timeLineArray.count];
    
    //更新日期中间的竖线
    float percent = [[_timeLineArray lastObject]integerValue]/[self getMaxValue:_timeLineArray];
    [_datesView lineViewsFromTag:_timeLineArray.count-1 PercentValue:percent];
}

// 通知
- (void)timePointTouch:(NSNotification *)notification {
    
    NSDictionary *dic = [notification userInfo];    
    NSUInteger index = [[dic objectForKey:@"index"]integerValue];
    float percent = [[dic objectForKey:@"percent"] floatValue];
    float offsett = [[dic objectForKey:@"offset"]floatValue];

    data_index = index;
    //更新选择的日期
    NSTimeInterval secondsPerDay = ([_timeLineArray count]-1-index)*24 * 60 * 60;
    NSDate *calDate = [NSDate dateWithTimeInterval:-secondsPerDay sinceDate:_selectedDate];
    
    [_dayLabel setText:[DateTimeHelper formatDate:calDate toString:@"yyyy-MM-dd"]];
    NSString *puffs = [_timeLineArray objectAtIndex:index];
    [_ecigPuffsLabel setText: puffs];
    
    NSInteger nicotine = [[S_USER_DEFAULTS objectForKey:F_NICOTINE_VALUE]integerValue];
    float mg = (nicotine/300.0)*[puffs integerValue];
    [_nicotineLabel setText:[NSString stringWithFormat:@"%.2f", mg]];
    
    //更新日期中间的竖线
    [_datesView lineViewsFromTag:index PercentValue:percent];
    
    if ((_scrollView.contentSize.width-offsett-kScreen_Width) > 30) {
        
        //偏移scrollView
        if ((_scrollView.contentOffset.x-offsett+30) > kScreen_Width) {
            
            [_scrollView setContentOffset:CGPointMake(offsett+kScreen_Width-60, 0) animated:YES];
        }
        else if(_scrollView.contentOffset.x-30 < offsett){
            
            [_scrollView setContentOffset:CGPointMake(offsett+30, 0) animated:YES];
        }
    }

}

- (void)selDateOfTheFirst:(NSNotification *)notification{
    
    NSDictionary *dic = [notification userInfo];
    NSUInteger index = [[dic objectForKey:@"index"]integerValue];
    float percent = [[dic objectForKey:@"percent"] floatValue];
    
    //更新日期中间的竖线
    [_datesView lineViewsFromTag:index PercentValue:percent];
}

//获取最大值
-(float) getMaxValue:(NSMutableArray*)array
{
    float maxValue = 0;
    for (int i=0; i<array.count; i++) {
        if ([[array objectAtIndex:i] integerValue]>maxValue) {
            maxValue=[[array objectAtIndex:i] integerValue];
        }
    }
    return maxValue;
}

- (void) leftDate:(UITapGestureRecognizer *)gesture{

    data_index = (data_index>0) ? (--data_index) : 0;
    [_timelineView changeDateToUpdateThePointImageView:data_index];
    
}

- (void) rightDate:(UITapGestureRecognizer *)gesture{
    
    data_index = (data_index==(_timeLineArray.count-1)) ? data_index : (++data_index);
    [_timelineView changeDateToUpdateThePointImageView:data_index];
}

/*
 //扇形统计图
 - (void)initDaysCircularView
 {
 _daysCircularVIew = [[DaysCircularView alloc]initWithFrame:CGRectMake(0, _scrollView.frame.origin.y+_scrollView.frame.size.height, kScreen_Width, self.view.frame.size.height-(_scrollView.frame.origin.y+_scrollView.frame.size.height))];
 _daysCircularVIew.backgroundColor = [UIColor whiteColor];
 [self.view addSubview:_daysCircularVIew];
 143/255.0 ,146/255.0 , 148/255.0, 1.0
 }
 
 
 //水平线(lable形式)
 - (void)horizontalLine {
 
 float height = _scrollView.frame.size.height-35;
 //最多5份，少于5时，跟随变动
 
 float maxValue = [self getMaxValue:_timeLineArray];
 
 float maxNumber = 5;
 if (maxValue < 5) {
 maxNumber = maxValue;
 }
 
 for (int i = 0; i < maxNumber; i++) {
 UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, _scrollView.frame.origin.y+15+(maxNumber-i-1)*(height/maxNumber), kScreen_Width-45, 0.5)];
 label.backgroundColor = [UIColor colorWithRed:201/255.0 green:215/255.0 blue:216/255.0 alpha:1];
 [self.view addSubview:label];
 }
 
 }
 
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

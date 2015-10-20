//
//  HealthViewController.m
//  ECBLUE
//
//  Created by renchunyu on 14/11/19.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "HealthViewController.h"
#import "FirstSectionHealthCell.h"
#import "SecondSectionHealthCell.h"
#import "ConfigView.h"

@interface HealthViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSInteger lessCigs;
}
@property (strong, nonatomic) NSArray *titleArr;
@property (strong, nonatomic) NSMutableArray *percentArray;
@property (strong, nonatomic) NSMutableArray *oneSectionArray;
@property (strong, nonatomic) ConfigView *figView;
@property (strong, nonatomic) NSString *sinceDate;
@property (strong, nonatomic) UISwitch *vitalsRecoverySwitch;

@end

@implementation HealthViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Health", nil);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightSettingDown"] style:UIBarButtonItemStylePlain target:self action:@selector(configApp:)];
    //row1
    _vitalsRecoverySwitch=[[UISwitch alloc] initWithFrame:CGRectMake(20, 169, 79, 40)];
    [_vitalsRecoverySwitch addTarget:self action:@selector(tapSwitchOfIsSmoke:) forControlEvents:UIControlEventTouchUpInside];
    _vitalsRecoverySwitch.onTintColor=COLOR_YELLOW_NEW;
    lessCigs = [self lessSmoke];
    
    //设置戒烟
    NSDate *nonDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
    _sinceDate = [NSString stringWithFormat:NSLocalizedString( @"SINCE %@", nil), [DateTimeHelper formatDate:nonDate toString:@"yy-MM-dd"]] ;

    //标题
    _titleArr = [NSArray arrayWithObjects:NSLocalizedString(@"NICOTINE OUT OF BODY", nil) ,
                                          NSLocalizedString(@"BLOOD OXYGENATION", nil) ,
                                          NSLocalizedString(@"HEART REJUVENATION", nil) ,
                                          NSLocalizedString(@"TASTE&SMELL", nil) ,
                                          NSLocalizedString(@"LUNG CAPACITY", nil) ,
                                          NSLocalizedString(@"STROKE RISK MITIGATION", nil) ,
                                          NSLocalizedString(@"LUNG CANCER RISK MITIGATION", nil) ,
                                          NSLocalizedString(@"OTHER CANCER RISK MITIGATION", nil) ,nil];
    
    //数据
    [self dataInitIsRegular:NO];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (_runningAndHealthView) {
        [_runningAndHealthView timerFired];
    }

}




//心跳
- (IBAction)changeView:(id)sender {
    
    UISegmentedControl *selectedBtn=(id)sender;
    if (selectedBtn.selectedSegmentIndex==0) {
        [_runningAndHealthView timerFired];
        [_runningAndHealthView removeFromSuperview];
        
    }else
    {
        if (_runningAndHealthView==nil) {
            _runningAndHealthView=[[RunningAndHealthView alloc] initWithFrame:_tabView.frame];
        }
        [self.view addSubview:_runningAndHealthView];
        
    }
    
    
}

- (void)dataInitIsRegular:(BOOL)flag {

    NSDate *oldDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
    NSInteger days = [DateTimeHelper daysFromDate:oldDate toDate:[NSDate date]];
    _percentArray = [self fromDaysGetPercent:days isRegular:flag];
    [self fromDayGetOneSecData:days isRegular:flag];
    
}

#pragma mark - 获取一个存有所有百分比的数组

- (float) regularDataOfFloat:(float)num
{
    NSInteger aveCigs = [[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY]integerValue];
    return num*((float)lessCigs/aveCigs);
}

- (NSMutableArray *)fromDaysGetPercent:(NSInteger)days isRegular:(BOOL)flag
{
    NSMutableArray *percents = [NSMutableArray array];
    if (!days) {
        for (int i = 0; i < 8; i ++) {
            [percents addObject:@"0.0"];
        }
        return percents;
    }
    
    if (days == 1) {
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:0.6]):0.6]];//暂时数据
    }
    else{
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];//暂时数据
    }
    double percentage = 0.0f;
    
    percentage = (-0.0108147*(days*days)+1.4903*days+49.5205)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:percentage]):percentage]];
    if (days >= 60) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];
    }
    
    percentage = (-3.24249*(1.0/100000)*(days*days)+0.10762*days+9.89241)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:percentage]):percentage]];
    if (days >= 1825) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];
    }
    
    percentage = (-0.143514*(days*days)+7.7248*days-2.58129)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:percentage]):percentage]];
    if (days >= 30) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];
    }
    
    percentage = (-0.00198746*(days*days)+0.858218*days+9.14377)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:percentage]):percentage]];
    if (days >= 180) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];
    }
    
    percentage = (4.88944*(1.0/100000000)*(days*days)+0.0270931*days+0.458119)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:percentage]):percentage]];
    if (days >= 3600) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];
    }
    
    percentage = (-2.98023*(1.0/10000000)*(days*days)+0.0108708*days+0.956522)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:percentage]):percentage]];
    if (days >= 18250) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];
    }
    
    percentage = (4.88944*(1.0/100000000)*(days*days)+0.0270931*days+0.458119)/100;
    [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:percentage]):percentage]];
    if (days >= 3650) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%f", flag?([self regularDataOfFloat:1.0]):1.0]];
    }

    return percents;
}

- (void) fromDayGetOneSecData:(NSInteger)day isRegular:(BOOL)flag
{
    double rejuvenation = -1.5201*(1.0/100000)*(day*day)+0.282878*day+0.151503;
    double rejuvenation2 = 0.0;
    if (day < 5475) {
        rejuvenation2 = -5.72205*(1.0/1000000)*(day*day)+0.0443926*day+10.9556;
    }
    else{
        rejuvenation = 99;
        if (day > 18250) {
            rejuvenation = 100;
        }
    }
    NSArray *arr =  [NSArray arrayWithObjects:@(rejuvenation), @(rejuvenation2), nil];
    
    _oneSectionArray = [NSMutableArray array];
    if (!flag) {
        [_oneSectionArray addObject:[NSString stringWithFormat:@"%.0f%%", [[arr objectAtIndex:0]floatValue]]];
        [_oneSectionArray addObject:[NSString stringWithFormat:@"+ %.0f Days", [[arr objectAtIndex:1]floatValue]]];
        
    } else {
        NSInteger aveCigs = [[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY]integerValue];
        if (aveCigs>0 && lessCigs<aveCigs) {
            [_oneSectionArray addObject:[NSString stringWithFormat:@"%.0f%%", [[arr objectAtIndex:1]floatValue]*((float)lessCigs/aveCigs)]];
            [_oneSectionArray addObject:[NSString stringWithFormat:@"+ %.0f Days", [[arr objectAtIndex:0]floatValue]*((float)lessCigs/aveCigs)]];
        }
        else{
            [_oneSectionArray addObject:[NSString stringWithFormat:@"%.0f%%", [[arr objectAtIndex:1]floatValue]]];
            [_oneSectionArray addObject:[NSString stringWithFormat:@"+ %.0f Days", [[arr objectAtIndex:0]floatValue]]];
        }
    }
    if (!day) {
        [_oneSectionArray removeAllObjects];
        [_oneSectionArray addObject:[NSString stringWithFormat:@" 0%%"]];
        [_oneSectionArray addObject:[NSString stringWithFormat:@"+ 0 Days"]];
    }
}

- (NSInteger)lessSmoke
{

    SmokeModel *smoke = [self smokeOfToday];
    
    NSString *nicoLev = [S_USER_DEFAULTS objectForKey:F_NICOTINE_RANGE];
    float nicoFlo = [[S_USER_DEFAULTS objectForKey:F_NICOTINE_VALUE]floatValue];
    float cigs = 0.0f;
    if ([nicoLev isEqualToString:@"Ultra Light(<0.5mg/cig.)"]) {
        cigs = smoke.mouths*(1.0/300)*nicoFlo/0.25;
    }
    else if([nicoLev isEqualToString:@"Light(0.5-0.7 mg/cig.)"]){
        cigs = smoke.mouths*(1.0/300)*nicoFlo/0.65;
    }
    else if([nicoLev isEqualToString:@"Regular(0.7-1.0 mg/cig.)"]){
        cigs = smoke.mouths*(1.0/300)*nicoFlo/0.85;
    }
    else if([nicoLev isEqualToString:@"Strong(>1.0 mg/cig.)"]){
        cigs = smoke.mouths*(1.0/300)*nicoFlo/1.0;
    }
    return cigs;
}

- (SmokeModel *) smokeOfToday
{
    NSDictionary *dic = [DateTimeHelper getsEveryOneFromDate:[NSDate date]];
    NSInteger year = [[dic objectForKey:@"year"]integerValue];
    NSInteger month = [[dic objectForKey:@"month"]integerValue];
    NSInteger day = [[dic objectForKey:@"day"]integerValue];
    NSDate *date = [DateTimeHelper dateFromYear:year month:month day:day hour:0 minute:0 seconds:0];
    
    SmokeModel *smokeModel = [[SmokeModel alloc] init];
    smokeModel.date = date;
    smokeModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    SmokeModel *localSmoke = [[EcblueDAO sharedManager] findSmokeByID:smokeModel];
    
    return localSmoke;
}

//配置界面
- (void)configApp:(UIBarButtonItem *)item
{
    if (_runningAndHealthView) {
        [_runningAndHealthView timerFired];
    }

    
    self.navigationItem.rightBarButtonItem.enabled=NO;
    
    // _figView 可以重用， 根据 show 字段判断view是否在界面显示
    if (_figView == nil) {
        _figView = [[ConfigView alloc]initWithType:HEALTH withFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height)];
        _figView.show = NO;
        [self.view addSubview:_figView];
    }
    [_figView endEditing:YES];
    if (_figView.show) {
        [UIView animateWithDuration:0.4 animations:^{
            _figView.backgroundColor = [UIColor clearColor];
            _figView.frame = CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height);
        } completion:^(BOOL finished) {
            _figView = nil;
            _figView.show = NO;
            self.navigationItem.rightBarButtonItem.image=[UIImage imageNamed:@"rightSettingDown"];
            self.navigationItem.rightBarButtonItem.enabled=YES;
            //设置戒烟
            NSDate *nonDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
            _sinceDate = [NSString stringWithFormat:NSLocalizedString( @"SINCE %@", nil), [DateTimeHelper formatDate:nonDate toString:@"yy-MM-dd"]] ;
            [self dataInitIsRegular:_vitalsRecoverySwitch.on];
            [_tabView reloadData];
        }];
    } else {
//        _figView = [[ConfigView alloc]initWithType:HEALTH withFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height)];
//        [self.view addSubview:_figView];
        [UIView animateWithDuration:0.4 animations:^{
            _figView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        } completion:^(BOOL finished) {
            self.navigationItem.rightBarButtonItem.image=[UIImage imageNamed:@"rightSettingUp"];
            self.navigationItem.rightBarButtonItem.enabled=YES;
            _figView.show = YES;
        }];
    }
}


#pragma mark - TableViewdelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //第二个节
    if (indexPath.section) {
        SecondSectionHealthCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SecondSectionHealthCell" owner:self options:nil] lastObject];
        [cell.titleLab setText:[_titleArr objectAtIndex:indexPath.row]];
        float percent = [[_percentArray objectAtIndex:indexPath.row]floatValue];
        [cell.percentLab setText:[NSString stringWithFormat:@"%.0f%%", percent*100]];
        cell.percent = percent;
        [cell configView];
        return cell;
    }

    //第一个节
    FirstSectionHealthCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FirstSectionHealthCell" owner:self options:nil] lastObject];
    [cell.sinceDateLab setText:_sinceDate];
    cell.delegate = (id)self;
    [cell.progressLab setText:[_oneSectionArray firstObject]];
    [cell.increaseLab setText:[_oneSectionArray lastObject]];
    [cell addSubview:_vitalsRecoverySwitch];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section>0 ? 8 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section>0 ? 75 : 250;
}


#pragma mark - FirstSectionHealthCell delegate

- (void)tapSwitchOfIsSmoke:(UISwitch *)swit {
    
    [self dataInitIsRegular:swit.on];
    [_tabView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

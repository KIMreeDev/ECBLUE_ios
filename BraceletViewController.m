//
//  BraceletViewController.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "BraceletViewController.h"
#import "RunTableViewCell.h"
#import "RunLineTableViewCell.h"
#import "ConfigView.h"
@interface BraceletViewController() <UITableViewDelegate, UITableViewDataSource>{
}

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *imageArray;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UIButton *monthButton;
@property (strong, nonatomic) NSDate *selDate;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *popView;
@property (nonatomic,assign) NSInteger versionNum;
@property (strong, nonatomic) ConfigView *figView;
@end

@implementation BraceletViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Sport", nil);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightSettingDown"] style:UIBarButtonItemStylePlain target:self action:@selector(configApp:)];
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    //数据
    [self dataInit];
    
    //初始化视图
    // [self viewsInit];
    
}


//配置界面
- (void)configApp:(UIBarButtonItem *)item
{
    self.navigationItem.rightBarButtonItem.enabled=NO;
    [_figView endEditing:YES];
    if (_figView) {
        //隐藏
        [UIView animateWithDuration:0.4 animations:^{
            _figView.backgroundColor = [UIColor clearColor];
            _figView.frame = CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height);
        } completion:^(BOOL finished) {
            _figView = nil;
            [_tableView reloadData];
            self.navigationItem.rightBarButtonItem.image=[UIImage imageNamed:@"rightSettingDown"];
            self.navigationItem.rightBarButtonItem.enabled=YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_ECI object:nil];
        }];
    } else {
        //显示
        _figView = [[ConfigView alloc]initWithType:RUNNING withFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height)];
        [self.view addSubview:_figView];
        [UIView animateWithDuration:0.4 animations:^{
            _figView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        } completion:^(BOOL finished) {
            self.navigationItem.rightBarButtonItem.image=[UIImage imageNamed:@"rightSettingUp"];
            self.navigationItem.rightBarButtonItem.enabled=YES;
        }];
    }
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (indexPath.row==3) ? 150 : 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row==0) {
        RunLineTableViewCell *RLcell = [[RunLineTableViewCell alloc] init];
        RLcell = [[[NSBundle mainBundle] loadNibNamed:@"RunLineTableViewCell" owner:self options:nil] lastObject];
        RLcell.targetValue = [[S_USER_DEFAULTS objectForKey:F_GOAL_RUNNING]integerValue];
        RLcell.value = [[_dataArray objectAtIndex:indexPath.row]integerValue];
        [RLcell configView];
        cell = RLcell;
        
    }else if(indexPath.row==3)
    {
        RunTableViewCell *RTcell = [[RunTableViewCell alloc] init];
        RTcell = [[[NSBundle mainBundle] loadNibNamed:@"RunTableViewCell" owner:self options:nil] lastObject];
        RTcell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row-1]];
        RTcell.date = _selDate;
        [RTcell configView];
        cell = RTcell;
        
    }else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.detailTextLabel.text=[_dataArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.textColor = COLOR_MIDDLE_GRAY;
        cell.imageView.image=[UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row-1]];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    [self popDatePicker:NO];
}

#pragma mark - 初始化
//数据
- (void)dataInit{
    
    _imageArray = [[NSArray alloc] initWithObjects:@"kilometre",@"calorie",@"sleep", nil];
    _dataArray = [NSMutableArray array];
    NSDate *date = [self dateFromNow];
    //日期默认为今天
    _selDate = date;
    //载入信息
    [self reloadLocalData];
}

- (void) reloadLocalData
{
    [_dataArray removeAllObjects];
    [_dateLabel setText:[DateTimeHelper formatDate:_selDate toString:@"yyyy-MM-dd"]];
    StepModel *stepModel = [[StepModel alloc]init];
    stepModel.date = _selDate;
    stepModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    StepModel *model = [[EcblueDAO sharedManager] findStepByID:stepModel];
    
    if (model) {
        [_dataArray addObject:[NSString stringWithFormat:@"%lu", (unsigned long)model.steps]];
        [_dataArray addObject:[NSString stringWithFormat:@"%.2f %@",  model.distances, NSLocalizedString(@"km", nil)]];
        [_dataArray addObject:[NSString stringWithFormat:@"%lu %@", (unsigned long)model.kcals, NSLocalizedString(@"cal", nil)]];
    } else {
        [_dataArray addObject:[NSString stringWithFormat:@"0"]];
        [_dataArray addObject:[NSString stringWithFormat:@"0.00 %@", NSLocalizedString(@"km", nil)]];
        [_dataArray addObject:[NSString stringWithFormat:@"0 %@", NSLocalizedString(@"cal", nil)]];
    }
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

- (IBAction)leftTouth:(id)sender
{
    NSTimeInterval timeInter = 24*60*60;
    _selDate = [NSDate dateWithTimeInterval:-timeInter sinceDate:_selDate];
    //刷新
    [self reloadLocalData];
    [_tableView reloadData];
}

- (IBAction)rightTouth:(id)sender
{
    NSTimeInterval timeInter = 24*60*60;
    NSDate *nextDate = [NSDate dateWithTimeInterval:timeInter sinceDate:_selDate];
    
    if (!([nextDate compare:[NSDate date]]==NSOrderedDescending)) {
        _selDate = nextDate;
        //刷新
        [self reloadLocalData];
        [_tableView reloadData];
    };
}


- (void)viewsInit{
    
    //隐藏线条
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    
    //    //日期按钮
    //    _monthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    _monthButton.frame = CGRectMake(0, 0, 80, 40);
    //    _monthButton.titleLabel.font = [UIFont systemFontOfSize:12];
    //    [_monthButton setTitleColor:COLOR_YELLOW_NEW forState:UIControlStateNormal];
    //    [_monthButton addTarget:self action:@selector(monthTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self datePickerInit];
}

- (void)monthTouch:(UIButton *)butt {
    
    [_datePicker setDate:_selDate animated:YES];
    [self popDatePicker:YES];
}

//出生、
-(void)datePickerInit
{
    //birthday date picker
    if (_datePicker == nil) {
        
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = COLOR_BACKGROUND;
        [_datePicker addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        
    }
    
    _popView=[[UIView alloc] init];
    _popView.frame=CGRectMake(0, kScreen_Height+20, kScreen_Width, 310);
    _popView.backgroundColor = COLOR_THEME;
    
    //按钮
    UIButton *sureButton, *cancelButton;
    sureButton=[UIButton buttonWithType:UIButtonTypeSystem];
    sureButton.frame = CGRectMake(kScreen_Width-110, 0, 110, 50);
    sureButton.backgroundColor=[UIColor clearColor];
    [sureButton setTitleColor:COLOR_WHITE_NEW forState:UIControlStateNormal];
    [sureButton setTitle:NSLocalizedString(@"Save", "") forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(saveData) forControlEvents:UIControlEventTouchUpInside];
    
    cancelButton=[UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake(0, 0, 110, 50);
    cancelButton.backgroundColor=[UIColor clearColor];
    [cancelButton setTitleColor:COLOR_WHITE_NEW forState:UIControlStateNormal];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", "") forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelData) forControlEvents:UIControlEventTouchUpInside];
    
    [_popView addSubview:sureButton];
    [_popView addSubview:cancelButton];
    //加dayDatePicker
    _datePicker.frame = CGRectMake(0, 50, kScreen_Width, 260);
}

- (void) saveData {
    
    _selDate = [_datePicker date];
    [_tableView reloadData];
    [self popDatePicker:NO];
}

- (void) cancelData {
    [self popDatePicker:NO];
}

-(void) popDatePicker:(BOOL)isPop{
    
    if (isPop) {
        
        //避免覆盖
        [_popView removeFromSuperview];
        [self.view addSubview:_popView];
        [_popView addSubview:_datePicker];
        
        
        //动画弹出
        [UIView animateWithDuration:0.3 animations:^{
            
            _popView.frame=CGRectMake(0, kScreen_Height-266, kScreen_Width, 266);
            
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
        
    } else {
        
        //动画隐藏
        [UIView animateWithDuration:0.3 animations:^{
            
            _popView.frame=CGRectMake(0, kScreen_Height+20, kScreen_Width, 310);
            
        } completion:^(BOOL finished) {
            [_datePicker removeFromSuperview];
            self.view.userInteractionEnabled = YES;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

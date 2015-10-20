//
//  MessageViewController.m
//  ECBLUE
//
//  Created by renchunyu on 14/11/19.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "MessageViewController.h"
#import "ConfigView.h"
@interface MessageViewController (){
    
    NSInteger runTimes;//跑步时间(分钟)
    NSInteger steps;//步数
    NSInteger kcal;//卡路里
    NSInteger sleepTimes;//睡眠时间 (分钟)
    
    float saveToday;//今天省钱
    float saveWeek;//一周省钱
    float saveMonth;//一个月省钱
}
//新增百分比数组（按顺序）
@property (strong, nonatomic) NSMutableArray *percentArray;
//新增恢复进度
@property (strong, nonatomic) NSString *progress;
//新增多活几天
@property (strong, nonatomic) NSString *increase;


@property (strong, nonatomic) NSArray *imageArray;
@property (strong, nonatomic) ConfigView *figView;
@property (strong, nonatomic) NSArray *contentArray;
@property (strong, nonatomic) NSDictionary *dic;
@property (assign, nonatomic) BOOL isSmoke;//判断在哪个界面
@end

@implementation MessageViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.navigationController.navigationBarHidden=NO;


}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Message", nil);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightSettingDown"] style:UIBarButtonItemStylePlain target:self action:@selector(configApp:)];
    
    //获取数据
    [self dataInit];
    
    NSLog(@"\n步数：%li, \n卡路里：%li, \n 睡眠时间(分钟)：%li, \n今天省钱：%.2f, \n一周省钱：%.2f, \n一个月省钱：%.2f, \n货币符号：%@",
          (long)steps, (long)kcal, (long)sleepTimes, saveToday, saveWeek, saveMonth,[S_USER_DEFAULTS objectForKey:F_CURRENCY] );
    
    //首次启动
    _contentArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"message.plist" ofType:nil]];
    //内容
     _dic=[_contentArray objectAtIndex:0];
    //图标
    _imageArray=[[NSArray alloc] initWithObjects:@"moneySave",@"moneySave",@"moneySave",nil];
    _isSmoke=YES;

    //隐藏无内容行
    _tableView.tableFooterView=[[UIView alloc] init];
    //调整分隔线位置
    _tableView.separatorInset = UIEdgeInsetsMake(0, -100, 0, 0);

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
            //刷新数据
            [self dataInit];
        }];
    } else {
        _figView = [[ConfigView alloc]initWithType:MESSAGE withFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kScreen_Height)];
        [self.view addSubview:_figView];
        [UIView animateWithDuration:0.4 animations:^{
            _figView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        } completion:^(BOOL finished) {
            self.navigationItem.rightBarButtonItem.image=[UIImage imageNamed:@"rightSettingUp"];
            self.navigationItem.rightBarButtonItem.enabled=YES;
        }];
    }
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID=@"sampleCellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = 1;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.highlightedTextColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.opaque = NO; // 选中Opaque表示视图后面的任何内容都不应该绘制
        label.backgroundColor = [UIColor clearColor];
        label.textColor=COLOR_MIDDLE_GRAY;
        [cell.contentView addSubview:label];
    }
    
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    CGRect cellFrame = [cell frame];
    cellFrame.origin = CGPointMake(0, 0);
    
    label.font=[UIFont italicSystemFontOfSize:13];
    
//   label.text =  [_contentArray objectAtIndex:indexPath.row];
    
    if (_isSmoke) {
        switch (indexPath.row) {
            case 0:
                

                if (saveToday<3.0&&saveToday>=0) {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"todayS"], nil) ,saveToday];
                }else if(saveToday>=3.0&&saveToday<8.0)
                {
                     label.text=[NSString stringWithFormat:NSLocalizedString([_dic objectForKey:@"todayM"], nil),saveToday];
                }else{
                    label.text=[NSString stringWithFormat:NSLocalizedString([_dic objectForKey:@"todayL"], nil),saveToday];
                }
                break;
            case 1:
                if (saveWeek<3&&saveWeek>=0) {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"weekS"], nil) ,saveWeek];
                }else if(saveWeek>=3&&saveWeek<8)
                {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"weekM"], nil) ,saveWeek];
                }else{
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"weekL"], nil) ,saveWeek];
                }

                break;
            case 2:
                if (saveMonth<3&&saveMonth>=0) {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"monthS"], nil) ,saveMonth];
                }else if(saveMonth>=3&&saveMonth<8)
                {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"monthM"], nil) ,saveMonth];
                }else{
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"monthL"], nil) ,saveMonth];
                }
                
                break;
                
            default:
                break;
        }
        
    }else{
        
        switch (indexPath.row) {
            case 0:
                if (sleepTimes<5&&sleepTimes>=0) {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"sleepS"], nil) ,sleepTimes];
                }else if(sleepTimes>=5&&sleepTimes<8)
                {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"sleepM"], nil) ,sleepTimes];
                }else{
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"sleepL"], nil) ,sleepTimes];
                }
                break;
            case 1:
                
                if (steps<5000&&steps>=0) {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"runS"], nil) ,steps];
                }else if(steps>=5000&&steps<10000)
                {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"runM"], nil) ,steps];
                }else{
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"runL"], nil) ,steps];
                }
                break;
            case 2:
                if (kcal<185&&kcal>=0) {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"calorieS"], nil) ,kcal];
                }else if(kcal>=185&&kcal<370)
                {
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"calorieM"], nil) ,kcal];
                }else{
                    label.text=[NSString stringWithFormat: NSLocalizedString([_dic objectForKey:@"calorieL"], nil) ,kcal];
                }
                break;
                
            default:
                break;
        }
    
    }
    


    label.frame = CGRectMake(60, 15, cellFrame.size.width-70, cellFrame.size.height-30);
    [label sizeToFit];
    if (label.frame.size.height > 56) {
        cellFrame.size.height = 60 + label.frame.size.height - 56;
    }
    else {
        cellFrame.size.height = 60;
    }
    [cell setFrame:cellFrame];
    
    

    //临时设定，看效果

    cell.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@",[_imageArray objectAtIndex:indexPath.row]]];
    
    return cell;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeContent:(id)sender {
 
    UISegmentedControl *selectedBtn=(id)sender;
    if (selectedBtn.selectedSegmentIndex==0) {
        
        _dic=[_contentArray objectAtIndex:0];
        _imageArray=[[NSArray alloc] initWithObjects:@"moneySave",@"moneySave",@"moneySave",nil];
        _isSmoke=YES;
        
    }else
    {

        _dic=[_contentArray objectAtIndex:1];
        _imageArray=[[NSArray alloc] initWithObjects:@"sleep",@"run",@"run",nil];
        _isSmoke=NO;
        
    }
    [_tableView reloadData];
    
}


//数据
- (void) dataInit
{
    //步数、卡路里（今天）
    NSDictionary *dic = [DateTimeHelper getsEveryOneFromDate:[NSDate date]];
    NSInteger year = [[dic objectForKey:@"year"]integerValue];
    NSInteger month = [[dic objectForKey:@"month"]integerValue];
    NSInteger day = [[dic objectForKey:@"day"]integerValue];
    NSDate *date = [DateTimeHelper dateFromYear:year month:month day:day hour:0 minute:0 seconds:0];
    StepModel *stepModel = [[StepModel alloc]init];
    stepModel.date = date;
    stepModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    StepModel *localStep = [[EcblueDAO sharedManager] findStepByID:stepModel];
    steps=0; kcal=0; sleepTimes = 0; runTimes = 0;
    if (localStep) {
        runTimes = localStep.minutes;
        steps = localStep.steps;
        kcal = localStep.kcals;
        sleepTimes = 24*60 - localStep.minutes;
    }
    //分钟
    NSMutableArray *sleeps = [[EcblueDAO sharedManager] findAllOfSleep];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"startDate < %@ AND endDate >= %@", date, date];
    [sleeps filterUsingPredicate:predicate];
    NSInteger sum = 0;
    if ([sleeps count]) {
        SleepModel *model = [sleeps lastObject];
        NSTimeInterval time = [model.endDate timeIntervalSinceDate:date];
        sum += (long long int)time/60;
        sleeps = [[EcblueDAO sharedManager] findAllOfSleep];
        predicate = [NSPredicate predicateWithFormat:@"startDate >= %@", date];
        [sleeps filterUsingPredicate:predicate];
        for (SleepModel *model in sleeps) {
            sum += model.minutes;
        }
        
    }else{
        predicate = [NSPredicate predicateWithFormat:@"startDate >= %@", date];
        [sleeps filterUsingPredicate:predicate];
        for (SleepModel *model in sleeps) {
            sum += model.minutes;
        }
    }
    sleepTimes = sum;
    
    
    //吸烟省钱、（今天、一周、一个月）
    NSMutableArray *smokes = [[EcblueDAO sharedManager] findAllOfSmoke];
    SmokeModel *smokeModel = [[SmokeModel alloc] init];
    smokeModel.date = date;
    smokeModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    SmokeModel *localSmoke = [[EcblueDAO sharedManager] findSmokeByID:smokeModel];
    saveToday = 0;
    //传统烟的费用
    NSInteger cigsPer = [[S_USER_DEFAULTS objectForKey:F_CIGARETTES_DAY]integerValue];  //支
    float pricePack = [[S_USER_DEFAULTS objectForKey:F_PRICE_PACK]floatValue]/20;//包
    float priceMl = [[S_USER_DEFAULTS objectForKey:F_PRICE_ML]floatValue]/10;//ml
    if (localSmoke) {

        float milliliter = localSmoke.mouths/300.0;
        saveToday = cigsPer*pricePack-priceMl*milliliter;
    }
    
    NSMutableArray *weekData = [NSMutableArray arrayWithArray:smokes];
    NSMutableArray *monthData = [NSMutableArray arrayWithArray:smokes];
    saveWeek = 0;
    saveMonth = 0;
    //一周、一月
    if ([weekData count]) {
        NSTimeInterval timeInterval = 6*24*3600;
        NSDate *beforeDate = [NSDate dateWithTimeInterval:-timeInterval sinceDate:date];
        predicate = [NSPredicate predicateWithFormat:
                                  @"date >= %@", beforeDate];
        [weekData filterUsingPredicate:predicate];
        sum = 0;
        for (SmokeModel *model in weekData) {
            sum += model.mouths;
        }
        float milliliter = sum/300.0;
        saveWeek = cigsPer*pricePack-priceMl*milliliter;

        timeInterval = 30*24*3600;
        beforeDate = [NSDate dateWithTimeInterval:-timeInterval sinceDate:date];
        predicate = [NSPredicate predicateWithFormat:
                                  @"date >= %@", beforeDate];
        [monthData filterUsingPredicate:predicate];
        sum = 0;
        for (SmokeModel *model in monthData) {
            sum += model.mouths;
        }
        milliliter = sum/300.0;
        saveMonth = cigsPer*pricePack-priceMl*milliliter;
    }
    
    //百分比数组
    NSDate *oldDate = [S_USER_DEFAULTS objectForKey:F_NON_SMOKING];
    NSInteger days = [DateTimeHelper daysFromDate:oldDate toDate:[NSDate date]];
    _percentArray = [self fromDaysGetPercent:days];
    
    //progress、increase
    [self fromDayGetOneSecData:days];
}


#pragma mark - 获取一个存有所有百分比的数组


- (NSMutableArray *)fromDaysGetPercent:(NSInteger)days
{
    NSMutableArray *percents = [NSMutableArray array];
    if (!days) {
        for (int i = 0; i < 8; i ++) {
            [percents addObject:@"0.0"];
        }
        return percents;
    }
    
    if (days == 1) {
        [percents addObject:[NSString stringWithFormat:@"%.2f", 0.6]];//暂时数据
    }
    else{
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];//暂时数据
    }
    double percentage = 0.0f;
    
    percentage = (-0.0108147*(days*days)+1.4903*days+49.5205)/100;
    [percents addObject:[NSString stringWithFormat:@"%.2f", percentage]];
    if (days >= 60) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];
    }
    
    percentage = (-3.24249*(1.0/100000)*(days*days)+0.10762*days+9.89241)/100;
    [percents addObject:[NSString stringWithFormat:@"%.2f", percentage]];
    if (days >= 1825) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];
    }
    
    percentage = (-0.143514*(days*days)+7.7248*days-2.58129)/100;
    [percents addObject:[NSString stringWithFormat:@"%.2f", percentage]];
    if (days >= 30) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];
    }
    
    percentage = (-0.00198746*(days*days)+0.858218*days+9.14377)/100;
    [percents addObject:[NSString stringWithFormat:@"%.2f", percentage]];
    if (days >= 180) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];
    }
    
    percentage = (4.88944*(1.0/100000000)*(days*days)+0.0270931*days+0.458119)/100;
    [percents addObject:[NSString stringWithFormat:@"%.2f", percentage]];
    if (days >= 3600) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];
    }
    
    percentage = (-2.98023*(1.0/10000000)*(days*days)+0.0108708*days+0.956522)/100;
    [percents addObject:[NSString stringWithFormat:@"%.2f", percentage]];
    if (days >= 18250) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];
    }
    
    percentage = (4.88944*(1.0/100000000)*(days*days)+0.0270931*days+0.458119)/100;
    [percents addObject:[NSString stringWithFormat:@"%.2f", percentage]];
    if (days >= 3650) {
        [percents removeLastObject];
        [percents addObject:[NSString stringWithFormat:@"%.2f", 1.0]];
    }
    
    return percents;
}

- (void) fromDayGetOneSecData:(NSInteger)day
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
    
    NSMutableArray *oneSectionArray = [NSMutableArray array];
    if (!day) {
        [oneSectionArray addObject:[NSString stringWithFormat:@"+ 0 Days"]];
        [oneSectionArray addObject:[NSString stringWithFormat:@" 0%%"]];
    }else{
        [oneSectionArray addObject:[NSString stringWithFormat:@"%.0f%%", [[arr objectAtIndex:0]floatValue]]];
        [oneSectionArray addObject:[NSString stringWithFormat:@"+ %.0f Days", [[arr objectAtIndex:1]floatValue]]];
    }
    
    _progress = [oneSectionArray firstObject];
    _increase = [oneSectionArray lastObject];
}



@end

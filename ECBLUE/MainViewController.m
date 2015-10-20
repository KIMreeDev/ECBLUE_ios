//
//  MainViewController.m
//  ECBLUE
//
//  Created by renchunyu on 14/12/17.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "HealthViewController.h"
#import "MessageViewController.h"
#import "BraceletViewController.h"
#import "DiagramViewController.h"
#import "NavigationAnimation.h"
#import "LeSelectedController.h"
#import "GetWeather.h"

enum
{
    MESSAGETAG=101,
    SETTINGTAG,
    HEALTHTAG,
    CIGTAG,
    RUNTAG,
    BLUETAG,
    BLUETAG2
};



@interface MainViewController ()<UINavigationControllerDelegate>
{
    UITapGestureRecognizer *messageTouch,*settingTouch,*healthTouch,*cigTouch,*runTouch, *blueTouch, *blueTouchImg;
    MBProgressHUD *progressHUD;
    MemoryModel *memory;
    BOOL isOpenBlue;
}
@property (strong,nonatomic) NavigationAnimation *navAnimation;
@property (strong,nonatomic) LeSelectedController *searchBlue;
@end

@implementation MainViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isOpenBlue = NO;
    //控制开机动画延迟时间
    [NSThread sleepForTimeInterval:0.0];
    
    //载入默认
    [DateTimeHelper defaultProperty];
    
    //载入个人信息
    [self localHeadImage];
    [self localNick];
    [self updatedTime];
    [self irRegularCircle];
//    _updateButton.enabled = NO;
    
    //通知
    [self notifications];
    
    //蓝牙
    [self initBlue];
    
    //增加导航动画
    _navAnimation=[NavigationAnimation new];
    self.navigationController.delegate=self;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    
    //设置导航栏颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:44/255.0 green:154/255.0 blue:207/255.0 alpha:1.0]];
    //标记及左右按键颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           COLOR_WHITE_NEW, NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0], NSFontAttributeName, nil]];
    //增加各手势
    messageTouch=[self addGesture:messageTouch inView:_messageImageVIew withTag:MESSAGETAG];
    settingTouch=[self addGesture:settingTouch inView:_settingImageView withTag:SETTINGTAG];
    healthTouch=[self addGesture:healthTouch inView:_healthImageView withTag:HEALTHTAG];
    cigTouch=[self addGesture:cigTouch inView:_cigImageView withTag:CIGTAG];
    runTouch=[self addGesture:runTouch inView:_runImageView withTag:RUNTAG];
    blueTouch = [self addGesture:blueTouch inView:_statusLable withTag:BLUETAG];
    blueTouchImg = [self addGesture:blueTouchImg inView:_battaryImageView withTag:BLUETAG2];
    //动态背景设置
    self.parallaxView.parallax = YES;
    self.parallaxView.parallaxDelegate = self;
    self.parallaxView.refocusParallax = YES;

    //加载本地数据
    [self reloadLocalData];
    
    //第一次启动
    [self configInfosIfFirstLaunch];
}

//从本地读取头像
- (void)localHeadImage{
    self.headImageView.image = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
    if ([manager fileExistsAtPath:fullPath]) {
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        [self.headImageView setImage:savedImage];
    }else{
        [self.headImageView setImage:[UIImage imageNamed:@"backgroundImage"]];
    }
    //圆角设置
    self.headImageView.layer.masksToBounds = YES;
    if (IPHONE6)
    {
        self.headImageView.layer.cornerRadius = 45;
    }
    else if (IPHONE6PLUS)
    {
        self.headImageView.layer.cornerRadius = 50;
    }
    else
    {
        self.headImageView.layer.cornerRadius = 35;// 3.5 、 4屏
    }

}

- (void) localNick
{
    //昵称
    NSMutableArray *dataValueArr = [NSMutableArray arrayWithArray:[S_USER_DEFAULTS objectForKey:F_PERSON_INFO]];
    _nameLabel.text = [dataValueArr firstObject];
    if([_nameLabel.text isEqualToString:@""]){
        NSInteger sex = [[dataValueArr objectAtIndex:2]integerValue];
        _nameLabel.text = sex?NSLocalizedString(@"Princess", nil):NSLocalizedString(@"Prince", nil);
    }
}

//第一次启动
- (void) configInfosIfFirstLaunch
{
    if (![S_USER_DEFAULTS boolForKey:F_OPENED_SECOND]) {
        //搜索蓝牙
        [[GGDiscover sharedInstance] startScanning];
        if (!_searchBlue) {
            _searchBlue = [[LeSelectedController alloc]init];
        }
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:_searchBlue];
        navi.navigationBar.barTintColor  = [UIColor colorWithRed:23/255.0 green:23/255.0 blue:23/255.0 alpha:1];
        [self presentViewController:navi animated:YES completion:^{
        }];
    }
}

#pragma mark - ACParallaxViewDelegate

- (void)parallaxView:(ACParallaxView*)parallaxView didChangeRelativeAttitude:(ACAttitude)attitude {
    
       // NSLog(@"这里一直都在跑");
}


//蓝牙
- (void) initBlue
{
    [[GGDiscover sharedInstance] setDiscoveryDelegate:(id)self];
}

//通知
- (void) notifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(characterDiscover:)
                                                 name:NOTIFICATION_CHARACTER_DISCOVER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(headImageChanged:)
                                                 name:NOTIFICATION_HEADIMAGE_CHANGE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nickChanged:)
                                                 name:NOTIFICATION_NICK_CHANGE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearSave:)
                                                 name:NOTIFICATION_CLEAR_SAVE
                                               object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(endApp:)
                                                  name:UIApplicationWillResignActiveNotification
                                                object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter ] addObserver:self
                                              selector:@selector(enteredApp:)
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:[UIApplication sharedApplication]];
    
}


//手势方法
-(UITapGestureRecognizer*)addGesture:(UITapGestureRecognizer*) gesture inView:(UIView*)view withTag:(NSInteger) tag
{
    
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
    gesture.numberOfTapsRequired=1;
    view.tag=tag;
    [view addGestureRecognizer:gesture];
    view.userInteractionEnabled = YES;
    return gesture;
}

//点击方法
-(void)touchAction:(id)sender
{
    UITapGestureRecognizer *tap=(id)sender;
    //未打开蓝牙提示
    if ((tap.view.tag==BLUETAG||tap.view.tag==BLUETAG2)&&(!isOpenBlue)) {
        [self blueNotOpenTip];
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        if (tap.view.tag==MESSAGETAG) {
            
            MessageViewController *messageVC=[[MessageViewController alloc] init];
            [self.navigationController pushViewController:messageVC animated:YES];
            
        }else if(tap.view.tag==SETTINGTAG)
        {
            
            SettingViewController *settingVC=[[SettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
            
        }else if(tap.view.tag==HEALTHTAG)
        {
            
            HealthViewController *healthVC=[[HealthViewController alloc] init];
            [self.navigationController pushViewController:healthVC animated:YES];
            
        }else if (tap.view.tag==CIGTAG) {
            
            DiagramViewController *cigVC=[[DiagramViewController alloc] init];
            [self.navigationController pushViewController:cigVC animated:YES];
            
        }else if(tap.view.tag==RUNTAG){
            
            BraceletViewController *runVC=[[BraceletViewController alloc] init];
            [self.navigationController pushViewController:runVC animated:YES];
            
        }else if(tap.view.tag==BLUETAG||tap.view.tag==BLUETAG2){
  
            //搜索蓝牙
            [[GGDiscover sharedInstance] startScanning];
            if (!_searchBlue) {
                _searchBlue = [[LeSelectedController alloc]init];
            }
            [self presentViewController:_searchBlue animated:YES completion:^{
                [self discoveredDidRefresh];
            }];
        }
    }];
}


//固件设置
- (void) setFirmwareVersion:(NSString *)name
{
    [S_USER_DEFAULTS setObject:name forKey:F_FIRMWARE_VERSION];
    [S_USER_DEFAULTS synchronize];
}

//请求电量
- (void) batteryShow
{
    [[GGDiscover sharedInstance]
     startRequestWithCmd:API_MEMORY_STATUS_CMD_HEADER
     index:0
     finishedBlock:^(GGDataConversion *requestManager) {
         memory = requestManager.memoryModel;
         
         //连接状态
         [self connectStatu];
         
         NSLog(@"成功收到数据对象。。\n运动的天数：%li\n睡眠几次%li\n吸烟几天%li\n电池电量%li%%\n", (long)memory.daysOfStep, (long)memory.timesOfSleep, (long)memory.daysOfSmoke, (long)memory.numbersOfBattery);
     }];
}

//储存蓝牙
- (void) addSavedDev:(NSString *) uuid
{
    
    NSArray			*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
    NSMutableArray	*newDevices		= nil;
    
    if (![storedDevices isKindOfClass:[NSArray class]]) {
        storedDevices = [NSArray arrayWithObject:uuid];
        /* Store */
        [S_USER_DEFAULTS setValue:uuid forKey:F_BLUE_UUID];
        [S_USER_DEFAULTS setObject:storedDevices forKey:U_STORED_DEVICES];
        [S_USER_DEFAULTS synchronize];
        return;
    }
    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    if (![newDevices containsObject:uuid]) {
        [newDevices addObject:uuid];
        [S_USER_DEFAULTS setValue:uuid forKey:F_BLUE_UUID];
        [S_USER_DEFAULTS setObject:(NSArray *)newDevices forKey:U_STORED_DEVICES];
        [S_USER_DEFAULTS synchronize];
    }
}

//更新数据的时间
- (void) updatedTime
{
    if ([S_USER_DEFAULTS objectForKey:F_UPDATE_TIME]) {
        NSString *info = [DateTimeHelper formatDate:[S_USER_DEFAULTS objectForKey:F_UPDATE_TIME] toString:@"yyyy-MM-dd HH:mm"];
        [_timeLabel setText:info];
    }else{
        [_timeLabel setText:@""];
    }
}

- (void) notConnectStatu
{
    [progressHUD hide:YES];
    progressHUD = nil;
//    _updateButton.enabled = NO; 
    _statusLable.text = NOT_CONNECTED_IDENTI;
    _statusLable.textColor = COLOR_WHITE_NEW;
    [_battaryImageView setImage:[UIImage imageNamed:@"bluetooth"]];
    [self setFirmwareVersion:NOT_CONNECTED_IDENTI];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NOT_CONNECTED object:nil userInfo:nil];
}

- (void) connectStatu
{
    _updateButton.enabled = YES;
    _statusLable.text = [NSString stringWithFormat:@"%li%%", (long)memory.numbersOfBattery];
    _statusLable.textColor = COLOR_WHITE_NEW;
    [_battaryImageView setImage:[UIImage imageNamed:@"battery"]];
}

//刷新主界面数据
- (void) reloadLocalData
{
    NSDictionary *dic = [DateTimeHelper getsEveryOneFromDate:[NSDate date]];
    NSInteger year = [[dic objectForKey:@"year"]integerValue];
    NSInteger month = [[dic objectForKey:@"month"]integerValue];
    NSInteger day = [[dic objectForKey:@"day"]integerValue];
    NSDate *date = [DateTimeHelper dateFromYear:year month:month day:day hour:0 minute:0 seconds:0];
    //查询smoke
    SmokeModel *smokeModel = [[SmokeModel alloc] init];
    smokeModel.date = date;
    smokeModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    SmokeModel *localSmoke = [[EcblueDAO sharedManager] findSmokeByID:smokeModel];
    if (localSmoke) {
        [_smokingPuffs setText:[NSString stringWithFormat:@"%lu", (unsigned long)localSmoke.mouths]];
    }else{
        [_smokingPuffs setText:@"0"];
    }
    
    //查询step
    StepModel *stepModel = [[StepModel alloc] init];
    stepModel.date = date;
    stepModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    StepModel *localStep = [[EcblueDAO sharedManager] findStepByID:stepModel];
    if (localStep) {
        [_runningSteps setText:[NSString stringWithFormat:@"%lu", (unsigned long)localStep.steps]];
    }else{
        [_runningSteps setText:@"0"];
    }
}

- (void) bluePowerOffTip
{
    NSString *title     =  NSLocalizedString( @"Bluetooth", nil);
    NSString *message   =  NSLocalizedString(@"Please turn on Bluetooth in Settings", nil) ;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    alertView.tag = 1000;
    [alertView show];
}

- (void) blueNotOpenTip
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:NSLocalizedString(@"Please turn on Bluetooth in Settings", nil)
                                                  delegate:(id)self
                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                         otherButtonTitles:nil];
    alert.tag = 1001;
    [alert show];
}


//更新两个圆环
- (void) irRegularCircle
{
    //设定类型(步数、吸烟)
    _cigView.circleType=0;
    _runView.circleType=1;
    
    NSDictionary *dic = [DateTimeHelper getsEveryOneFromDate:[NSDate date]];
    NSInteger year = [[dic objectForKey:@"year"]integerValue];
    NSInteger month = [[dic objectForKey:@"month"]integerValue];
    NSInteger day = [[dic objectForKey:@"day"]integerValue];
    NSDate *date = [DateTimeHelper dateFromYear:year month:month day:day hour:0 minute:0 seconds:0];
    
    //步数
    StepModel *stepModel = [[StepModel alloc]init];
    stepModel.date = date;
    stepModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    StepModel *localStep = [[EcblueDAO sharedManager] findStepByID:stepModel];
    float percent = 0;
    if (localStep) {
        percent = (float)(localStep.steps)/[[S_USER_DEFAULTS objectForKey:F_GOAL_RUNNING]integerValue];
    }
    _runView.percentage = percent;
    [_runView setNeedsDisplay];

    //吸烟
    SmokeModel *smokeModel = [[SmokeModel alloc] init];
    smokeModel.date = date;
    smokeModel.blueUUID = [S_USER_DEFAULTS valueForKey:F_BLUE_UUID];
    SmokeModel *localSmoke = [[EcblueDAO sharedManager] findSmokeByID:smokeModel];
    if (localSmoke) {
        percent = (float)(localSmoke.mouths)/[[S_USER_DEFAULTS objectForKey:F_PUFFS_LIMIT]integerValue];
    }
    _cigView.percentage = percent;
    [_cigView setNeedsDisplay];
}

#pragma mark - 通知的方法

//进入app
- (void)enteredApp:(NSNotification *)notification
{
    [[GGDiscover sharedInstance] startScanning];
}

//挂载
- (void)endApp:(NSNotification *)notification
{
    [[GGDiscover sharedInstance] cancelConnection];
}

//图像变动
- (void) headImageChanged: (NSNotification *)notification
{
    UIImage *image = notification.object;
    [self.headImageView setImage:image];
}

//昵称变动
- (void) nickChanged: (NSNotification *)notification
{
    NSString *text = notification.object;
    self.nameLabel.text = text;
}

//删除数据
- (void) clearSave: (NSNotification *)notification
{
    [self localHeadImage];
    [self localNick];
    [self reloadLocalData];
    [S_USER_DEFAULTS removeObjectForKey:F_UPDATE_TIME];
    [self updatedTime];
    [self irRegularCircle];
}

//发现特征
- (void) characterDiscover:(NSNotification *)notification
{
    NSDictionary *dic = [notification object];
    NSString *name = [dic objectForKey:@"name"];
    NSString *uuid = [dic objectForKey:@"uuid"];
    NSInteger characteristic = [[dic objectForKey:@"characteristic"]integerValue];//1是写、0是读 （写先于读获取）
    
    if (characteristic == 1) {
        //设置已连接(固件版本)
        [self setFirmwareVersion:name];
        
        //存储蓝牙uuid
        [self addSavedDev:uuid];
        
        //更新蓝牙列表
        [_searchBlue connectedSuccess];
        
    } else {
        //请求电量
        [self batteryShow];
        
        //第一次启动
        [_searchBlue pushPersonInfo];
        
    }
}

- (void) updateRunView
{
    
}

#pragma mark - GGDiscover delegate

//连接成功后
- (void) connectedSuccess
{
    NSLog(@"连接成功....");
}

//搜索后刷新
- (void) discoveredDidRefresh
{
    NSMutableArray *foundPeripherals = [NSMutableArray arrayWithArray:[[GGDiscover sharedInstance] foundPeripherals]];
    GGPeripheral *GGPeriphe = [[[GGDiscover sharedInstance]connectedUARTPeripherals]lastObject];
    if (GGPeriphe && ![foundPeripherals containsObject:GGPeriphe.peripheral]) {
        [foundPeripherals insertObject:GGPeriphe.peripheral atIndex:0];
    }
    _searchBlue.foundPeripherals = foundPeripherals;
    [_searchBlue changeViewToList];
}

//蓝牙关闭
- (void) discoveryStatePoweredOff
{
    isOpenBlue = NO;
    //更新蓝牙列表
    [_searchBlue connectedSuccess];
    [self notConnectStatu];
    NSLog(@"蓝牙关闭....");
}

//蓝牙打开
- (void) discoveryStatePoweredOn
{
    [[GGDiscover sharedInstance] startScanning];
    isOpenBlue = YES;
    NSLog(@"蓝牙打开....");
}

//连接失败
- (void) connectedFailure
{
    [self notConnectStatu];
    NSLog(@"连接失败....");
}

//取消连接
- (void) didCancelconnected
{
    [self notConnectStatu];
    [_searchBlue connectedFailure];
    NSLog(@"取消连接....");
}

#pragma mark -  UINavigationControllerDelegate
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    
    return _navAnimation;
    
}

#pragma mark - 同步数据

- (IBAction)dataUpdate:(id)sender {
    
    if (![[GGDiscover sharedInstance] isConnectted]) {
        [self touchAction:blueTouch];
        return;
    }
    
    
    _updateButton.enabled = NO;
    NSDate *updateTime = [S_USER_DEFAULTS objectForKey:F_UPDATE_TIME];
    if ([self isSameDayWithDate:updateTime]) {
        [self myProgressTask];
    }else{
        [self startProgress];
    }
    
}

- (BOOL) isSameDayWithDate:(NSDate *)date
{
    if (!date) {
        return NO;
    }
    NSDictionary *updateDic = [DateTimeHelper getsEveryOneFromDate:date];
    NSDictionary *todayDic = [DateTimeHelper getsEveryOneFromDate:[NSDate date]];
    return ([[updateDic objectForKey:@"year"]integerValue]==[[todayDic objectForKey:@"year"]integerValue])&&
           ([[updateDic objectForKey:@"month"]integerValue]==[[todayDic objectForKey:@"month"]integerValue])&&
           ([[updateDic objectForKey:@"day"]integerValue]==[[todayDic objectForKey:@"day"]integerValue]);
}

//progress
- (void) startProgress
{
    progressHUD = nil;
    progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:progressHUD];
    progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    progressHUD.delegate = (id)self;
    progressHUD.progress = 0;
    [progressHUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
}

- (void) myProgressTask {
    [[GGDiscover sharedInstance]
     startRequestWithCmd:API_MEMORY_STATUS_CMD_HEADER
     index:0
     finishedBlock:^(GGDataConversion *requestManager) {
         memory = nil;
         memory = requestManager.memoryModel;
         NSInteger sum = memory.daysOfStep + memory.daysOfSmoke + memory.timesOfSleep;

         dispatch_semaphore_t sema = dispatch_semaphore_create(0);
         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

         dispatch_async(queue, ^{
             //跑步
             [self stepsSynch:sema Sum:sum];
             
             //睡眠
             [self sleepSynch:sema Sum:sum];

             //吸烟
             [self smokeSynch:sema Sum:sum];
            
             //更新状态
             dispatch_async(dispatch_get_main_queue(), ^{
                 _updateButton.enabled = YES;
                 if (progressHUD&&(progressHUD.progress >= 1.0)) {
                     [progressHUD hide:YES];
                     progressHUD = nil;
                 }
                 [S_USER_DEFAULTS setObject:[NSDate date] forKey:F_UPDATE_TIME];
                 [S_USER_DEFAULTS synchronize];
                 [self updatedTime];
                 [self reloadLocalData];
                 [self irRegularCircle];
             });
         });
    }];
}

//同步跑步
- (void) stepsSynch:(dispatch_semaphore_t)sema Sum:(NSInteger)sum
{
    __block BOOL isModify = NO;
    for (NSInteger i = memory.daysOfStep-1; i >= 0; i --) {
        [[GGDiscover sharedInstance]
         startRequestWithCmd:API_STEP_DATA_CMD_HEADER
         index:i
         finishedBlock:^(GGDataConversion *requestManager) {
             StepModel *stepModel = requestManager.stepModel;
             StepModel *localModel = [[EcblueDAO sharedManager] findStepByID:stepModel];
             if (localModel) {
                 if ([[EcblueDAO sharedManager] modifyStep:stepModel]==0) {
                     progressHUD.progress += (i+1)/(float)sum;
                     isModify = YES;
                     dispatch_semaphore_signal(sema);
                 }
             } else {
                 if ([[EcblueDAO sharedManager] createStep:stepModel]==0) {
                     progressHUD.progress += 1.0/sum;
                     dispatch_semaphore_signal(sema);
                 }
             }
         }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        if (isModify) {
            break;
        }
    }
}

//同步睡眠
- (void) sleepSynch:(dispatch_semaphore_t)sema Sum:(NSInteger)sum
{
    __block BOOL isModify = NO;
    for (NSInteger i = memory.timesOfSleep-1; i >= 0; i --) {
        [[GGDiscover sharedInstance]
         startRequestWithCmd:API_SLEEP_DATA_CMD_HEADER
         index:i
         finishedBlock:^(GGDataConversion *requestManager) {
             SleepModel *sleepModel = requestManager.sleepModel;
             SleepModel *localModel = [[EcblueDAO sharedManager] findSleepByID:sleepModel];
             if (localModel) {
                 if ([[EcblueDAO sharedManager] modifySleep:sleepModel]==0) {
                     progressHUD.progress += (i+1)/(float)sum;
                     isModify = YES;
                     dispatch_semaphore_signal(sema);
                 }
             } else {
                 if ([[EcblueDAO sharedManager] createSleep:sleepModel]==0) {
                     progressHUD.progress += 1.0/sum;
                     if (progressHUD.progress >= 1.0) {
                         [progressHUD hide:YES];
                         progressHUD = nil;
                     }
                     dispatch_semaphore_signal(sema);
                 }
             }
         }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        if (isModify) {
            break;
        }
    }
}

//同步吸烟
- (void) smokeSynch:(dispatch_semaphore_t)sema Sum:(NSInteger)sum
{
    __block BOOL isModify = NO;
    for (NSInteger i = memory.daysOfSmoke-1; i >= 0; i --) {
        [[GGDiscover sharedInstance]
         startRequestWithCmd:API_SMOKE_DATA_CMD_HEADER
         index:i
         finishedBlock:^(GGDataConversion *requestManager) {
             SmokeModel *smokeModel = requestManager.smokeModel;
             SmokeModel *localModel = [[EcblueDAO sharedManager] findSmokeByID:smokeModel];
             if (localModel) {
                 if ([[EcblueDAO sharedManager] modifySmoke:smokeModel]==0) {
                     progressHUD.progress += (i+1)/(float)sum;
                     if (progressHUD.progress >= 1.0) {
                         [progressHUD hide:YES];
                         progressHUD = nil;
                     }
                     isModify = YES;
                     dispatch_semaphore_signal(sema);
                 }
             } else {
                 if ([[EcblueDAO sharedManager] createSmoke:smokeModel]==0) {
                     progressHUD.progress += 1.0/sum;
                     if (progressHUD.progress >= 1.0) {
                         [progressHUD hide:YES];
                         progressHUD = nil;
                     }
                     dispatch_semaphore_signal(sema);
                 }
             }
         }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        if (isModify) {
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  SettingViewController.m
//  ECBLUE
//
//  Created by renchunyu on 14/11/19.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "SettingViewController.h"
#import "PersonInfoViewController.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PersonInfoViewController *personInfoController;
@end

@implementation SettingViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"Setting", nil);
    [self notifications];
    
    //手势
    [self addGestureRecognizers];
    //载入头像
    [self localPicInfo];

}

- (void) notifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(headImageChanged:)
                                                 name:NOTIFICATION_HEADIMAGE_CHANGE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(characterDiscover:)
                                                 name:NOTIFICATION_CHARACTER_DISCOVER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notConnected:)
                                                 name:NOTIFICATION_NOT_CONNECTED
                                               object:nil];
}

//发现特征
- (void) characterDiscover:(NSNotification *)notification
{
    NSDictionary *dic = [notification object];
//    NSString *name = [dic objectForKey:@"name"];
//    NSString *uuid = [dic objectForKey:@"uuid"];
    NSInteger characteristic = [[dic objectForKey:@"characteristic"]integerValue];//1是写、0是读 （写先于读获取）
    
    if (characteristic == 1) {
    } else {
        [_tableView reloadData];
    }
}

//改变头像
- (void) headImageChanged: (NSNotification *)notification
{
    UIImage *image = notification.object;
    [self.headView setImage:image];
}

//断开连接
- (void) notConnected: (NSNotification *)notification
{
    [_tableView reloadData];
}

- (void)addGestureRecognizers
{
    //头像手势
    UITapGestureRecognizer *tapHeadView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeadViewGesture:)];
    tapHeadView.numberOfTapsRequired = 1;
    _headView.userInteractionEnabled = YES;
    [_headView addGestureRecognizer:tapHeadView];
}

//从本地读取头像
- (void)localPicInfo
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
    if ([manager fileExistsAtPath:fullPath]) {
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        [self.headView setImage:savedImage];
    }
    //圆角设置
    _headView.layer.masksToBounds = YES;
    if (IPHONE6)
    {
        _headView.layer.cornerRadius = 75;
    }
    else if (IPHONE6PLUS)
    {
        _headView.layer.cornerRadius = 95;
    }
    else
    {
        _headView.layer.cornerRadius = 50;// 3.5 、 4屏
    }
}

//点击头像
- (void)tapHeadViewGesture:(UIGestureRecognizer *)gesture
{
    _personInfoController = [[PersonInfoViewController alloc]initWithNibName:@"PersonInfoViewController" bundle:nil];
    [self.navigationController pushViewController:_personInfoController animated:YES];
    return;
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return section>0?2:2;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1;
    }
    return 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, kScreen_Width, 44.0)];
    customView.backgroundColor = COLOR_GRAY_BLUE;
    
    return customView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID=@"sampleCellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell=[[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.textLabel.textColor=COLOR_MIDDLE_GRAY;
        cell.detailTextLabel.textColor=COLOR_MIDDLE_GRAY;
    }

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text= NSLocalizedString(@"Smoke", nil) ;
                cell.detailTextLabel.text = [S_USER_DEFAULTS objectForKey:F_SMOKE_VERSION];
                break;
            case 1:
                cell.textLabel.text= NSLocalizedString(@"Firmware", nil) ;
                cell.detailTextLabel.text = NSLocalizedString([S_USER_DEFAULTS objectForKey:F_FIRMWARE_VERSION], nil) ;
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text= NSLocalizedString(@"Store", nil) ;
                break;
            case 1:
                cell.textLabel.text= NSLocalizedString(@"Clear data", nil) ;
                break;
            default:
                break;
        }
    }

    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
   
        //打开appStore商店
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[S_USER_DEFAULTS objectForKey:STORE_URL]]];
            //清除缓存
        }else if (indexPath.row==1){
            [self showActionSheet];
        }
        return;
        
    }
}

- (void)showActionSheet {
    // 创建时仅指定取消按钮
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:(id)self
                                              cancelButtonTitle:NSLocalizedString( @"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    // 逐个添加按钮（比如可以是数组循环）
    [sheet addButtonWithTitle: NSLocalizedString(@"The Local Data", nil) ];
    [sheet addButtonWithTitle: NSLocalizedString(@"Hand Ring Data", nil) ];
    [sheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    { return; }
    switch (buttonIndex)
    {
        case 1: {
            //清除本地
            [self clearCache];
            break;
        }
        case 2: {
            //清除手环
            [self clearHandRingData];
            break;
        }

    } 
}

#pragma mark  enter subview

-(void)clearCache
{
    
    dispatch_async(
                   dispatch_get_global_queue(0, 0)
                   , ^{
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       
                       
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       
                       
                       NSLog(@"files :%lu",(unsigned long)[files count]);
                       
                       
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }
                       //删除个人信息
//                       [S_USER_DEFAULTS removeObjectForKey:F_PERSON_INFO];
//                       [S_USER_DEFAULTS synchronize];
                       //删除本地手环数据
                       [[EcblueDAO sharedManager]removeAllInfo];
                       //恢复默认
//                       [DateTimeHelper defaultProperty];
                       //删除所有信息
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];});
}

-(void)clearCacheSuccess
{
//    [self removeHeadImage];
    [self showWithCustomView];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLEAR_SAVE object:nil];
}

- (void) removeHeadImage
{
    self.headView.image = nil;
    [self.headView setImage:[UIImage imageNamed:@"backgroundImage"]];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
    if ([manager fileExistsAtPath:fullPath]) {
        NSError *err;
        [manager removeItemAtPath:fullPath error:&err];
    }
}

- (void)clearHandRingData
{
   
    if ([[GGDiscover sharedInstance]isConnectted]) {
        [[GGDiscover sharedInstance]sendCmd:CMD_CLR_MEMORY model:nil finishedBlock:^(NSString *reciveData) {
            [self showWithCustomView];
        }];
    } else {
        UIAlertView  *noConnected=[[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString( @"No Bluetooth Connection", nil)
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Sure", @""), nil];
        noConnected.tag=102;
        [noConnected show];
    }

}

- (void)showWithCustomView {
    
    MBProgressHUD *mb = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mb];
    mb.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    mb.mode = MBProgressHUDModeCustomView;
    
    mb.delegate = (id)self;
    mb.labelText = NSLocalizedString(@"Completed", nil);
    
    [mb show:YES];
    [mb hide:YES afterDelay:1];
}
@end

//
//  ConfigView.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/7.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "ConfigView.h"
#import "DateTimeHelper.h"

@interface ConfigView(){
    ConfigViewControllerType viewType;
    NSArray *cellTitles;
    NSArray *dataKeys;
}
@property (strong, nonatomic) UIView *listView;
@property (strong, nonatomic) DetailView *detaiV;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *uploadButt;
@end
@implementation ConfigView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithType:(ConfigViewControllerType)type withFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];
    if (self) {
        viewType = type;
        
        //界面
        [self viewsInit];
        //数据
        [self dataInit];
    }
    
    
    return self;
}

- (void) viewsInit
{
    self.backgroundColor = [UIColor colorWithRed:145/255.0 green:146/255.0 blue:147/255.0 alpha:0.6];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characterDiscover:) name:NOTIFICATION_CHARACTER_DISCOVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notConnected:) name:NOTIFICATION_NOT_CONNECTED object:nil];
    
    //listView
    _listView= [[UIView alloc] initWithFrame:CGRectMake(15, kScreen_Height/7.0, kScreen_Width-30, kScreen_Height*5/7.0)];
    _listView.layer.cornerRadius=20;
    _listView.layer.masksToBounds = YES;
    _listView.backgroundColor=COLOR_WHITE_NEW;
    [self addSubview:_listView];
    
    //标题栏
    _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-30, 50)];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.backgroundColor=COLOR_YELLOW_NEW;
    _titleLabel.textColor=COLOR_WHITE_NEW;
    [_listView addSubview:_titleLabel];
    _titleLabel.text = NSLocalizedString(@"Configuration", nil) ;
    
    if (viewType == SMOKING) {
        _uploadButt = [UIButton buttonWithType:UIButtonTypeCustom];
        _uploadButt.frame = CGRectMake(_titleLabel.bounds.size.width-50, 3, 50, 50);
        [_uploadButt setImage:[UIImage imageNamed:@"syncBtn"] forState:UIControlStateNormal];
        [_uploadButt addTarget:self action:@selector(tapUpload) forControlEvents:UIControlEventTouchUpInside];
        [_listView addSubview:_uploadButt];
        if (![[GGDiscover sharedInstance]isConnectted]) {
            _uploadButt.enabled = NO;
        }
    }

    //表格
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 53, kScreen_Width-30, kScreen_Height*5/7.0-56) style:UITableViewStylePlain];
    _tableView.delegate=(id)self;
    _tableView.dataSource=(id)self;
    [_listView addSubview:_tableView];
    
    //隐藏表格线
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}

- (void) dataInit
{
    //数据键
    NSArray *primaryDataKeys = [NSArray arrayWithObjects:   @[F_NICOTINE_VALUE, F_PUFFS_LIMIT],
                                                            @[F_GOAL_RUNNING, F_GOAL_CALORIES],
                                                            @[F_CIGARETTES_DAY, F_CURRENCY, F_PRICE_PACK, F_PRICE_ML, F_NICOTINE_RANGE],
                                                            @[F_NON_SMOKING], nil];
    dataKeys = [primaryDataKeys objectAtIndex:viewType];
    
    //标题
    NSArray *primaryData = [NSArray arrayWithObjects:   @[NSLocalizedString(@"Nicotine Level(1-50mg/ml)", nil) , NSLocalizedString(@"Puffs Limit(1-1000)", nil) ],
                                                        @[NSLocalizedString(@"The Goal Of Running", nil) ,NSLocalizedString(@"The Goal Of Calory", nil) ],
                                                        @[NSLocalizedString(@"Cigarettes Smoked Per Day", nil) , NSLocalizedString(@"Currency Symbol", nil) , NSLocalizedString(@"Price Of Pack Of 20", nil) , NSLocalizedString(@"Price Of Smoke Oil(10ml)", nil) , NSLocalizedString(@"Nicotine Level", nil) ],
                                                        @[NSLocalizedString(@"Non Smoker Since", nil) ], nil];
    cellTitles = [primaryData objectAtIndex:viewType];

}

- (void)tapUpload
{
    //发送口数限制设置
    if (viewType == SMOKING) {
        _uploadButt.enabled = YES;
        id data = [S_USER_DEFAULTS objectForKey:[dataKeys objectAtIndex:1]];
        SmokeCntModel *cntModel = [[SmokeCntModel alloc]init];
        cntModel.times = [(NSString *)data integerValue];
        [[GGDiscover sharedInstance] sendCmd:CMD_SMOKE_CNT_HEADER model:cntModel finishedBlock:^(NSString *reciveData) {
            _uploadButt.enabled = YES;
            [self showWithCustomView];
        }];
    }
}

#pragma mark - 通知

- (void) characterDiscover:(NSNotification *)notification
{
    _uploadButt.enabled = YES;
}

- (void) notConnected:(NSNotification *)notification
{
    _uploadButt.enabled = NO;
}

- (void)showWithCustomView {
    
    MBProgressHUD *mb = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:mb];
    mb.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    mb.mode = MBProgressHUDModeCustomView;
    
    mb.delegate = (id)self;
    mb.labelText = NSLocalizedString(@"Completed", nil);
    
    [mb show:YES];
    [mb hide:YES afterDelay:1];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellTitles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId=@"sampleCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.textColor = COLOR_DARK_GRAY;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = [cellTitles objectAtIndex:indexPath.row];
   

    cell.detailTextLabel.textColor = COLOR_THEME_ONE;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
   

    
    id data = [S_USER_DEFAULTS objectForKey:[dataKeys objectAtIndex:indexPath.row]];
    
    if (viewType==HEALTH) {
        cell.detailTextLabel.text = [DateTimeHelper formatDate:data toString:@"yyyy-M-d"];
    }else{
          cell.detailTextLabel.text = data;
        
        }
            


    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self detailViewInitNeedIndexPath:indexPath];
    [UIView animateWithDuration:0.55 animations:^(){
        _detaiV.alpha = 1;
    }];

}

#pragma mark - DetailDelegate

- (void) backToConfigView
{
    [_tableView reloadData];
    [UIView animateWithDuration:0.55 animations:^{
        _detaiV.alpha = 0;
    } completion:^(BOOL finished) {
        [_detaiV removeFromSuperview];
        _detaiV = nil;
    }];
}

- (void) detailViewInitNeedIndexPath:(NSIndexPath *)indexPath
{
    id data = [S_USER_DEFAULTS objectForKey:[dataKeys objectAtIndex:indexPath.row]];
    _detaiV = [[DetailView alloc]initWithType:viewType withIndex:indexPath.row withFrame:_listView.frame withData:data withTitle:[cellTitles objectAtIndex:indexPath.row]];
    _detaiV.layer.cornerRadius=20;
    _detaiV.layer.masksToBounds=YES;
    _detaiV.backgroundColor = COLOR_WHITE_NEW;
    _detaiV.delegate = (id)self;
    _detaiV.alpha = 0;
    [self addSubview:_detaiV];
}

@end

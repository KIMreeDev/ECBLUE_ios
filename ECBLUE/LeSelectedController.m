//
//  LeSelectedController.m
//  Mistic
//

#import "LeSelectedController.h"
#import "PersonInfoViewController.h"

@interface LeSelectedController ()
{
    NSMutableArray *newDevies;
    PersonInfoViewController *personInfoController;
}
@end

@implementation LeSelectedController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray	*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
    newDevies = [NSMutableArray arrayWithArray:storedDevices];
    
    self.view.backgroundColor = COLOR_DARK_GRAY;
    _listView= [[UIView alloc] initWithFrame:CGRectMake(20, kScreen_Height/7.0, kScreen_Width-40, kScreen_Height*5/7.0)];
    _listView.backgroundColor=COLOR_WHITE_NEW;
    _tableView.backgroundColor=COLOR_BACKGROUND;
    _listView.layer.masksToBounds=YES;
    _listView.layer.cornerRadius=10;
    
    [self.view addSubview:_listView];
    _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-40, 50)];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.backgroundColor=COLOR_YELLOW_NEW;
    _titleLabel.textColor=COLOR_WHITE_NEW;
    [_listView addSubview:_titleLabel];
    

    
    //添加手势
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    _titleLabel.userInteractionEnabled = YES;
    tapView.numberOfTapsRequired = 1;
    [_titleLabel addGestureRecognizer:tapView];
    
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 50, kScreen_Width-40, kScreen_Height*5/7.0) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.tableFooterView=[[UIView alloc] init];


    if (_foundPeripherals.count==0) {
        _connectionActivityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _connectionActivityIndicator.frame=CGRectMake(140, 160, 30, 30);
        [_connectionActivityIndicator setCenter:CGPointMake(140, 160)];//指定进度轮中心点
        [_listView addSubview:_connectionActivityIndicator];
        [_connectionActivityIndicator startAnimating];
        _titleLabel.text=@"Devices";
    }else
    {
        [self changeViewToList];
    }
}


-(void)changeViewToList
{

    [_connectionActivityIndicator stopAnimating];
    [_connectionActivityIndicator removeFromSuperview];
    if (![[_listView subviews] containsObject:_tableView]) {
        [_listView addSubview:_tableView];
    }

    [_tableView reloadData];
}


- (UIButton *) buttonWithConnectedOrDisConnected:(NSIndexPath *)indexPath
{
    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    butt.frame = CGRectMake(_listView.frame.size.width-105, 10, 90, 30);
    [butt.titleLabel setFont:[UIFont systemFontOfSize:14]];
    butt.tag = indexPath.row+100;
    [butt addTarget:self action:@selector(connectOrDis:) forControlEvents:UIControlEventTouchUpInside];
    butt.layer.cornerRadius=6;
    [butt setTitleColor:COLOR_WHITE_NEW forState:UIControlStateNormal];
    butt.backgroundColor=COLOR_GREEN_NEW;
    //取得连接者
    NSMutableArray *connected = [[GGDiscover sharedInstance] connectedUARTPeripherals];
    CBPeripheral *conPerip = ((GGPeripheral *)[connected lastObject]).peripheral;
    
    //对应标题、颜色
    if ([conPerip isEqual:[_foundPeripherals objectAtIndex:indexPath.row]]) {
        [butt setTitle:@"disconnect" forState:UIControlStateNormal];
        butt.backgroundColor=COLOR_RED_NEW;
    }else{
        [butt setTitle:@"connect" forState:UIControlStateNormal];
        butt.backgroundColor=COLOR_GREEN_NEW;
    }
    
    return butt;
}

- (void) connectOrDis:(UIButton *)butt
{
    NSString *title = [butt titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"......"]) {
        return;
    }
    [butt setTitle:@"......" forState:UIControlStateNormal];
    [[GGDiscover sharedInstance] stopScanning];
    if ([title isEqualToString:@"disconnect"]) {
        [[GGDiscover sharedInstance] cancelConnection];
    } else {
        [[GGDiscover sharedInstance] connectPeripheral:[_foundPeripherals objectAtIndex:butt.tag-100]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foundPeripherals.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellId=@"sampleCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.backgroundColor=COLOR_BACKGROUND;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
  
    CBPeripheral *peripheral=[_foundPeripherals objectAtIndex:indexPath.row];
    cell.textLabel.textColor = COLOR_DARK_GRAY;
    [cell.textLabel setFont:[UIFont systemFontOfSize:22]];
    cell.textLabel.text=peripheral.name;
     cell.detailTextLabel.textColor=COLOR_MIDDLE_GRAY;
    [cell.detailTextLabel setFont:[UIFont italicSystemFontOfSize:11]];
    //cell.detailTextLabel.text=peripheral.identifier.UUIDString;
    cell.detailTextLabel.numberOfLines=0;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"  \n%@",peripheral.identifier.UUIDString];
    
    if (![newDevies containsObject:peripheral.identifier.UUIDString]) {
        cell.textLabel.textColor = COLOR_THEME_ONE;
        cell.detailTextLabel.textColor = COLOR_THEME_ONE;
    }
    
    UIButton *butt = [self buttonWithConnectedOrDisConnected:indexPath];
    [cell addSubview:butt];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [[GGDiscover sharedInstance] cancelConnection];
//    
//    [_connectionActivityIndicator removeFromSuperview];
//    [_listView addSubview:_connectionActivityIndicator];
//    [_connectionActivityIndicator startAnimating];
//    
//    _titleLabel.text=@"connectting...";
//    [[GGDiscover sharedInstance] connectPeripheral:[_foundPeripherals objectAtIndex:indexPath.row]];
   
}

-(void)connectedSuccess
{
    [_tableView reloadData];
}

-(void)connectedFailure
{
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapView:(UITapGestureRecognizer *)tapgesture
{
//    //第一次启动验证
//    if (![S_USER_DEFAULTS boolForKey:F_OPENED_SECOND]){
//        return;
//    }
//    
    [self dismissViewControllerAnimated:YES completion:^{
        [[GGDiscover sharedInstance] stopScanning];
    }];
}

- (void) pushPersonInfo
{
    if (self.navigationController.topViewController==personInfoController) {
        return;
    }
    if (![S_USER_DEFAULTS boolForKey:F_OPENED_SECOND]){
        personInfoController = nil;
        personInfoController = [[PersonInfoViewController alloc]initWithNibName:@"PersonInfoViewController" bundle:nil];
        [self.navigationController pushViewController:personInfoController animated:YES];
        return;
    }
}


@end

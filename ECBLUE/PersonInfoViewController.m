//
//  PersonInfoViewController.m
//  ECBLUE
//
//  Created by JIRUI on 14/12/8.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "PersonInfoViewController.h"
@interface PersonInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>{
    NSIndexPath *selectedIndex;
    NSInteger selectedRow;
}

@property (strong, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) IBOutlet UIImageView *headView;
@property (nonatomic, strong) UIView *popView;

//属性
@property (strong, nonatomic) NSArray *dataKeyArr;
@property (strong, nonatomic) NSMutableArray *dataValueArr;
@property (nonatomic, strong) UISegmentedControl *personSex;

//出生
@property (nonatomic, strong) UIDatePicker *birthdayDatePicker;

//身高与体重
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableDictionary *unitDic;
@property (nonatomic, strong) NSArray *unitArr;

//文本框
@property (nonatomic, strong) UITextField *textField;

@end

@implementation PersonInfoViewController

- (void)viewWillDisappear:(BOOL)animated{
    
    [S_USER_DEFAULTS setObject:_dataValueArr forKey:F_PERSON_INFO];
    [S_USER_DEFAULTS synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=NSLocalizedString(@"Personal Information", nil);
    selectedIndex = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characterDiscover:) name:NOTIFICATION_CHARACTER_DISCOVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notConnected:) name:NOTIFICATION_NOT_CONNECTED object:nil];
    [self addGestureRecognizers];
    
    //载入数据
    [self attributes];
    
    //载入照片
    [self localPicInfo];
    
    //初始化控件
    [self initControls];
}

//初始化
- (void)initControls{
    
    //文本框
    [self textFieldsInit];
    
    //性别
    [self sexSegmentedInit];
    
    //日期选择器
    [self birthdayPickerInit];
    
    //选择视图（身高、体重）
    [self pickViewInit];
    
    //上传数据
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(uploadInfo)];
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"syncBtn"]];
    
    //没有连接，则禁用上传
    if (![[GGDiscover sharedInstance]isConnectted]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
}

//属性
- (void) attributes{
    //键
    _dataKeyArr = [NSArray arrayWithObjects:NSLocalizedString(@"Nickname", nil),
                                            NSLocalizedString(@"Phone", nil),
                                            NSLocalizedString(@"Sex", nil),
                                            NSLocalizedString(@"Birthday", nil),
                                            NSLocalizedString(@"Height", nil),
                                            NSLocalizedString(@"Weight", nil), nil];
    
    //本地数据
    _dataValueArr = [NSMutableArray arrayWithArray:[S_USER_DEFAULTS objectForKey:F_PERSON_INFO]];
    
    //厘米、英寸
    _unitDic = [NSMutableDictionary dictionary];
    NSMutableArray *limi = [NSMutableArray array];
    NSMutableArray *yingchi = [NSMutableArray array];
    
    for (int i = 100; i < 200; i ++) {
        [limi addObject:@(i)];
        [yingchi addObject:@(roundf(i/2.54))];
    }
    [_unitDic setObject:limi forKey:KEY_LIMI];
    [_unitDic setObject:yingchi forKey:KEY_YINCHI];
    
    //公斤、磅
    NSMutableArray *jin = [NSMutableArray array];
    NSMutableArray *bang = [NSMutableArray array];
    for (int i = 30; i <= 149; i ++) {
        [jin addObject:@(i)];
        [bang addObject:@(roundf(i*2.2046226218488))];
    }
    [_unitDic setObject:jin forKey:KEY_GONJIN];
    [_unitDic setObject:bang forKey:KEY_BANG];
    
    //单位
    _unitArr = [NSArray arrayWithObjects:@[KEY_LIMI, KEY_YINCHI], @[KEY_GONJIN, KEY_BANG], nil];
}

- (void)addGestureRecognizers{
    
    //头像手势
    UITapGestureRecognizer *tapHeadView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeadViewGesture:)];
    tapHeadView.numberOfTapsRequired = 1;
    _headView.userInteractionEnabled = YES;
    [_headView addGestureRecognizer:tapHeadView];
    
}

//从本地读取头像
- (void)localPicInfo{
    
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
- (void)tapHeadViewGesture:(UIGestureRecognizer *)gesture{

    [self.view endEditing:YES];
    if (_popView.frame.origin.y < kScreen_Height) {
        [self popDatePicker:NO];
    }
    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet= [[UIActionSheet alloc] initWithTitle:nil
                                           delegate:(id)self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                             destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Taking Pictures", nil), NSLocalizedString(@"Photo Albums", nil), nil];
    } else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:(id)self
                                   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                              destructiveButtonTitle:nil
                                   otherButtonTitles:NSLocalizedString(@"Photo Albums", nil), nil];
    }
    sheet.tag = 101;
    [sheet showInView:self.view];
}

//文本框
- (void)textFieldsInit{
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(kScreen_Width-kScreen_Width*1.9/3.0-16, 15.0f, kScreen_Width*1.9/3.0, 30.0f)];
    [_textField setBorderStyle:UITextBorderStyleNone];
    _textField.backgroundColor = COLOR_WHITE_NEW;
    _textField.textAlignment = NSTextAlignmentRight;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    _textField.delegate = (id)self;
    _textField.keyboardType = UIKeyboardTypeNumberPad;

}

//性别
- (void)sexSegmentedInit{
    
    NSArray *buttonNames = [NSArray arrayWithObjects:NSLocalizedString(@"Male", nil),NSLocalizedString(@"Female", nil), nil];
    _personSex = [[UISegmentedControl alloc] initWithItems:buttonNames];
    [_personSex addTarget:self action:@selector(sex:) forControlEvents:UIControlEventValueChanged];
    _personSex.tintColor= COLOR_YELLOW_NEW;
    [_personSex setFrame:CGRectMake(kScreen_Width-15-100, 16, 100, 28)];
    [_personSex setSelectedSegmentIndex:[[_dataValueArr objectAtIndex:2] integerValue]];
    
}

//出生、
-(void)birthdayPickerInit
{
    //birthday date picker
    if (self.birthdayDatePicker == nil) {
        
        _birthdayDatePicker = [[UIDatePicker alloc] init];
        _birthdayDatePicker.backgroundColor = COLOR_BACKGROUND;
        [_birthdayDatePicker addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
        _birthdayDatePicker.datePickerMode = UIDatePickerModeDate;

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
    _birthdayDatePicker.frame = CGRectMake(0, 50, kScreen_Width, 260);
}

- (void) pickViewInit{
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, kScreen_Width, 260)];
    _pickerView.delegate=self;
    _pickerView.showsSelectionIndicator=YES;
    _pickerView.backgroundColor = COLOR_WHITE_NEW;
    
}


#pragma mark - 触发、

-(void)uploadInfo
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [S_USER_DEFAULTS setObject:_dataValueArr forKey:F_PERSON_INFO];
    //体重（公斤）
    NSRange range = [[_dataValueArr lastObject] rangeOfString:@" "];
    NSInteger weight = [[[_dataValueArr lastObject] substringToIndex:range.location]integerValue];
    NSString *weightKey = [[_dataValueArr lastObject] substringFromIndex:range.location+1];
    if ([weightKey isEqualToString:KEY_BANG]) {
        weight = roundf(weight*0.45359237);
    }
    //身高（厘米）
    range = [[_dataValueArr objectAtIndex:4] rangeOfString:@" "];
    NSInteger height = [[[_dataValueArr objectAtIndex:4] substringToIndex:range.location]integerValue];
    NSString *heightKey = [[_dataValueArr objectAtIndex:4] substringFromIndex:range.location+1];
    if ([heightKey isEqualToString:KEY_YINCHI]) {
        height = roundf(height*2.54);
    }
    //步长、RMR
    NSInteger age = roundf(([DateTimeHelper daysFromDate:[_dataValueArr objectAtIndex:3] toDate:[NSDate date]])/365.0);
    NSInteger sex = [[_dataValueArr objectAtIndex:2]integerValue];
    NSInteger stepLength = roundf(height*((float)75/170));
    stepLength = stepLength<30?30:(stepLength>150?150:stepLength);
    float rmr = sex?((10 * weight) + (6.25 * height) - (5 * age) + 5):((10 * weight) + (6.25 * height) - (5 * age) - 161);
    //组合数据
    PersonModel *personModel = [[PersonModel alloc]init];
    personModel.weight = weight;
    personModel.stride = stepLength;
    personModel.corr_rmr = 1.15 * rmr / 24 / 60 ;
    [S_USER_DEFAULTS synchronize];
    if ([[GGDiscover sharedInstance]isConnectted]) {
        [[GGDiscover sharedInstance] sendCmd:CMD_PARA_HEADER model:personModel finishedBlock:^(NSString *reciveData) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self textFieldShouldReturn:_textField];
            [self showWithCustomView];
            //第一次启动
            if (![S_USER_DEFAULTS boolForKey:F_OPENED_SECOND]){
                [[self.navigationController.viewControllers objectAtIndex:0]dismissViewControllerAnimated:YES completion:nil];
                [S_USER_DEFAULTS setBool:YES forKey:F_OPENED_SECOND];
            }
        }];
    }else{
        UIAlertView  *noConnected=[[UIAlertView alloc] initWithTitle:nil
                                                             message:NSLocalizedString( @"No Bluetooth Connection", nil)
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"Sure", @""), nil];
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

- (void)sex:(UISegmentedControl *)seg{
    
    NSInteger index = seg.selectedSegmentIndex;
    [_dataValueArr replaceObjectAtIndex:2 withObject:@(index)];
    
}

- (void)cancelData{
    
    [self popDatePicker:NO];
    
}

- (void)saveData{
    
    NSArray *popSubviews = [_popView subviews];
    
    //生日
    if ([popSubviews containsObject:_birthdayDatePicker]) {

        NSTimeInterval largerT = -5*365*24*3600;
        NSTimeInterval smalT = -65*365*24*3600;
        NSDate *selDate = _birthdayDatePicker.date;
        NSDate *largerD = [NSDate dateWithTimeIntervalSinceNow:largerT];
        NSDate *smalD = [NSDate dateWithTimeIntervalSinceNow:smalT];
        NSComparisonResult results = [selDate compare:largerD];
        if (results == NSOrderedDescending){
            selDate = largerD;
        }
        results = [selDate compare:smalD];
        if (results == NSOrderedAscending){
            selDate = smalD;
        }
        
        [_dataValueArr replaceObjectAtIndex:3 withObject:selDate];
    }
    
    //身高、体重
    if ([popSubviews containsObject:_pickerView]) {

        NSInteger unitIndex = 0;
        if ((selectedIndex.section==1&&selectedIndex.row==3))
            unitIndex = 1;
        
        NSInteger comp0 = [_pickerView selectedRowInComponent:0];
        NSInteger comp1 = [_pickerView selectedRowInComponent:1];
        NSString *strKey = [[_unitArr objectAtIndex:unitIndex]objectAtIndex:comp1];//单位键
        NSInteger value = [[[_unitDic objectForKey:strKey]objectAtIndex:comp0]integerValue];//值
        
        [_dataValueArr replaceObjectAtIndex:unitIndex+4 withObject:[NSString stringWithFormat:@"%li %@", (long)value, strKey]];
    }
    
    //隐藏
    [self popDatePicker:NO];
    
    //刷新
    [self.infoTableView reloadData];
}

- (void)localBirthData {
    
    //载入日期
    NSDate *localDate = [_dataValueArr objectAtIndex:3];
    [_birthdayDatePicker setDate:localDate animated:YES];
}

- (void)localPickerData: (NSIndexPath *)indexPath{
    
    NSInteger index = (indexPath.section>0?2:0)+indexPath.row;
    NSString *heightAndWeight = [_dataValueArr objectAtIndex:index];//身高或体重
    if ([heightAndWeight isEqualToString:@""]) {
        return;
    }
    
    //截取数据
    NSRange range = [heightAndWeight rangeOfString:@" "];
    NSString *strValue = [heightAndWeight substringToIndex:range.location];
    NSString *strKey = [heightAndWeight substringFromIndex:range.location+1];
    NSNumber *value = [NSNumber numberWithInteger:[strValue integerValue]];
    
    //获取index
    NSInteger comp0 = [[_unitDic objectForKey:strKey] indexOfObject:value];
    NSInteger comp1 = [[_unitArr objectAtIndex:index-4] indexOfObject:strKey];

    //滚动到数据
    selectedRow = comp1;
    [_pickerView selectRow:comp0 inComponent:0 animated:NO];
    [_pickerView selectRow:comp1 inComponent:1 animated:NO];
}

-(void) popDatePicker:(BOOL)isPop{
    
    if (isPop) {
        
        //避免覆盖
        [_popView removeFromSuperview];
        [self.view addSubview:_popView];
        
        if (selectedIndex.section==1&&selectedIndex.row>1) {
            [_popView addSubview:_pickerView];
        } else {
            [_popView addSubview:_birthdayDatePicker];
        }
        
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
            [_birthdayDatePicker removeFromSuperview];
            [_pickerView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
        }];
    }
}

//切换TextField
- (void)changeTextFields:(UITableView *)tableView andIndex:(NSIndexPath *)indexPath {
    
    _textField.text = nil;
    [_textField removeFromSuperview];
    _textField.keyboardType = (indexPath.row==0)?UIKeyboardTypeDefault:UIKeyboardTypeNumbersAndPunctuation;//键盘类型
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _textField.text = cell.detailTextLabel.text;
    _textField.tag = indexPath.row+100;
    [cell addSubview:_textField];
    [_textField becomeFirstResponder];
    
}
#pragma mark - 通知

- (void) notConnected:(NSNotification *)notification
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) characterDiscover:(NSNotification *)notification
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - UITextField delegate

//改动即存储
- (void)textChange:(NSNotification *)notification
{
    NSInteger index = _textField.tag-100;
    index = index?index:0;
    [_dataValueArr replaceObjectAtIndex:index withObject:_textField.text];
    if (index == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NICK_CHANGE object:_textField.text];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self.infoTableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    [_textField removeFromSuperview];
    
    [self.infoTableView reloadData];
    return YES;
    
}

#pragma mark - UIPickView delegate

//确定picker的轮子个数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 2;
    
}

//确定picker的每个轮子的item数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger number = 0;
    if (component == 0) {
        
        if ((selectedIndex.section==1) && (selectedIndex.row==2)) {
            
            number = selectedRow==0? [[_unitDic objectForKey:KEY_LIMI]count] : [[_unitDic objectForKey:KEY_YINCHI]count] ;//身高
            
        } else if((selectedIndex.section==1) && (selectedIndex.row==3)){
            
            number = selectedRow==0? [[_unitDic objectForKey:KEY_GONJIN]count] : [[_unitDic objectForKey:KEY_BANG]count] ;//体重
        }

        
    } else {
        
        number = 2;
    }
    
    return number;
}

//确定每个轮子的每一项显示什么内容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSInteger valueName = 0;
    if (component == 0) {
        
        if ((selectedIndex.section==1) && (selectedIndex.row==2)) {
            
            valueName = selectedRow==0? [[[_unitDic objectForKey:KEY_LIMI]objectAtIndex:row]integerValue] : [[[_unitDic objectForKey:KEY_YINCHI]objectAtIndex:row]integerValue] ;//身高数值
            
        } else if((selectedIndex.section==1) && (selectedIndex.row==3)){
            
            valueName = selectedRow==0? [[[_unitDic objectForKey:KEY_GONJIN]objectAtIndex:row]integerValue] : [[[_unitDic objectForKey:KEY_BANG]objectAtIndex:row]integerValue];//体重数值
        }
        
        
    } else {
        
        if ((selectedIndex.section==1) && (selectedIndex.row==2)) {
            
            return [[_unitArr objectAtIndex:0] objectAtIndex:row];//身高单位
            
        } else if((selectedIndex.section==1) && (selectedIndex.row==3)){
            
            return [[_unitArr objectAtIndex:1] objectAtIndex:row];//体重单位
        }
    }
    
    return [NSString stringWithFormat:@"%li",(long)valueName];
}

//监听轮子的移动
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 1) {
        
        selectedRow = row;
        
        //重点！更新第二个轮子的数据
        [self.pickerView reloadComponent:0];
    
    }

}

#pragma mark - UIActionSheet delegate
//actionsheet对话框
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 101) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
            }
        }
        else {
            if (buttonIndex == 1) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = (id)self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
    }
}

#pragma mark - UIImage picker delegte
//完成相片选择
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    picker = nil;
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //保存、显示头像
    [self saveImage:image withName:@"selectedImage.png"];
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
//    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    [self.headView setImage:image];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HEADIMAGE_CHANGE object:image];
}

//点击了相册选择中的取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    picker=nil;
}

//图片写入沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    
    UIImage *upOrientation = [self fixOrientation:currentImage];
    NSData *imageData = UIImageJPEGRepresentation(upOrientation, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:NO];
}

//图片方向为上
- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp)
        return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID=@"PersonCellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell==nil) {
        
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.textLabel.textColor=COLOR_MIDDLE_GRAY;
        cell.detailTextLabel.textColor=COLOR_MIDDLE_GRAY;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    //属性键
    cell.textLabel.text = [_dataKeyArr objectAtIndex:((indexPath.section>0?2:0)+indexPath.row)];
    
    //属性值
    if (!(indexPath.section==1 && (indexPath.row==0||indexPath.row==1))) {
        cell.detailTextLabel.text = [_dataValueArr objectAtIndex:((indexPath.section>0?2:0)+indexPath.row)];
    }
    else{
        if (indexPath.section==1 && indexPath.row==1) {
            cell.detailTextLabel.text = [DateTimeHelper formatDate:[_dataValueArr objectAtIndex:((indexPath.section>0?2:0)+indexPath.row)] toString:@"yyyy-MM-dd"];
        } else {
            //性别seg
            [cell addSubview:_personSex];
        }
       
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.view.userInteractionEnabled = NO;
    selectedIndex = indexPath;
    
    //显示文本框
    if (indexPath.section==0 && (_popView.frame.origin.y > kScreen_Height)) {
        [self changeTextFields:tableView andIndex:indexPath];
    }
    
    //隐藏日期view
    if (_popView.frame.origin.y < kScreen_Height) {
        [self popDatePicker:NO];
    }
    
    //弹出日期view
    if (indexPath.section==1&&indexPath.row==1) {
        
        [self popDatePicker:YES];
        [self localBirthData];
    }
    
    //弹出单位（身高、体重）
    if (indexPath.section==1&&indexPath.row>1) {
        
        [self popDatePicker:YES];
        [self localPickerData:indexPath];
        [self.pickerView reloadAllComponents];
    }
    
    if (!(indexPath.section==1 && indexPath.row>0)) {
        self.view.userInteractionEnabled = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return section>0?(section>1?1:4):2;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 25.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, kScreen_Width, 25.0)];
    customView.backgroundColor = COLOR_GRAY_BLUE;

    return customView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  DetailView.m
//  ECBLUE
//
//  Created by JIRUI on 15/1/7.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "DetailView.h"
#import "DateTimeHelper.h"
@interface DetailView()<UITextFieldDelegate>{
    ConfigViewControllerType dataType;
    NSUInteger dataIndex;
    id object;
    NSArray *dataKeys;
}
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *backLabel;
@property (strong, nonatomic) UILabel *saveLabel;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIPickerView *pickView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSMutableArray *pickerArray;
@property (strong, nonatomic) NSString *limitString;
@end

@implementation DetailView
- (instancetype)initWithType:(ConfigViewControllerType)type withIndex:(NSUInteger)index withFrame:(CGRect)rect withData:(id)obj withTitle:(NSString *)title{

    self = [super initWithFrame:rect];
    if (self) {
        dataType = type;
        dataIndex = index;
        object = obj;
        [self viewsInit];
        _titleLabel.text = title;
    }
    return self;
}

- (void) viewsInit
{
    [self titleViewInit];

    if (dataType==MESSAGE&&(dataIndex==1||dataIndex==4)) {
        
        [self pickerViewInit];
        //[self saveAndCancel];
    }
    else if(dataType==HEALTH){
        
        [self datePickInit];
    }
    else{
        
        [self textFieldInit];
    }
}

#pragma mark - 控件初始化

- (void) titleViewInit
{
    //标题栏
//    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-30, 50)];
//    _topLabel.textAlignment=NSTextAlignmentCenter;
//    _topLabel.backgroundColor=COLOR_YELLOW_NEW;
//    _topLabel.textColor=COLOR_WHITE_NEW;
//    [self addSubview:_topLabel];
    
    
    //标题
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor=COLOR_YELLOW_NEW;
    _titleLabel.textColor = COLOR_WHITE_NEW;
    [self addSubview:_titleLabel];
    

    //view手势
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    tapView.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapView];
    
    //数据键
    NSArray *primaryDataKeys = [NSArray arrayWithObjects:   @[F_NICOTINE_VALUE, F_PUFFS_LIMIT],
                                                            @[F_GOAL_RUNNING, F_GOAL_CALORIES],
                                                            @[F_CIGARETTES_DAY, F_CURRENCY, F_PRICE_PACK, F_PRICE_ML, F_NICOTINE_RANGE],
                                                            @[F_NON_SMOKING], nil];
    dataKeys = [primaryDataKeys objectAtIndex:dataType];
    
    NSArray *primaryLimits = [NSArray arrayWithObjects: @[@"1-50", @"1-1000"],
                                                        @[@"1-10000000", @"0-37080"],
                                                        @[@"0-40", @"0-40", @"0-40", @"0-40", @"0-40"],
                                                        @[@"0-40"], nil];
    _limitString = [[primaryLimits objectAtIndex:dataType]objectAtIndex:dataIndex];
}


-(void) saveAndCancel
{

    //存储
    _saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, self.frame.size.height-50, self.frame.size.width/2, 50)];
    _saveLabel.textAlignment = NSTextAlignmentCenter;
    _saveLabel.textColor = COLOR_WHITE_NEW;
    _saveLabel.text = @"Save";
    _saveLabel.font = [UIFont systemFontOfSize:15];
    _saveLabel.backgroundColor=COLOR_THEME_ONE;
    [self addSubview:_saveLabel];
    
    //返回键
    _backLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-50, self.frame.size.width/2.0, 50)];
    _backLabel.textAlignment = NSTextAlignmentCenter;
    _backLabel.textColor = COLOR_WHITE_NEW;
    _backLabel.font = [UIFont systemFontOfSize:15];
    _backLabel.text = @"Back";
    _backLabel.backgroundColor=COLOR_THEME_ONE;
    [self addSubview:_backLabel];
    
    
    //返回手势
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBack:)];
    _backLabel.userInteractionEnabled = YES;
    tapBack.numberOfTapsRequired = 1;
    [_backLabel addGestureRecognizer:tapBack];
    
    //存储手势
    UITapGestureRecognizer *tapSave = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSave:)];
    _saveLabel.userInteractionEnabled = YES;
    tapSave.numberOfTapsRequired = 1;
    [_saveLabel addGestureRecognizer:tapSave];
    

}




- (void) textFieldInit
{
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 70, self.frame.size.width-30, 40)];
    _textField.borderStyle=UITextBorderStyleRoundedRect;
    if (dataType==MESSAGE&&dataIndex!=0) {
        _textField.keyboardType = UIKeyboardTypeDecimalPad;
    }else{
        _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    _textField.delegate = (id)self;
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.text = (NSString *)object;
    [self addSubview:_textField];
    [_textField becomeFirstResponder];
}

- (void) pickerViewInit
{
    if (dataIndex == 1) {
        //货币
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"currency" ofType:@"plist"];
        NSArray *currencyArr = [NSArray arrayWithContentsOfFile:plistPath];
        _pickerArray=[[NSMutableArray alloc] init];
        for (NSString *curr in currencyArr) {
            [_pickerArray addObject:curr];
        }
    } else {
        //尼古丁水平
        _pickerArray=[[NSMutableArray alloc] initWithObjects:   @"Ultra Light(<0.5mg/cig.)",
                                                                @"Light(0.5-0.7 mg/cig.)",
                                                                @"Regular(0.7-1.0 mg/cig.)",
                                                                @"Strong(>1.0 mg/cig.)", nil];
    }
    
    _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 75, self.frame.size.width, 75+40+20)];
    _pickView.delegate = (id)self;
    _pickView.dataSource = (id)self;
    [self addSubview:_pickView];
    [_pickView selectRow:[_pickerArray indexOfObject:object] inComponent:0 animated:YES];
}

- (void) datePickInit
{
    _datePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(-15, 75, self.frame.size.width, 75+40+20)];
    _datePicker.datePickerMode=UIDatePickerModeDate;
    [_datePicker setDate:(NSDate *)object animated:YES];
    [self addSubview:_datePicker];
}

- (void)tapSave:(UITapGestureRecognizer *)tapgesture
{
    [_textField resignFirstResponder];
    id value = nil;
    if (_textField) {
        if (![_textField.text isEqualToString:object]) {
            if (dataType==MESSAGE&&dataIndex!=0) {
                value = (id)[NSString stringWithFormat:@"%.2f",[_textField.text floatValue]] ;
            }else{
                value = [self limitFromString:_textField.text];
                value = (id)[NSString stringWithFormat:@"%li",(long)[value integerValue]] ;
            }
            
        }
    }
    
    if (_pickView) {
        NSString *pickValue = [_pickerArray objectAtIndex:[_pickView selectedRowInComponent:0]] ;
        if (pickValue != object) {
            value = (id)pickValue;
        }
    }
    
    if (_datePicker) {
        BOOL isSameDay = [DateTimeHelper isSameDay:_datePicker.date date2:object];
        if (!isSameDay) {
            value = (id)_datePicker.date;
            if ([_datePicker.date compare:[NSDate date]]==NSOrderedDescending) {
                value = [NSDate date];
            }
        }
    }
    
    if (value) {
        NSString *key = [dataKeys objectAtIndex:dataIndex];
        if ([key isEqualToString:F_GOAL_RUNNING]) {
            NSInteger kcal = [self kcalAndSteps:value isRun:1];
            [S_USER_DEFAULTS setObject:[NSString stringWithFormat:@"%li",(long)kcal] forKey:F_GOAL_CALORIES];
            
        } else if([key isEqualToString:F_GOAL_CALORIES]){
            NSInteger steps = [self kcalAndSteps:value isRun:0];
            [S_USER_DEFAULTS setObject:[NSString stringWithFormat:@"%li",(long)steps] forKey:F_GOAL_RUNNING];
        }
        
        [S_USER_DEFAULTS setObject:value forKey:key];
        [S_USER_DEFAULTS synchronize];
    }
    
    //代理
    if ([_delegate respondsToSelector:@selector(backToConfigView)]) {
        [_delegate backToConfigView];
    }
}
- (NSInteger) kcalAndSteps:(NSString *)value isRun:(NSInteger)flag
{
    if (flag) {
        NSMutableArray *dataValueArr = [NSMutableArray arrayWithArray:[S_USER_DEFAULTS objectForKey:F_PERSON_INFO]];
        //体重（公斤）
        NSRange range = [[dataValueArr lastObject] rangeOfString:@" "];
        NSInteger weight = [[[dataValueArr lastObject] substringToIndex:range.location]integerValue];
        NSString *weightKey = [[dataValueArr lastObject] substringFromIndex:range.location+1];
        if ([weightKey isEqualToString:KEY_BANG]) {
            weight = roundf(weight*0.45359237);
        }
        NSInteger kcal = ((weight-15)*0.000693+0.005895)*[value integerValue];
        return kcal;
    } else {
        NSMutableArray *dataValueArr = [NSMutableArray arrayWithArray:[S_USER_DEFAULTS objectForKey:F_PERSON_INFO]];
        //体重（公斤）
        NSRange range = [[dataValueArr lastObject] rangeOfString:@" "];
        NSInteger weight = [[[dataValueArr lastObject] substringToIndex:range.location]integerValue];
        NSString *weightKey = [[dataValueArr lastObject] substringFromIndex:range.location+1];
        if ([weightKey isEqualToString:KEY_BANG]) {
            weight = roundf(weight*0.45359237);
        }
        NSInteger steps = [value integerValue]/((weight-15)*0.000693+0.005895);
        return steps;
    }

}

- (void)tapBack:(UITapGestureRecognizer *)tapgesture
{
    [_textField resignFirstResponder];

    //代理
    if ([_delegate respondsToSelector:@selector(backToConfigView)]) {
        [_delegate backToConfigView];
    }
}

//范围
- (NSString *) limitFromString:(NSString *)string
{
    float value = [string floatValue];
    NSRange range =[_limitString rangeOfString:@"-"];
    float minValue = [[_limitString substringToIndex:range.location] floatValue];
    float maxValue = [[_limitString substringFromIndex:range.location+1] floatValue];
    
    if (value > maxValue) {
        return [NSString stringWithFormat:@"%.0f", maxValue];
    }
    if (value < minValue) {
        return [NSString stringWithFormat:@"%.0f", minValue];
    }
    return string;
}

- (void)tapView:(UITapGestureRecognizer *)tapgesture
{
    
    [_textField resignFirstResponder];
    [self tapSave:tapgesture];
}

#pragma mark -  UIpickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [_pickerArray count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [_pickerArray objectAtIndex:row];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

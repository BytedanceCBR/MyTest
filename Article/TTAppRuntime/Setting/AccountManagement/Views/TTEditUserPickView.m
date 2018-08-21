//
//  TTEditUserPickView.m
//  Article
//
//  Created by wangdi on 2017/3/30.
//
//

#import "TTEditUserPickView.h"

#define kTopViewHeight 40

@interface TTEditUserPickView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, weak) SSThemedView *topView;
@property (nonatomic, weak) SSThemedButton *completionBtn;
@property (nonatomic, weak) SSThemedButton *cancelBtn;
@property (nonatomic, weak) SSThemedView *topViewBottomLine;
@property (nonatomic, weak) UIPickerView *areaPickerView;
@property (nonatomic, weak) UIDatePicker *birthdayDatePickder;

@property (nonatomic, weak) SSThemedView *coverView;

@property (nonatomic, assign) TTEditUserPickViewType type;
@property (nonatomic, copy) void (^completion)(NSArray *textArray,TTEditUserPickViewType type);

@property (nonatomic, copy) NSString *currentBirthday;
@property (nonatomic, copy) NSString *currentProvince;
@property (nonatomic, copy) NSString *currentCity;

@property (nonatomic, assign) NSInteger currentLeftIndex;

@end

@implementation TTEditUserProvinceModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end


@interface TTEditUserPickViewManager ()

@property (nonatomic, strong) NSMutableArray<TTEditUserProvinceModel *> *provinceModelArray;

@end

@implementation TTEditUserPickViewManager

static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (NSMutableArray<TTEditUserProvinceModel *> *)provinceModelArray
{
    if(!_provinceModelArray) {
        _provinceModelArray = [NSMutableArray array];
    }
    return _provinceModelArray;
}

- (NSArray<TTEditUserProvinceModel *> *)provinceModels
{
    if(self.provinceModelArray.count > 0) return [self.provinceModelArray copy];
    //从本地读取
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
    NSArray *modelArray = [TTEditUserProvinceModel arrayOfModelsFromDictionaries:array];
    [self.provinceModelArray addObjectsFromArray:modelArray];
    return [self.provinceModelArray copy];
}

@end

@implementation TTEditUserPickView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColorThemeKey = kColorBackground3;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedView *topView = [[SSThemedView alloc] init];
    topView.backgroundColorThemeKey = kColorBackground4;
    [self addSubview:topView];
    self.topView = topView;
    
    SSThemedButton *completionBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    completionBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    [completionBtn setTitle:@"完成" forState:UIControlStateNormal];
    completionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [completionBtn addTarget:self action:@selector(completionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    completionBtn.titleColorThemeKey = kColorText6;
    [topView addSubview:completionBtn];
    self.completionBtn = completionBtn;
    
    SSThemedButton *cancelBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleColorThemeKey = completionBtn.titleColorThemeKey;
    cancelBtn.titleLabel.font = completionBtn.titleLabel.font;
    [cancelBtn addTarget:self action:@selector(coverViewTapClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cancelBtn];
    self.cancelBtn = cancelBtn;

    
    SSThemedView *topViewBottomLine = [[SSThemedView alloc] init];
    topViewBottomLine.backgroundColorThemeKey = kColorLine1;
    [topView addSubview:topViewBottomLine];
    self.topViewBottomLine = topViewBottomLine;
}

- (void)showWithType:(TTEditUserPickViewType)type pickerViewHeight:(CGFloat)pickerViewHeight completion:(void (^)(NSArray<NSString *> *textArray, TTEditUserPickViewType type))completion
{
    self.type = type;
    self.completion = completion;
    [self setupCoverView];
    [self setupPickView];
    self.left = 0;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.height = pickerViewHeight;
    self.width = window.width;
    self.top = window.height;
    self.coverView.alpha = 0;
    [window addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.top = window.height - self.height;
        self.coverView.alpha = 0.5;
    } completion:^(BOOL finished) {
    }];
}

- (void)setupPickView
{
    switch (self.type) {
        case TTEditUserPickViewTypeBirthday:
            [self setupBirthdayPickView];
            break;
        case TTEditUserPickViewTypeArea:
            [self setupAreaPickView];
            break;
        default:
            break;
    }
}

- (void)setupCoverView
{
    SSThemedView *coverView = [[SSThemedView alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTapClick)];
    [coverView addGestureRecognizer:tap];
    coverView.backgroundColor = [UIColor blackColor];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    coverView.frame = window.bounds;
    [window addSubview:coverView];
    self.coverView = coverView;
    
}

- (void)setupBirthdayPickView
{
    UIDatePicker *birthdayDatePicker = [[UIDatePicker alloc] init];
    birthdayDatePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
    birthdayDatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:0];
    [birthdayDatePicker addTarget:self action:@selector(birthdayDatePickerValueChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:birthdayDatePicker];
    self.birthdayDatePickder = birthdayDatePicker;
}

- (void)setupAreaPickView
{
    UIPickerView *areaPickerView = [[UIPickerView alloc] init];
    areaPickerView.delegate = self;
    areaPickerView.dataSource = self;
    [self addSubview:areaPickerView];
    self.areaPickerView = areaPickerView;
}

- (void)birthdayDatePickerValueChange:(UIDatePicker *)datePicker
{
    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    NSString *dateStr = [dateFormatter stringFromDate:date];
    self.currentBirthday = dateStr;
}

- (void)completionBtnClick
{
    NSMutableArray *textArray = [NSMutableArray array];
    if(self.type == TTEditUserPickViewTypeBirthday && !isEmptyString(self.currentBirthday)) {
        [textArray addObject:self.currentBirthday];
    } else {
        if(!isEmptyString(self.currentProvince)) {
            [textArray addObject:self.currentProvince];
        }
        
        if(!isEmptyString(self.currentCity)) {
            [textArray addObject:self.currentCity];
        }
    }

    if(self.completion) {
        self.completion(textArray,self.type);
    }
    [self coverViewTapClick];

}

- (void)coverViewTapClick
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [UIView animateWithDuration:0.25 animations:^{
        self.top = window.height;
        self.coverView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - pickerView 数据源 & 代理

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0) {
        return [[TTEditUserPickViewManager sharedInstance] provinceModels].count;
    } else {
        NSArray *provinces = [[TTEditUserPickViewManager sharedInstance] provinceModels];
        TTEditUserProvinceModel *province = provinces[self.currentLeftIndex];
        return province.areas.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *provinces = [[TTEditUserPickViewManager sharedInstance] provinceModels];
    if(component == 0) {
        TTEditUserProvinceModel *province = provinces[row];
        return province.province;
    } else {
        TTEditUserProvinceModel *province = provinces[self.currentLeftIndex];
        return province.areas[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0) {
        self.currentLeftIndex = row;
        [pickerView reloadComponent:1];
    }
    NSInteger rightIndex = [pickerView selectedRowInComponent:1];
    TTEditUserProvinceModel *province = [[TTEditUserPickViewManager sharedInstance] provinceModels][self.currentLeftIndex];
    self.currentProvince = province.province;
    if(province.areas.count == 0) {
        self.currentCity = nil;
    } else {
        self.currentCity = province.areas[rightIndex];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topView.frame = CGRectMake(0, 0, self.width, kTopViewHeight);
    
    self.completionBtn.width = [TTDeviceUIUtils tt_newPadding:52];
    self.completionBtn.height = [TTDeviceUIUtils tt_newPadding:29];
    self.completionBtn.left = self.width - [TTDeviceUIUtils tt_newPadding:15] - self.completionBtn.width;
    self.completionBtn.centerY = self.topView.centerY;
    
    self.cancelBtn.width = self.completionBtn.width;
    self.cancelBtn.left = [TTDeviceUIUtils tt_padding:15];
    self.cancelBtn.height = self.completionBtn.height;
    self.cancelBtn.centerY = self.topView.centerY;
    
    self.topViewBottomLine.width = self.width;
    self.topViewBottomLine.height = [TTDeviceHelper ssOnePixel];
    self.topViewBottomLine.left = 0;
    self.topViewBottomLine.top = self.topView.height - self.topViewBottomLine.height;
    
    self.birthdayDatePickder.frame = CGRectMake(0, self.topView.bottom, self.width, self.height - self.topView.bottom);
    self.areaPickerView.frame = CGRectMake(0, self.topView.bottom, self.width, self.height - self.topView.bottom);
    
    [self pickerView:self.areaPickerView didSelectRow:0 inComponent:0];
    [self birthdayDatePickerValueChange:self.birthdayDatePickder];
}

@end

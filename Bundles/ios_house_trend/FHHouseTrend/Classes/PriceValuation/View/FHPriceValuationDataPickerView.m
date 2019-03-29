//
//  FHPriceValuationDataPickerView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationDataPickerView.h"
#import "TTDeviceUIUtils.h"
#import "UIViewAdditions.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

#define kTopViewHeight 42
#define MULTIPLE 51

@interface FHPriceValuationDataPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIButton *completionBtn;
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, weak) UIPickerView *pickderView;
@property (nonatomic, weak) UILabel *chooseLabel;
@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, copy) void (^completion)(NSDictionary *result);

@end

@implementation FHPriceValuationDataPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        _hideWhenCompletion = YES;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor themeGray7];;
    [self addSubview:topView];
    self.topView = topView;
    
    UIButton *completionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completionBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [completionBtn setTitle:@"确定" forState:UIControlStateNormal];
    [completionBtn addTarget:self action:@selector(completionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [completionBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal] ;
    [topView addSubview:completionBtn];
    self.completionBtn = completionBtn;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [cancelBtn addTarget:self action:@selector(coverViewTapClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cancelBtn];
    self.cancelBtn = cancelBtn;
    
    UILabel *chooseLabel = [[UILabel alloc] init];
    chooseLabel.font = [UIFont themeFontRegular:16];
    chooseLabel.textColor = [UIColor themeGray1];
    chooseLabel.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:chooseLabel];
    self.chooseLabel = chooseLabel;
}

- (void)showWithHeight:(CGFloat)pickerViewHeight completion:(void (^)(NSDictionary *resultDic))completion {
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

- (void)setupPickView {
    UIPickerView *pickderView = [[UIPickerView alloc] init];
    pickderView.backgroundColor = [UIColor whiteColor];
    pickderView.showsSelectionIndicator = YES;
    pickderView.delegate = self;
    pickderView.dataSource = self;
    [self addSubview:pickderView];
    self.pickderView = pickderView;
    
    for (NSInteger i = 0; i < _defaultSelection.count; i++) {
        if(i < _dataSource.count){
            NSInteger row = [_dataSource[i] indexOfObject:_defaultSelection[i]];
            NSArray *subArray = _dataSource[i];
            if(row < subArray.count){
                [self.pickderView selectRow:row inComponent:i animated:NO];
            }
        }
    }
}

- (void)setupCoverView {
    UIView *coverView = [[UIView alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTapClick)];
    [coverView addGestureRecognizer:tap];
    coverView.backgroundColor = [UIColor blackColor];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    coverView.frame = window.bounds;
    [window addSubview:coverView];
    self.coverView = coverView;
}

- (void)completionBtnClick {
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        NSArray *subArray = self.dataSource[i];
        if([subArray isKindOfClass:[NSArray class]]){
            NSInteger row = [self.pickderView selectedRowInComponent:i];
            if(row < subArray.count){
                [resultDic setObject:subArray[row] forKey:[NSString stringWithFormat:@"%li",(long)i]];
            }
        }
    }
    
    if(self.completion) {
        self.completion(resultDic);
    }
    
    if(_hideWhenCompletion){
        [self coverViewTapClick];
    }
}

- (void)coverViewTapClick {
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dataSource.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(component < self.dataSource.count){
        NSArray *subArray = self.dataSource[component];
        if([subArray isKindOfClass:[NSArray class]]){
            return subArray.count;
        }
    }
    return 0;
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    if(component == 0){
//        return 130.0f;
//    }else if(component == 1){
//        //            return SCREEN_WIDTH - 40.0f - 130.0f - 60.0f - 10.0f;
//        return self.width - 40.0f - 130.0f - 60.0f - 10.0f;
//    }else{
//        return 60.0f;
//    }
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component < self.dataSource.count){
        ((UILabel *)[pickerView.subviews objectAtIndex:1]).backgroundColor = [UIColor themeGray6];//显示分隔线
        ((UILabel *)[pickerView.subviews objectAtIndex:2]).backgroundColor = [UIColor themeGray6];//显示分隔线
        NSArray *subArray = nil;
        if(self.titleSource && component < self.titleSource.count){
            subArray = self.titleSource[component];
        }else{
            subArray = self.dataSource[component];
        }
        if([subArray isKindOfClass:[NSArray class]]){
            if(row < subArray.count){
                return subArray[row];
            }
        }
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(self.didSelectedBlock){
        self.didSelectedBlock(pickerView, row, component);
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.5;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        pickerLabel.font = [UIFont themeFontRegular:16];
        pickerLabel.textColor = [UIColor themeGray1];
    }
    // Fill the label text here
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topView.frame = CGRectMake(0, 0, self.width, kTopViewHeight);
    
    self.completionBtn.width = [TTDeviceUIUtils tt_newPadding:75];
    self.completionBtn.height = kTopViewHeight;
    self.completionBtn.left = self.width - self.completionBtn.width;
    self.completionBtn.centerY = kTopViewHeight/2;
    
    self.cancelBtn.width = self.completionBtn.width;
    self.cancelBtn.left = 0;
    self.cancelBtn.height = self.completionBtn.height;
    self.cancelBtn.centerY = kTopViewHeight/2;
    
    self.chooseLabel.frame = CGRectMake(self.cancelBtn.right, 0, self.width - self.completionBtn.width * 2, kTopViewHeight);
    
    CGFloat bottom = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    self.pickderView.frame = CGRectMake(20, self.topView.bottom, self.width - 40, self.height - self.topView.bottom - bottom);
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
}

- (void)setDefaultSelection:(NSArray *)defaultSelection {
    _defaultSelection = defaultSelection;
}

- (void)setTitleSource:(NSArray *)titleSource {
    _titleSource = titleSource;
}

@end


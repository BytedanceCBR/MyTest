//
//  FHMapSubwayPickerView.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHMapSubwayPickerView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry/Masonry.h>

#define BAR_HEIGHT 42
#define PICKER_HEIGHT 216
#define ACTION_BTN_WIDTH 72

@interface FHMapSubwayPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic , strong) UIControl *topBgControl;
@property(nonatomic , strong) UIPickerView *picker;
@property(nonatomic , strong) UIView *chooseBar;
@property(nonatomic , strong) UIButton *cancelButton;
@property(nonatomic , strong) UIButton *okButton;
@property(nonatomic , strong) UIView *bottomView;
@property(nonatomic , strong) FHSearchFilterConfigOption *dataModel;
@property(nonatomic , strong) FHSearchFilterConfigOption *configData;

@end

@implementation FHMapSubwayPickerView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _chooseBar = [[UIView alloc] init];
        _chooseBar.backgroundColor = [UIColor whiteColor];
        
        _cancelButton = [self button:@"取消" color:[UIColor themeGray1] action:@selector(cancelAction)];
        _okButton = [self button:@"完成" color:[UIColor themeOrange1] action:@selector(okAction)];
        
        [_chooseBar addSubview:_cancelButton];
        [_chooseBar addSubview:_okButton];
        
        _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), PICKER_HEIGHT)];
        _picker.delegate = self;
        _picker.dataSource = self;
        _picker.backgroundColor = [UIColor whiteColor];
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        _topBgControl = [[UIControl alloc] init];
        [_topBgControl addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_topBgControl];
        [self addSubview:_chooseBar];
        [self addSubview:_picker];
        [self addSubview:_bottomView];
     
        self.backgroundColor = [UIColor clearColor];
        
        [self initConstraints];
    }
    return self;
}


-(UIButton *)button:(NSString *)title color:(UIColor *)color action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font =  [UIFont themeFontRegular:16];
    
    return button;
    
}

-(void)cancelAction
{
    [self dismiss:NO];
}

-(void)okAction
{
    NSInteger mainIndex = [self.picker selectedRowInComponent:0];
    NSInteger subIndex = [self.picker selectedRowInComponent:1];
    if (mainIndex >= self.dataModel.options.count) {
        return;
    }
    FHSearchFilterConfigOption *line = self.dataModel.options[mainIndex];
    if (subIndex >= line.options.count) {
        return;
    }
    FHSearchFilterConfigOption *station = line.options[subIndex];
    if (self.chooseStation) {
        self.chooseStation(line, station);
    }
    [self dismiss:YES];
}


-(void)initConstraints
{
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0 , *)) {
        safeInsets = [[[[UIApplication sharedApplication]delegate ] window] safeAreaInsets];
    }
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(safeInsets.bottom);
    }];
    
    [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(PICKER_HEIGHT);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    [_chooseBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.picker.mas_top);
        make.height.mas_equalTo(BAR_HEIGHT);
    }];
    
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.chooseBar);
        make.width.mas_equalTo(ACTION_BTN_WIDTH);
    }];
    
    [_okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(self.chooseBar);
        make.width.mas_equalTo(ACTION_BTN_WIDTH);
    }];
    
    [_topBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.chooseBar.mas_top);
    }];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *v in self.picker.subviews) {
        if (CGRectGetHeight(v.frame) < 1) {
            v.backgroundColor = [UIColor themeGray6];
        }
    }
}

-(void)showWithSubwayData:(FHSearchFilterConfigOption *)data inView:(UIView *)view
{
    if (data != _configData) {
                
        _configData = data;
        
        FHSearchFilterConfigOption *option = [FHSearchFilterConfigOption new];
        option.type = data.type;
        option.text = data.text;
        option.value = data.value;
        
        NSMutableArray *options = [[NSMutableArray alloc] initWithCapacity:data.options.count];
        for (FHSearchFilterConfigOption *op in data.options) {
            //去掉不限
            if ([op.type isEqualToString:@"line"]) {
                [options addObject:op];
            }
        }
        option.options = options;
        self.dataModel = option;
    }
    [view addSubview:self];
    self.frame = view.bounds;
    
    [_picker reloadAllComponents];
}

-(void)dismiss:(BOOL)choosed
{
    if (!choosed && self.dismissBlock) {
        self.dismissBlock();
    }
    [self removeFromSuperview];
}

#pragma mark - picker delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.dataModel.options.count;
    }
    NSInteger index = [pickerView selectedRowInComponent:0];
    if (index < self.dataModel.options.count) {
        FHSearchFilterConfigOption *line = self.dataModel.options[index];
        return line.options.count;
    }
    return 0;
}

//- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//
//    NSString *content = nil;
//    if (component == 0) {
//        FHSearchFilterConfigOption *line = self.dataModel.options[row];
//        content = line.text;
//    }else{
//        NSInteger index = [pickerView selectedRowInComponent:0];
//        FHSearchFilterConfigOption *line = self.dataModel.options[index];
//        if (row < line.options.count) {
//            FHSearchFilterConfigOption *station = line.options[row];
//            content = station.text;
//        }
//    }
//
//    if (content.length == 0) {
////        content = [NSString stringWithFormat:@"-%ld-%ld",component,row];
////        NSLog(@"[SUBWAY] error: %@",content);
//        content = @"...";
//    }
//
//    return [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16],NSForegroundColorAttributeName:[UIColor themeGray1]}];
//
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont themeFontRegular:16];
    label.textColor = [UIColor themeGray1];
    label.adjustsFontSizeToFitWidth = YES;
    
    
    NSString *content = nil;
    if (component == 0) {
        FHSearchFilterConfigOption *line = self.dataModel.options[row];
        content = line.text;
    }else{
        NSInteger index = [pickerView selectedRowInComponent:0];
        FHSearchFilterConfigOption *line = self.dataModel.options[index];
        if (row < line.options.count) {
            FHSearchFilterConfigOption *station = line.options[row];
            content = station.text;
        }
    }
    
    if (content.length == 0) {
        //        content = [NSString stringWithFormat:@"-%ld-%ld",component,row];
        //        NSLog(@"[SUBWAY] error: %@",content);
        content = @"...";
    }

    label.text = content;
    
    return label;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (component == 0) {
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

//
//  FHPriceValuationMoreInfoViewModel.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/27.
//

#import "FHPriceValuationMoreInfoViewModel.h"
#import "FHPriceValuationDataPickerView.h"
#import "TTDeviceUIUtils.h"
#import "FHUserTracker.h"

@interface FHPriceValuationMoreInfoViewModel()<FHPriceValuationMoreInfoViewDelegate>

@property(nonatomic ,weak) FHPriceValuationMoreInfoController *viewController;
@property(nonatomic ,strong) FHPriceValuationMoreInfoView *view;
@property(nonatomic ,strong) FHPriceValuationDataPickerView *floorPickerView;

//用来保存临时选择的值
@property(nonatomic ,strong) NSString *buildYear;
@property(nonatomic ,strong) NSString *faceType;
@property(nonatomic ,strong) NSString *floor;
@property(nonatomic ,strong) NSString *totalFloor;
@property(nonatomic ,strong) NSString *buildType;
@property(nonatomic ,strong) NSString *decorateType;

@end

@implementation FHPriceValuationMoreInfoViewModel

- (instancetype)initWithView:(FHPriceValuationMoreInfoView *)view controller:(FHPriceValuationMoreInfoController *)viewController {
    self = [super init];
    if (self) {
        _view = view;
        _view.delegate = self;
        _viewController = viewController;
        
        //初始化选项数据
        _buildYear = viewController.infoModel.builtYear;
        _faceType = viewController.infoModel.facingType;
        _floor = viewController.infoModel.floor;
        _totalFloor = viewController.infoModel.totalFloor;
        _buildType = viewController.infoModel.buildingType;
        _decorateType = viewController.infoModel.decorationType;
        
        //埋点
        [self addGoDetailTracer];
        
    }
    return self;
}

- (void)addGoDetailTracer {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"group_id"] = self.viewController.infoModel.estimateId;
    TRACK_EVENT(@"go_detail", tracerDict);
}

- (void)addClickOptionsTracer:(NSString *)position {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"group_id"] = self.viewController.infoModel.estimateId;
    tracerDict[@"click_position"] = position;
    TRACK_EVENT(@"click_options", tracerDict);
}

- (NSString *)pageType {
    return @"add_info";
}

- (void)handleBuildYearPickerResult:(NSDictionary *)resultDic {
    if(resultDic.count == 1){
        NSString *buildYear = resultDic[@"0"];
        self.buildYear = buildYear;
        self.view.buildYearItemView.contentLabel.text = buildYear;
    }
}

- (NSArray *)getBuildYearPickerSource {
    NSMutableArray *sourceArray = [NSMutableArray array];
    
    NSMutableArray *yearArray = [NSMutableArray array];
    NSDate *date =[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy"];
    NSInteger currentYear=[[formatter stringFromDate:date] integerValue];
    NSInteger startYear = 1960;
    
    for (NSInteger i = startYear; i <= currentYear; i++) {
        [yearArray addObject:[NSString stringWithFormat:@"%i",i]];
    }
    
    [sourceArray addObject:yearArray];
    return sourceArray;
}

- (NSArray *)getBuildYearDefaultSelection {
    NSMutableArray *defaultArray = [NSMutableArray array];
    NSString *defaultSelection = @"";
    if(self.buildYear && ![self.buildYear isEqualToString:@""]){
        defaultSelection = self.buildYear;
    }else{
        NSDate *date =[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSInteger currentYear=[[formatter stringFromDate:date] integerValue];
        defaultSelection = [NSString stringWithFormat:@"%i",currentYear];
    }
    [defaultArray addObject:defaultSelection];
    return defaultArray;
}

- (void)handleOrientationsPickerResult:(NSDictionary *)resultDic {
    if(resultDic.count == 1){
        NSString *facingType = resultDic[@"0"];
        self.faceType = facingType;
        self.view.orientationsItemView.contentLabel.text = [self.view getOrientations:facingType];
    }
}

- (NSArray *)getOrientationsTitleSource {
    NSMutableArray *sourceArray = [NSMutableArray array];
    [sourceArray addObject:@[@"东",@"西",@"南",@"北",@"东南",@"西南",@"东北",@"西北",@"南北",@"东西"]];
    return sourceArray;
}

- (NSArray *)getOrientationsDataSource {
    NSMutableArray *sourceArray = [NSMutableArray array];
    [sourceArray addObject:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"]];
    return sourceArray;
}

- (NSArray *)getOrientationsDefaultSelection {
    NSMutableArray *defaultArray = [NSMutableArray array];
    if(self.faceType){
        [defaultArray addObject:self.faceType];
    }
    return defaultArray;
}

- (void)handleFloorPickerResult:(NSDictionary *)resultDic {
    if(resultDic.count == 2){
        NSString *floor = resultDic[@"0"];
        NSString *totalFloor = resultDic[@"1"];
        NSInteger floorI = [[floor substringToIndex:(floor.length - 1)] integerValue];
        NSInteger totalFloorI = [[totalFloor substringWithRange:NSMakeRange(1, totalFloor.length - 2)] integerValue];
        if(floorI > totalFloorI){
            return;
        }
        
        self.floor = [floor substringToIndex:(floor.length - 1)];
        self.totalFloor = [totalFloor substringWithRange:NSMakeRange(1, totalFloor.length - 2)];
        self.view.floorItemView.contentLabel.text = [NSString stringWithFormat:@"%@/%@",floor,totalFloor];
        
        if([self.totalFloor isEqualToString:@"1"]){
            self.buildType = @"4";
            [self.view.buildTypeView selectedItem:[self.view getBuildType:self.buildType]];
        }else{
            if([self.buildType isEqualToString:@"4"]){
                self.buildType = nil;
                [self.view.buildTypeView clearAllSelection];
            }
        }
        [self.floorPickerView coverViewTapClick];
    }
}

- (NSArray *)getFloorPickerSource {
    NSMutableArray *sourceArray = [NSMutableArray array];
    
    NSMutableArray *floorArray = [NSMutableArray array];
    for (NSInteger i = 1; i <= 75; i++) {
        [floorArray addObject:[NSString stringWithFormat:@"%li层",(long)i]];
    }
    
    NSMutableArray *totalFloorArray = [NSMutableArray array];
    for (NSInteger i = 1; i <= 75; i++) {
        [totalFloorArray addObject:[NSString stringWithFormat:@"共%li层",(long)i]];
    }
    
    [sourceArray addObject:floorArray];
    [sourceArray addObject:totalFloorArray];
    return sourceArray;
}

- (NSArray *)getFloorDefaultSelection {
    NSMutableArray *defaultArray = [NSMutableArray array];
    if(self.floor){
        NSString *floor = [NSString stringWithFormat:@"%@层",self.floor];
        [defaultArray addObject:floor];
    }
    if(self.totalFloor){
        NSString *totalFloor = [NSString stringWithFormat:@"共%@层",self.totalFloor];
        [defaultArray addObject:totalFloor];
    }
    return defaultArray;
}

- (void)floorDidSelected:(UIPickerView * _Nonnull)pickerView row:(NSInteger)row component:(NSInteger)component {
    NSArray *floorPickerSource = [self getFloorPickerSource];
    if(floorPickerSource.count == 2){
        if(component == 0){
            NSInteger selectedRow = [pickerView selectedRowInComponent:1];
            if(row > selectedRow){
                [pickerView selectRow:row inComponent:1 animated:YES];
            }
        }else{
            NSInteger selectedRow = [pickerView selectedRowInComponent:0];
            if(row < selectedRow){
                [pickerView selectRow:row inComponent:0 animated:YES];
            }
        }
    }
}

#pragma mark - FHPriceValuationMoreInfoViewDelegate

- (void)confirm {
    self.viewController.infoModel.builtYear = self.buildYear;
    self.viewController.infoModel.facingType = self.faceType;
    self.viewController.infoModel.floor = self.floor;
    self.viewController.infoModel.totalFloor = self.totalFloor;
    self.viewController.infoModel.buildingType = self.buildType;
    self.viewController.infoModel.decorationType = self.decorateType;
    
    [self.viewController.navigationController popViewControllerAnimated:YES];
    [self.viewController.delegate callBackDataInfo:nil];
}

- (void)chooseBuildYear {
    //埋点
    [self addClickOptionsTracer:self.view.buildYearItemView.titleLabel.text];
    
    __weak typeof(self) wself = self;
    [self.view endEditing:YES];
    CGFloat bottom = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    CGFloat height = [TTDeviceUIUtils tt_newPadding:259 + bottom];
    
    FHPriceValuationDataPickerView *pickerView = [[FHPriceValuationDataPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    pickerView.dataSource = [self getBuildYearPickerSource];
    pickerView.defaultSelection = [self getBuildYearDefaultSelection];
    [pickerView showWithHeight:height completion:^(NSDictionary * _Nonnull resultDic) {
        [wself handleBuildYearPickerResult:resultDic];
    }];
}

- (void)chooseOrientations {
    //埋点
    [self addClickOptionsTracer:self.view.orientationsItemView.titleLabel.text];
    
    __weak typeof(self) wself = self;
    [self.view endEditing:YES];
    CGFloat bottom = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    CGFloat height = [TTDeviceUIUtils tt_newPadding:259 + bottom];
    
    FHPriceValuationDataPickerView *pickerView = [[FHPriceValuationDataPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    pickerView.dataSource = [self getOrientationsDataSource];
    pickerView.titleSource = [self getOrientationsTitleSource];
    pickerView.defaultSelection = [self getOrientationsDefaultSelection];
    [pickerView showWithHeight:height completion:^(NSDictionary * _Nonnull resultDic) {
        [wself handleOrientationsPickerResult:resultDic];
    }];
}

- (void)chooseFloor {
    //埋点
    [self addClickOptionsTracer:self.view.floorItemView.titleLabel.text];
    
    __weak typeof(self) wself = self;
    [self.view endEditing:YES];
    CGFloat bottom = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    CGFloat height = [TTDeviceUIUtils tt_newPadding:259 + bottom];
    
    self.floorPickerView = [[FHPriceValuationDataPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    _floorPickerView.didSelectedBlock = ^(UIPickerView * _Nonnull pickerView, NSInteger row, NSInteger component) {
        [wself floorDidSelected:pickerView row:row component:component];
    };
    _floorPickerView.dataSource = [self getFloorPickerSource];
    _floorPickerView.defaultSelection = [self getFloorDefaultSelection];
    _floorPickerView.hideWhenCompletion = NO;
    [_floorPickerView showWithHeight:height completion:^(NSDictionary * _Nonnull resultDic) {
        [wself handleFloorPickerResult:resultDic];
    }];
}

- (void)selectBuildType:(NSString *)type {
    //埋点
    [self addClickOptionsTracer:self.view.buildTypeLabel.text];
    
    self.buildType = type;
}

- (void)selectDecorateType:(NSString *)type {
    //埋点
    [self addClickOptionsTracer:self.view.decorateTypeLabel.text];
    
    self.decorateType = type;
}

@end

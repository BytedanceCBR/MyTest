//
//  FHPriceValuationViewModel.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHPriceValuationViewModel.h"
#import <TTRoute.h>
#import "FHPriceValuationDataPickerView.h"
#import "TTDeviceUIUtils.h"
#import "FHPriceValuationAPI.h"
#import "FHPriceValuationHistoryModel.h"
#import "ToastManager.h"
#import "FHPriceValuationEvaluateModel.h"
#import <TTReachability/TTReachability.h>
#import "FHUserTracker.h"

@interface FHPriceValuationViewModel()<FHPriceValuationViewDelegate,UITextFieldDelegate,FHHouseBaseDataProtocel>

@property(nonatomic , weak) FHPriceValuationViewController *viewController;
@property(nonatomic , strong) FHPriceValuationView *view;
@property(nonatomic , strong) FHPriceValuationHistoryModel *model;
//用来保存评估时选择的各项参数
@property(nonatomic , strong) FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *infoModel;

@end

@implementation FHPriceValuationViewModel

- (instancetype)initWithView:(FHPriceValuationView *)view controller:(FHPriceValuationViewController *)viewController;
{
    self = [super init];
    if (self) {
        _view = view;
        _view.delegate = self;
        _view.areaItemView.textField.delegate = self;
        _viewController = viewController;
        _infoModel = [[FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel alloc] init];
        
        //埋点
        [self addGoDetailTracer];
    }
    return self;
}

- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkEvaluateEnabled {
    NSString *neiborhoodName = self.view.neiborhoodItemView.contentLabel.text;
    NSString *area = self.view.areaItemView.textField.text;
    NSString *floor = self.view.floorItemView.contentLabel.text;
    
    if(neiborhoodName && ![neiborhoodName isEqualToString:@""] && area && ![area isEqualToString:@""] && floor && ![floor isEqualToString:@""]){
        [self.view setEvaluateBtnEnabled:YES];
    }else{
        [self.view setEvaluateBtnEnabled:NO];
    }
}

#pragma mark -- textFieldDidChange

- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    NSString *text = textField.text;
    
    if(text.length > 0){
        unichar single = [text characterAtIndex:(text.length - 1)];
        if(single == "."){
            text = [text substringToIndex:(text.length - 1)];
        }
    }
    self.infoModel.squaremeter = text;
    [self checkEvaluateEnabled];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //埋点
    [self addClickOptionsTracer:self.view.areaItemView.titleLabel.text];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isHaveDian = NO;
    if ([textField.text rangeOfString:@"."].location == NSNotFound){
        isHaveDian = NO;
    }else{
        isHaveDian = YES;
    }
    if ([string length] > 0){
        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.'){
            //首字母不能为小数点
            if([textField.text length] == 0){
                if(single == '.'){
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            //输入的字符是否是小数点
            if (single == '.'){
                if(!isHaveDian){
                    isHaveDian = YES;
                    return YES;
                }else{
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }else{
                if (isHaveDian) {//存在小数点
                    //判断小数点的位数
                    NSRange ran = [textField.text rangeOfString:@"."];
                    if (range.location - ran.location <= 2){
                        return YES;
                    }else{
                        return NO;
                    }
                }else{
                    //控制小数点前面的字符数不大于6个
                    NSUInteger loc = range.location;
                    if(range.location >= 6){
                        return NO;
                    }
                    return YES;
                }
                
            }
            
        }else{//输入的数据格式不正确
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }else{
        return YES;
    }
}

#pragma mark - 键盘通知

- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if(_isHideKeyBoard){
        return;
    }
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    
}

- (void)goToHistory {
    [self.view endEditing:YES];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"model"] = self.model;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];

    NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_history"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)addGoDetailTracer {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"enter_from"] = tracerDict[@"enter_from"] ? tracerDict[@"enter_from"] : @"be_null";
    tracer[@"page_type"] = [self pageType];
    TRACK_EVENT(@"go_detail", tracer);
}

- (void)addClickOptionsTracer:(NSString *)position {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"enter_from"] = tracerDict[@"enter_from"] ? tracerDict[@"enter_from"] : @"be_null";
    tracer[@"page_type"] = [self pageType];
    tracer[@"click_position"] = position;
    TRACK_EVENT(@"click_options", tracer);
}

- (NSString *)pageType {
    return @"value_info";
}

#pragma mark - FHPriceValuationViewDelegate

- (void)callBackDataInfo:(NSDictionary *)info {
    if (info && [info isKindOfClass:[NSDictionary class]]) {
        self.infoModel.neighborhoodName = info[@"neighborhood_name"];
        self.infoModel.neighborhoodId = info[@"neighborhood_id"];
        self.view.neiborhoodItemView.contentLabel.text = self.infoModel.neighborhoodName;
        [self checkEvaluateEnabled];
    }
}

- (void)goToNeighborhoodSearch {
    [self.view endEditing:YES];
    
    //埋点
    [self addClickOptionsTracer:self.view.neiborhoodItemView.titleLabel.text];
    
    NSHashTable *delegate = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [delegate addObject:self];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"title"] = @"查房价";
    dict[@"delegate"] = delegate;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_neighborhood_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)evaluate {
    [self.view endEditing:YES];
    
    if([self.infoModel.squaremeter doubleValue] == 0){
        [[ToastManager manager] showToast:@"面积不能为0"];
        return;
    }
    
    if ([TTReachability isNetworkConnected]) {
        NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
        tracerDict[@"enter_from"] = [self pageType];
        
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"infoModel"] = self.infoModel;
        dict[@"tracer"] = tracerDict;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_result"];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }else{
        [[ToastManager manager] showToast:@"网络异常"];
    }
}

- (void)goToUserProtocol {
    [self.view endEditing:YES];
    NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
    NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
    [[TTRoute sharedRoute]openURLByPushViewController:url];
}

- (void)chooseFloor {
    __weak typeof(self) wself = self;
    [self.view endEditing:YES];
    
    //埋点
    [self addClickOptionsTracer:self.view.floorItemView.titleLabel.text];
    
    CGFloat bottom = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    CGFloat height = [TTDeviceUIUtils tt_newPadding:259 + bottom];
    
    FHPriceValuationDataPickerView *pickerView = [[FHPriceValuationDataPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    pickerView.dataSource = [self getFloorPickerSource];
    pickerView.defaultSelection = [self getFloorDefaultSelection];
    [pickerView showWithHeight:height completion:^(NSDictionary * _Nonnull resultDic) {
        [wself handlePickerResult:resultDic];
    }];
}

- (void)handlePickerResult:(NSDictionary *)resultDic {
    if(resultDic.count == 3){
        NSString *room = resultDic[@"0"];
        NSString *lobby = resultDic[@"1"];
        NSString *toilet = resultDic[@"2"];
        self.infoModel.floorPlanRoom = [room substringToIndex:(room.length - 1)];
        self.infoModel.floorPlanHall = [lobby substringToIndex:(lobby.length - 1)];
        self.infoModel.floorPlanBath = [toilet substringToIndex:(toilet.length - 1)];
        
        self.view.floorItemView.contentLabel.text = [NSString stringWithFormat:@"%@/%@/%@",room,lobby,toilet];
        [self checkEvaluateEnabled];
    }
}

- (NSArray *)getFloorPickerSource {
    NSMutableArray *sourceArray = [NSMutableArray array];
    
    NSMutableArray *roomArray = [NSMutableArray array];
    for (NSInteger i = 1; i <= 9; i++) {
        [roomArray addObject:[NSString stringWithFormat:@"%i室",i]];
    }
    
    NSMutableArray *lobbyArray = [NSMutableArray array];
    for (NSInteger i = 0; i <= 9; i++) {
        [lobbyArray addObject:[NSString stringWithFormat:@"%i厅",i]];
    }
    
    NSMutableArray *toiletArray = [NSMutableArray array];
    for (NSInteger i = 0; i <= 9; i++) {
        [toiletArray addObject:[NSString stringWithFormat:@"%i卫",i]];
    }
    
    [sourceArray addObject:roomArray];
    [sourceArray addObject:lobbyArray];
    [sourceArray addObject:toiletArray];
    return sourceArray;
}

- (NSArray *)getFloorDefaultSelection {
    NSMutableArray *defaultArray = [NSMutableArray array];
    
    if(self.infoModel.floorPlanRoom){
        NSString *room = [NSString stringWithFormat:@"%@室",self.infoModel.floorPlanRoom];
        [defaultArray addObject:room];
    }
    if(self.infoModel.floorPlanHall){
        NSString *hall = [NSString stringWithFormat:@"%@厅",self.infoModel.floorPlanHall];
        [defaultArray addObject:hall];
    }
    if(self.infoModel.floorPlanBath){
        NSString *bath = [NSString stringWithFormat:@"%@卫",self.infoModel.floorPlanBath];
        [defaultArray addObject:bath];
    }
    return defaultArray;
}

@end

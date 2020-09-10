//
//  FHHouseSaleInputViewModel.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleInputViewModel.h"
#import "FHHouseSaleInputModel.h"
#import "FHPriceValuationDataPickerView.h"
#import "FHUserInfoManager.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHMainApi+HouseFind.h"
#import "TTBaseMacro.h"
#import "FHMainApi+Contact.h"
#import "NSData+BTDAdditions.h"
#import "HMDTTMonitor.h"
#import "FHUserTracker.h"

@interface FHHouseSaleInputViewModel ()<FHHouseSaleInputViewDelegate,FHPriceValuationItemViewDelegate>

@property(nonatomic, weak) FHHouseSaleInputController *viewController;
@property(nonatomic, weak) FHHouseSaleInputView *view;
@property(nonatomic, strong) FHHouseSaleInputModel *inputModel;
@property(nonatomic, strong) NSString *phoneNum;

@end

@implementation FHHouseSaleInputViewModel

- (instancetype)initWithView:(FHHouseSaleInputView *)view controller:(FHHouseSaleInputController *)viewController;
{
    self = [super init];
    if (self) {
        _view = view;
        _view.delegate = self;
        _view.areaItemView.delegate = self;
        _view.nameItemView.delegate = self;
        _view.phoneItemView.delegate = self;
        _viewController = viewController;
        
        [self configData];
    }
    return self;
}

- (void)configData {
    self.inputModel = [[FHHouseSaleInputModel alloc] init];
    self.inputModel.neighbourhoodId = self.viewController.neighbourhoodId;
    self.inputModel.neighbourhoodName = self.viewController.neighbourhoodName;
    self.view.neiborhoodItemView.contentText = self.viewController.neighbourhoodName;
    self.phoneNum = [FHUserInfoManager getPhoneNumberIfExist];
    [self showFullPhoneNum:NO];
}

- (void)viewWillAppear {
    
}

- (void)viewWillDisappear {
    
}

- (BOOL)canSubmitInfo {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return NO;
    }
    
    if(self.inputModel.neighbourhoodName.length <= 0){
        [[ToastManager manager] showToast:@"请填写所在小区"];
        return NO;
    }
    
    if(self.inputModel.phoneNumber.length <= 0){
        [[ToastManager manager] showToast:@"请填写手机号"];
        return NO;
    }
    
    NSString *phoneNumber = self.inputModel.phoneNumber;
    //包含*说明没有编辑过电话号码，直接取真实的手机号
    if ([phoneNumber containsString:@"*"]) {
        phoneNumber = self.phoneNum;
    }
    if (phoneNumber.length < 1 || ![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![FHUserInfoManager checkPureIntFormatted:phoneNumber]) {
        [[ToastManager manager] showToast:@"请输入正确的手机号"];
        return NO;
    }
    
    return YES;
}

- (void)showFullPhoneNum:(BOOL)isShow {
    if (self.phoneNum.length > 0) {
        if(isShow){
            self.inputModel.phoneNumber = @"";
        }else{
            self.inputModel.phoneNumber = [FHUserInfoManager formatMaskPhoneNumber:self.phoneNum];
        }
        self.view.phoneItemView.textField.text = self.inputModel.phoneNumber;
    }
}

- (BOOL)areaItemView:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
                    if(range.location > ran.location){
                        //控制小数点后面的字符数不大于2个
                        if ([textField.text length] - ran.location <= 2){
                            return YES;
                        }else{
                            return NO;
                        }
                    }else{
                        //控制小数点前面的字符数不大于6个
                        if (ran.location < 6){
                            return YES;
                        }else{
                            return NO;
                        }
                    }
                }else{
                    //控制无小数点时字符数不大于6个
                    if([textField.text length] >= 6){
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

#pragma mark - FHHouseSaleInputViewDelegate

- (void)callBackDataInfo:(NSDictionary *)info {
    if (info && [info isKindOfClass:[NSDictionary class]]) {
        self.inputModel.neighbourhoodName = info[@"neighborhood_name"];
        self.inputModel.neighbourhoodId = info[@"neighborhood_id"];
        self.view.neiborhoodItemView.contentText = self.inputModel.neighbourhoodName;
    }
}

- (void)goToNeighborhoodSearch {
    [self.view endEditing:YES];
    //埋点
//    [self addClickOptionsTracer:self.view.neiborhoodItemView.titleLabel.text];
    
    NSHashTable *delegate = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [delegate addObject:self];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"title"] = @"输入小区";
    dict[@"supportConfirmReturn"] = @(YES);
    dict[@"delegate"] = delegate;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_neighborhood_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)houseSale {
    [self addHousePublishClickLog];
    if([self canSubmitInfo]){
//        NSMutableDictionary *associateDict = [[NSMutableDictionary alloc] init];
//
//        NSString *associateStr = [associateDict btd_jsonStringEncoded] ?: @"";
//        NSDictionary *params = @{
//            @"from": @"app_newhouse_findselfhouse",
//            @"from_data": associateStr,
//        };
//
//        WeakSelf;
//        [FHMainApi loadAssociateEntranceWithParams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
//            StrongSelf;
//            if (!error) {
//                //Step2: 提交线索信息
//                NSDictionary *responseDict = (NSDictionary *)result;
//                if (responseDict && [responseDict isKindOfClass:[NSDictionary class]]) {
//                    if (responseDict[@"status"]) {
//                        NSInteger status = [responseDict[@"status"] integerValue];
//                        if (status != 0) {
//                            [[ToastManager manager] showToast:@"网络错误"];
//                            return;
//                        }
//                    }
//
//                    NSDictionary *data = responseDict[@"data"];
//                    if (data && [data isKindOfClass:[NSDictionary class]]) {
//                        NSDictionary *associateInfo = data[@"associate_info"];
//                        if (associateInfo && [associateInfo isKindOfClass:[NSDictionary class]]) {
//                            strongSelf.reportFormInfo = associateInfo[@"report_form_info"];
//                        } else {
//                            [[ToastManager manager] showToast:@"网络错误"];
//                            return;
//                        }
//                    } else {
//                        [[ToastManager manager] showToast:@"网络错误"];
//                        return;
//                    }
//                } else {
//                    [[ToastManager manager] showToast:@"网络错误"];
//                    return;
//                }
//
//                NSString *originFrom = strongSelf.tracerDict[@"origin_from"] ?: @"be_null";
//                NSMutableDictionary *params = @{
//                    @"origin_from": originFrom,
//                    @"user_phone": phoneNumber,
//                    @"report_form_info": strongSelf.reportFormInfo ?: @{},
//                    @"city_id": cityId ?: @"",
//                }.mutableCopy;
//                if ([FHUserInfoManager isLoginPhoneNumber:phoneNumber]) {
//                    params[@"use_login_phone"] = @(YES);
//                }
//                [strongSelf commitAssociateInfoWithParams:params.copy selectedModel:selectModel phoneNumber:phoneNumber];
//            } else {
//                //接口出错统一提示“网络错误”
//                [[ToastManager manager] showToast:@"网络错误"];
//            }
//        }];
        
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"title"] = @"发布成功";
        NSMutableDictionary *tracer = @{}.mutableCopy;
        tracer[@"origin_from"] = self.viewController.tracerDict[@"origin_from"] ?: @"be_null";
        tracer[@"enter_from"] = self.viewController.tracerDict[@"page_type"] ?: @"be_null";
        dict[@"tracer"] = tracer;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL* url = [NSURL URLWithString:@"sslocal://house_sale_result"];
        [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBack];
        });
        [self addhousePublishSuccessLog];
    }
}

- (void)commitAssociateInfoWithParams:(NSDictionary *)params {
    WeakSelf;
    [FHMainApi commitAssociateInfoWithParams:params completion:^(NSError *error, id response, TTHttpResponse *httpResponse) {
        StrongSelf;
        NSMutableDictionary *categoryDict = @{}.mutableCopy;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (![TTReachability isNetworkConnected]) {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",  FHClueErrorTypeNetFailure];
        }
        
        NSString *message = nil;
        if (httpResponse.statusCode == 200) {
            NSData *responseData = (NSData *)response;
            if (responseData && [responseData isKindOfClass:[NSData class]]) {
                NSDictionary *responseDict = [responseData btd_jsonDictionary];
                if (responseDict && [responseDict isKindOfClass:[NSDictionary class]]) {
                    if (responseDict[@"status"]) {
                        NSInteger status = [responseDict[@"status"] integerValue];
                        message = responseDict[@"message"];
                        if (status == 0) {
                            //Step3: 保存用户选择信息
//                            [strongSelf saveSelectedInfoWithSelectedModel:selectedModel phoneNumber:phoneNumber];
                            //埋点
//                            [strongSelf addClickLogWithEvent:@"click_confirm" position:nil associateInfo:strongSelf.reportFormInfo];
                            
                            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld", FHClueErrorTypeNone];
                        } else {
                            error = [NSError errorWithDomain:responseDict[@"message"] ?: @"请求错误" code:1000 userInfo:nil];
                            extraDict[@"error_code"] = @(status);
                        }
                    }
                } else {
                    error = [NSError errorWithDomain:@"请求错误" code:1000 userInfo:nil];
                }
            } else {
                error = [NSError errorWithDomain:@"请求错误" code:1000 userInfo:nil];
            }
        } else {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld", FHClueErrorTypeHttpFailure];
            extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld", httpResponse.statusCode];
            
            [self addClueFormErrorRateLog:categoryDict extraDict:extraDict];
            return;
        }
        
        if (error) {
            NSString *errorMsg = message ?: error.domain;
            extraDict[@"message"] = errorMsg ?: @"";
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld", FHClueErrorTypeServerFailure];
            [[ToastManager manager] showToast:@"网络错误"];
        }
        
        [self addClueFormErrorRateLog:categoryDict extraDict:extraDict];
    }];
}

- (void)addClueFormErrorRateLog:categoryDict extraDict:(NSDictionary *)extraDict {
    [[HMDTTMonitor defaultManager]hmdTrackService:@"clue_form_error_rate" metric:nil category:categoryDict extra:extraDict];
}

- (void)goBack {
    UIViewController *popVC = [self.viewController.navigationController popViewControllerAnimated:NO];
    if (nil == popVC) {
        [self.viewController dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
}

- (void)chooseFloor {
    __weak typeof(self) wself = self;
    [self.view endEditing:YES];
    
    CGFloat bottom = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    CGFloat height = 259 + bottom;
    
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
        self.inputModel.floorPlanRoom = [room substringToIndex:(room.length - 1)];
        self.inputModel.floorPlanHall = [lobby substringToIndex:(lobby.length - 1)];
        self.inputModel.floorPlanBath = [toilet substringToIndex:(toilet.length - 1)];
        
        self.view.floorItemView.contentText = [NSString stringWithFormat:@"%@/%@/%@",room,lobby,toilet];
    }
}

- (NSArray *)getFloorPickerSource {
    NSMutableArray *sourceArray = [NSMutableArray array];
    
    NSMutableArray *roomArray = [NSMutableArray array];
    for (NSInteger i = 1; i <= 9; i++) {
        [roomArray addObject:[NSString stringWithFormat:@"%li室",(long)i]];
    }
    
    NSMutableArray *lobbyArray = [NSMutableArray array];
    for (NSInteger i = 0; i <= 9; i++) {
        [lobbyArray addObject:[NSString stringWithFormat:@"%li厅",(long)i]];
    }
    
    NSMutableArray *toiletArray = [NSMutableArray array];
    for (NSInteger i = 0; i <= 9; i++) {
        [toiletArray addObject:[NSString stringWithFormat:@"%li卫",(long)i]];
    }
    
    [sourceArray addObject:roomArray];
    [sourceArray addObject:lobbyArray];
    [sourceArray addObject:toiletArray];
    return sourceArray;
}

- (NSArray *)getFloorDefaultSelection {
    NSMutableArray *defaultArray = [NSMutableArray array];
    [defaultArray addObject:@"2室"];
    [defaultArray addObject:@"1厅"];
    [defaultArray addObject:@"1卫"];
    return defaultArray;
}

#pragma mark - FHPriceValuationItemViewDelegate

- (void)itemView:(FHPriceValuationItemView *)itemView textFieldDidChange:(NSString *)text {
    if(itemView == self.view.areaItemView){
        if(text.length > 0){
            unichar single = [text characterAtIndex:(text.length - 1)];
            if(single == "."){
                text = [text substringToIndex:(text.length - 1)];
            }
        }
        self.inputModel.area = text;
    }else if (itemView == self.view.nameItemView){
        self.inputModel.name = text;
    }else if (itemView == self.view.phoneItemView){
        NSInteger limit = 11;
        if(text.length > limit) {
            text = [text substringToIndex:limit];
            itemView.textField.text = text;
        }
        self.inputModel.phoneNumber = text;
    }
}

- (BOOL)itemView:(FHPriceValuationItemView *)itemView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(itemView == self.view.areaItemView){
        return [self areaItemView:itemView.textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

- (void)itemView:(FHPriceValuationItemView *)itemView textFieldDidBeginEditing:(UITextField *)textField {
    if (itemView == self.view.phoneItemView){
        //明文展示或者内容为空时不用读缓存
        if (![textField.text containsString:@"*"]) {
            return;
        }
        [self showFullPhoneNum:YES];
    }
}

#pragma mark - 埋点
- (void)addHousePublishClickLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"enter_from"] = self.viewController.tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"page_type"] = self.viewController.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"click_position"] = @"passport_publisher";
    tracerDict[@"event_tracking_id"] = @"107635";
    TRACK_EVENT(@"house_publish_click", tracerDict);
}

- (void)addhousePublishSuccessLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"enter_from"] = self.viewController.tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"page_type"] = self.viewController.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"event_tracking_id"] = @"107636";
    TRACK_EVENT(@"house_publish_success", tracerDict);
}

@end

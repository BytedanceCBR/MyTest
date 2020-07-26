//
//  FHFastQAViewModel.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHFastQAViewModel.h"
#import "FHFastQAGuessQuestionView.h"
#import "FHFastQAViewController.h"
#import "FHFastQATextView.h"
#import "FHFastQAGuessQuestionView.h"
#import "FHFastQAMobileNumberView.h"
#import <FHHouseBase/FHMainApi.h>
#import <FHHouseList/FHSuggestionListModel.h>
#import <FHHouseBase/FHHouseType.h>
#import <Masonry/Masonry.h>
#import <YYCache/YYCache.h>
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHMainApi.h>
#import <FHCommonUI/ToastManager.h>
#import <TTReachability/TTReachability.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHHouseBase/FHSearchFilterOpenUrlModel.h>
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <FHHouseBase/FHMainApi+Contact.h>
#import <TTPlatformUIModel/HPGrowingTextView.h>

#define WORD_TYPE_NEIGHBORHOOD 4
#define WORD_TYPE_BUSSINESS_AREA 5

@interface FHFastQAViewModel ()<FHFastQAGuessQuestionViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,HPGrowingTextViewDelegate>

@property(nonatomic , strong) FHGuessYouWantResponseDataModel *guessData;
@property(nonatomic , strong) NSString *phoneNum;
@property(nonatomic , strong) FHGuessYouWantResponseDataDataModel *selectedModel;
@property(nonatomic , assign) BOOL userEditPhone;
@property(nonatomic , assign) NSTimeInterval trackStartTime;
@property(nonatomic , assign) NSTimeInterval trackStayTime;
@property(nonatomic , assign) BOOL requestSubmitDone;
@property(nonatomic , assign) BOOL requestCallReportDone;
@property(nonatomic , strong) NSString *submitMsg;

@end

@implementation FHFastQAViewModel

-(void)setGuessView:(FHFastQAGuessQuestionView *)guessView
{
    _guessView = guessView;
    guessView.delegate = self;
}

-(void)setMobileView:(FHFastQAMobileNumberView *)mobileView
{
    _mobileView = mobileView;
    mobileView.phoneTextField.delegate = self;
    [self setPhoneNumber];
    
}

-(void)setQuestionView:(FHFastQATextView *)questionView
{
    _questionView = questionView;
    questionView.delegate = self;
}

-(void)viewWillAppear
{
    [self startTrack];
}

-(void)viewWillDisappear
{
    [self endTrack];
    [self addStayPageLog];
}

-(void)requestData
{
    
    NSString *queryPath = @"/f100/api/guess_you_want_search";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = @(FHHouseTypeSecondHandHouse);
    
    __weak typeof(self) wself = self;
    [FHMainApi queryData:queryPath params:paramDic class:[FHGuessYouWantResponseModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!wself) {
            return ;
        }
        if (error) {
//            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            return;
        }else{
            [wself.viewController.emptyView hideEmptyView];
            wself.guessData = [(FHGuessYouWantResponseModel *)model data];
            [wself filterGuessData];
            if (wself.guessData.data.count > 0) {
                [wself reloadData];
            }
        }
    }];
}


-(void)filterGuessData
{
    NSMutableArray *data = [NSMutableArray new];
    //小区 1 商圈 2
    for (FHGuessYouWantResponseDataDataModel *m in self.guessData.data) {
        FHSearchFilterOpenUrlModel *openUrl = [FHSearchFilterOpenUrlModel instanceFromUrl:m.openUrl];
        if (openUrl.queryDict[@"neighborhood_id[]"]) {
            NSString *nid = openUrl.queryDict[@"neighborhood_id[]"];
            m.id = [self handleId:nid];
            m.type  = WORD_TYPE_NEIGHBORHOOD;
        }else if (openUrl.queryDict[@"area[]"]||openUrl.queryDict[@"area%5B%5D"]){
            NSString *aid = openUrl.queryDict[@"area[]"];
            if (!aid) {
                aid = openUrl.queryDict[@"area%5B%5D"];
            }
            m.id = [self handleId:aid];
            m.type = WORD_TYPE_BUSSINESS_AREA;
        }else{
            continue;
        }
        [data addObject:m];
    }
    
    FHGuessYouWantResponseDataModel *hguess = [FHGuessYouWantResponseDataModel new];
    hguess.data = data;
    self.guessData = hguess;
    
}

-(NSString *)handleId:(NSString *)nid
{
    if ([nid isKindOfClass:[NSArray class]]) {
        nid = [NSString stringWithFormat:@"%@",[(NSArray *)nid firstObject]];
    }else if ([nid isKindOfClass:[NSSet class]]){
        nid = [NSString stringWithFormat:@"%@",[(NSSet *)nid anyObject]];
    }else if (![nid isKindOfClass:[NSString class]]){
        nid = [NSString stringWithFormat:@"%@",nid];
    }
    return nid;
}

-(void)reloadData
{
    NSMutableArray *tips = [[NSMutableArray alloc] initWithCapacity:self.guessData.data.count];
    for (FHGuessYouWantResponseDataDataModel *model in self.guessData.data) {
        
        [tips addObject:model.text];
    }
    NSInteger count = [self.guessView updateWithItems:tips];
    [self.guessView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.guessView.bounds.size.height);
    }];
    for (NSInteger i = 0 ; i < count; i++) {
        [self addAskWordShowLog:i];
    }
}

-(void)sendQuestion
{
    if (![TTReachability isNetworkConnected]) {
        SHOW_TOAST(@"网络异常");
        return;
    }
    self.submitMsg = nil;
    
    self.requestSubmitDone = NO;
    self.requestCallReportDone = NO;
    
    NSString *path = @"/f100/api/investigate/question";
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"phone"] = self.phoneNum?:@"";
    param[@"question"] = self.questionView.text;
    if (self.selectedModel) {
        NSDictionary *guess = @{@"id":self.selectedModel.id?:@"",@"type":@(self.selectedModel.type)};
        param[@"guess"] = guess;
    }
        
    __weak typeof(self) wself = self;
    [FHMainApi postJsonRequest:path query:nil params:param completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        
        BOOL success = NO;
        if (result) {
            success = (result[@"status"] && [result[@"status"] integerValue] == 0);
            if (!success) {
                error = [NSError errorWithDomain:result[@"message"]?:@"请求失败" code:-1 userInfo:nil];
            }
        }
        
        if (error) {
            SHOW_TOAST(@"网络异常，请稍后重试");
            return ;
        }
        
        NSDictionary *data = result[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
             wself.submitMsg = data[@"toast"];
        }
       
        wself.requestSubmitDone = YES;
        [wself requestDone];
       
    }];
    
    [self requestCallReport];
    
}

-(void)requestCallReport
{
    __weak typeof(self) wself = self;
    NSString *houseId = nil;
    NSNumber *type = nil;
    if (self.selectedModel) {
        houseId = self.selectedModel.id;
        type = @(self.selectedModel.type);
    }
    
    [FHMainApi requestQuickQuestionByHouseId:houseId phone:self.phoneNum from:@"app_askpage" type:type extraInfo:nil completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        if (error || model.status.integerValue != 0) {
            SHOW_TOAST(@"网络异常，请稍后重试");
            return ;
        }
        wself.requestCallReportDone = YES;
        [wself requestDone];
    }];
}


-(void)requestDone
{
    
    if (!self.requestCallReportDone || !self.requestSubmitDone) {
        return;
    }
    
    NSString *msg = self.submitMsg;
    if(IS_EMPTY_STRING(msg)){
        msg = @"提交成功，幸福专家将在29分钟内为您解答";
    }
    [self.viewController goBack];
    SHOW_TOAST(msg);
}


-(void)submitQuestation
{
    if(self.userEditPhone){
        self.phoneNum = self.mobileView.phoneTextField.text;
    }
    [self addSubmibLog];
    NSString *phoneNum = self.phoneNum;
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && (!self.userEditPhone || [self isPureInt:phoneNum])) {
        [self sendQuestion];
    }else if (phoneNum.length == 0){
        SHOW_TOAST(@"请留下联系电话，方便获取问题解答");
    }else {
        SHOW_TOAST(@"手机号格式错误");
    }
}


-(void)selectView:(FHFastQAGuessQuestionView *)view atIndex:(NSInteger)index
{
    if (index>= 0 && index >= self.guessData.data.count) {
        return;
    }
    if (index < 0) {
        //反选
        self.selectedModel = nil;
        self.questionView.text = nil;
        return;
    }
    
    FHGuessYouWantResponseDataDataModel *model = self.guessData.data[index];
    if (model.type == WORD_TYPE_NEIGHBORHOOD){
       self.questionView.text =  [NSString stringWithFormat:@"【%@】这个小区怎么样？",model.text];
    }else{
        self.questionView.text = [NSString stringWithFormat:@"【%@】这个区域有哪些房源推荐？",model.text];
    }
    self.selectedModel = model;
    [self addAskWordClickLod:index];
}

- (void)setPhoneNumber {
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    id loginPhoneCache = [sendPhoneNumberCache objectForKey:kFHPLoginhoneNumberCacheKey];
    
    NSString *phoneNum = nil;
    if ([phoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)phoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }else if ([loginPhoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)loginPhoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }
    self.phoneNum = phoneNum;
    [self showFullPhoneNum:NO];
}

- (void)showFullPhoneNum:(BOOL)isShow {
    if (self.phoneNum.length > 0) {
        if(isShow){
            self.mobileView.phoneTextField.text = self.phoneNum;
        }else{
            // 显示 151*****010
            NSString *tempPhone = self.phoneNum;
            if (self.phoneNum.length == 11 && [self.phoneNum hasPrefix:@"1"] && [self isPureInt:self.phoneNum]) {
                tempPhone = [NSString stringWithFormat:@"%@****%@",[self.phoneNum substringToIndex:3],[self.phoneNum substringFromIndex:7]];
            }
            self.mobileView.phoneTextField.text = tempPhone;
        }
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - scrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isTracking) {
        
        [self.viewController.view endEditing:YES];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str replaceCharactersInRange:range withString:string];
    if (str.length > 11) {
        return NO;
    }
    
    if (![self isPureInt:string] && textField.text.length < str.length) {
        return NO;
    }
    return YES;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showFullPhoneNum:YES];
    self.userEditPhone = YES;
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self addClickFillLog];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.viewController scrollToFitHideKeyboard];
    return YES;
}


- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self addClickEditLog];
}

- (void)resetStayTime
{
    self.trackStayTime = 0;
}

- (void)startTrack
{
    self.trackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)endTrack
{
    self.trackStayTime += [[NSDate date] timeIntervalSince1970] - self.trackStartTime;
}



#pragma mark - log
-(void)addQuckAction
{
    /*
     "1. event_type：house_app2c_v2
     2. category_name：category名,{'大家问“：everyone_ask_question}
     3. enter_type：进入category方式,{'点击': 'click', '默认': 'default'} }
     4.enter_from：{'发现tab': 'discover_tab'}
     5.origin_from：{'发现tab': 'discover_tab'}
     6..click_position ：“快速提问”：quick_ask_question"
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_CATEGORY_NAME] = @"everyone_ask_question";
    param[UT_ENTER_TYPE] = @"click";
    param[UT_ENTER_FROM] = @"discover_tab";
    param[UT_ORIGIN_FROM] = @"discover_tab";
    param[@"click_position"] = @"quick_ask_question";
    
    TRACK_EVENT(@"click_quick_question", param);
}

-(void)addGoDetailLog
{
    /*
     "1. event_type ：house_app2c_v2
     2. page_type（详情页类型）：”我要提问“：want_ask_question
     3. enter_from（详情页入口）：“快速提问”：quick_ask_question
     4. origin_from ：{'大家问“：everyone_ask_question}
     7.log_pb"
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = self.viewController.tracerModel.categoryName;
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom;
    param[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom;

    TRACK_EVENT(@"go_detail", param);
}

-(void)addAskWordShowLog:(NSInteger)index
{
    /*
     "1. event_type：house_app2c_v2
     2. word：猜你想问热词，服务端下发
     3. word_id：猜你想问热词id，服务端下发
     4. word_type：猜你想问热词类型,{'小区热词': 'neighborhood_hot'；‘商圈热词’：‘area_hot’；}
     5. rank：展现位置"
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    FHGuessYouWantResponseDataDataModel *m = self.guessData.data[index];
    param[@"word"] = m.text;
    param[@"word_id"] = m.guessSearchId;
    param[@"word_type"] = (m.type == WORD_TYPE_NEIGHBORHOOD)?@"neighborhood_hot":@"area_hot";
    param[@"rank"] = @(index);
    
    TRACK_EVENT(@"ask_word_show", param);
}

-(void)addAskWordClickLod:(NSInteger)index
{
    /*
     "1. event_type：house_app2c_v2
     2. word：猜你想问热词，服务端下发
     3. word_id：猜你想问热词id，服务端下发
     4. word_type：猜你想问热词类型,{'小区热词': 'neighborhood_hot'；‘商圈热词’：‘area_hot’；}
     5. rank：展现位置"
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    FHGuessYouWantResponseDataDataModel *m = self.guessData.data[index];
    param[@"word"] = m.text;
    param[@"word_id"] = m.guessSearchId;
    param[@"word_type"] = (m.type == WORD_TYPE_NEIGHBORHOOD)?@"neighborhood_hot":@"area_hot";
    param[@"rank"] = @(index);
    
    TRACK_EVENT(@"ask_word_click", param);
}

//
-(void)addClickEditLog
{
 
    /*
     "1. event_type ：house_app2c_v2
     2. page_type（详情页类型）：”我要提问“：want_ask_question
     3. enter_from（详情页入口）：“快速提问”：quick_ask_question
     4. origin_from ：{'大家问“：everyone_ask_question}
     
     "
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = self.viewController.tracerModel.categoryName;
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom;
    param[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom;
    
    TRACK_EVENT(@"click_edit", param);
    //
}

//
-(void)addClickFillLog
{
    /*
     "1. event_type ：house_app2c_v2
     2. page_type（详情页类型）：”我要提问“：want_ask_question
     3. enter_from（详情页入口）：“快速提问”：quick_ask_question
     4. origin_from ：{'大家问“：everyone_ask_question}
     5. click_position：点击位置：{“填写手机号”：fill_phone}
     "
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = self.viewController.tracerModel.categoryName;
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom;
    param[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom;
    param[@"click_position"] = @"fill_phone";
    
    TRACK_EVENT(@"click_fill", param);
    
   //click_fill
}

-(void)addSubmibLog
{
    /*
     "1. event_type ：house_app2c_v2
     2. page_type（详情页类型）：”我要提问“：want_ask_question
     3. enter_from（详情页入口）：“快速提问”：quick_ask_question
     4. origin_from ：{'大家问“：everyone_ask_question}
     5. click_position：点击位置：{“提交问题“：refer_question}
     6.phone_number:用户手机号落入线索库"
     */
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = self.viewController.tracerModel.categoryName;
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom;
    param[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom;
    param[@"click_position"] = @"refer_question";
    param[@"phone_number"] = (self.phoneNum.length > 0)?self.phoneNum:UT_BE_NULL;
    
    TRACK_EVENT(@"click_evaluation_result", param);
    //click_submit
    
}

-(void)addStayPageLog
{
    
    /*
     "1. event_type ：house_app2c_v2
     2. page_type（详情页类型）：”我要提问“：want_ask_question
     3. enter_from（详情页入口）：“快速提问”：quick_ask_question
     4. origin_from ：{'大家问“：everyone_ask_question}
     8.stay_time：停留时长，单位毫秒"
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = self.viewController.tracerModel.categoryName;
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom;
    param[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom;
    param[@"stay_time"] = [NSString stringWithFormat:@"%.0f",self.trackStayTime*1000];
    
    TRACK_EVENT(@"stay_page", param);
    //
}


@end

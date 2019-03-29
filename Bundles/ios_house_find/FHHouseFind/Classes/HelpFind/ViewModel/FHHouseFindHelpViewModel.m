//
//  FHHouseFindHelpViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindHelpViewModel.h"
#import "FHHouseFindHelpBottomView.h"
#import "FHHouseFindHeaderView.h"
#import "FHHouseFindHelpRegionCell.h"
#import "FHHouseFindPriceCell.h"
#import "FHHouseFindTextItemCell.h"
#import "FHHouseFindHelpContactCell.h"
#import <FHHouseBase/FHEnvContext.h>
#import "FHHouseFindSelectModel.h"
#import <FHHouseBase/FHHouseType.h>
#import <TTNewsAccountBusiness/TTAccountManager+AccountInterfaceTask.h>
#import <FHCommonUI/ToastManager.h>
#import <TTReachability/TTReachability.h>

#define HELP_HEADER_ID @"header_id"
#define HELP_ITEM_HOR_MARGIN 20
#define HELP_MAIN_CELL_ID @"main_cell_id"
#define HELP_REGION_CELL_ID @"region_cell_id"
#define HELP_PRICE_CELL_ID @"price_cell_id"
#define HELP_NORMAL_CELL_ID @"normal_cell_id"

#define HELP_CONTACT_CELL_ID @"contact_cell_id"

extern NSString *const kFHPhoneNumberCacheKey;

@interface FHHouseFindHelpViewModel ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) FHHouseFindHelpBottomView *bottomView;
@property (nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *secondFilter;
@property (nonatomic , strong) NSArray<NSString *> *titlesArray;
@property (nonatomic , strong) RACDisposable *configDisposable;
@property (nonatomic , assign) BOOL available;
@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) NSMutableDictionary *selectMap; // housetype : FHHouseFindSelectModel

@property (nonatomic , weak) FHHouseFindHelpContactCell *contactCell;
@property(nonatomic , assign) BOOL isRequestingSMS;
@property(nonatomic , strong) NSTimer *timer;
@property(nonatomic , assign) NSInteger verifyCodeRetryTime;
//是否重新是重新发送验证码
@property(nonatomic , assign) BOOL isVerifyCodeRetry;
@property(nonatomic , assign) CGFloat lastY;

@end

@implementation FHHouseFindHelpViewModel

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView bottomView:(FHHouseFindHelpBottomView *)bottomView
{
    self = [super init];
    if (self) {
        _houseType = FHHouseTypeSecondHandHouse;
        _collectionView = collectionView;
        _bottomView = bottomView;
        [self registerCell:collectionView];
        collectionView.delegate = self;
        collectionView.dataSource = self;
//        collectionView.allowsSelection = NO;
        
        __weak typeof(self)wself = self;
        _bottomView.resetBlock = ^{
            [wself resetBtnDidClick];
        };
        _bottomView.confirmBlock = ^{
            [wself confirmBtnDidClick];
        };
        [self setupHouseContent:nil];

//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

//        RACDisposable *disposable = [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(FHConfigDataModel * _Nullable x) {
//            if (x) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [wself setupHouseContent:x];
//                });
//            }
//        }];
//        self.configDisposable = disposable;
        
    }
    return self;
}

- (void)resetBtnDidClick
{
    
}

- (void)confirmBtnDidClick
{
    [self.collectionView endEditing:YES];
    __weak typeof(self) wself = self;
    NSString *phoneNumber = self.contactCell.phoneInput.text;
    NSString *smsCode = self.contactCell.varifyCodeInput.text;

    if(![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]){
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    if(smsCode.length == 0){
        [[ToastManager manager] showToast:@"验证码为空"];
        return;
    }
    [self requestQuickLogin:phoneNumber smsCode:smsCode completion:^(UIImage * _Nonnull captchaImage, NSNumber * _Nonnull newUser, NSError * _Nonnull error) {
        if(!error){
//            [[ToastManager manager] showToast:@"登录成功"];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPhoneNumberCacheKey];
            [wself submitAction];
        }else{
            NSString *errorMessage = [wself errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
        }
    }];
}
#pragma mark 提交选项
- (void)submitAction
{
    
}

- (void)setupHouseContent:(FHConfigDataModel *)configData
{
    if (!configData) {
        configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    }
    
    self.secondFilter = nil;
    
    if (!configData) {
        //show no data
        if (self.showNoDataBlock) {
            self.showNoDataBlock(YES,NO);
        }
    }else{
        
        BOOL avaiable = configData.cityAvailability.enable.boolValue;
        if (self.showNoDataBlock) {
            self.showNoDataBlock(NO,avaiable);
        }
        self.available = avaiable;
        
        if (!avaiable) {
            return;
        }
        self.secondFilter = configData.filter;
        
        NSMutableArray *titles = @[].mutableCopy;
        NSInteger sectionNum = 1;
        for (FHSearchFilterConfigItem *configItem in configData.filter) {
            
            if ([configItem.tabId integerValue] == FHSearchTabIdTypeRegion) {
                sectionNum += 1;
                [titles addObject:@"您想买的区域是？"];
            }else if ([configItem.tabId integerValue] == FHSearchTabIdTypePrice) {
                sectionNum += 1;
                [titles addObject:@"您的购房预算是多少？"];
            }else if ([configItem.tabId integerValue] == FHSearchTabIdTypeRoom) {
                sectionNum += 1;
                [titles addObject:@"您想买的户型是？"];
            }
        }
        self.titlesArray = titles;
        [self.collectionView reloadData];
    }
}

- (NSArray<FHSearchFilterConfigItem *> *)filterOfHouseType:(FHHouseType) ht
{
    switch (ht) {
        case FHHouseTypeSecondHandHouse:
            return _secondFilter;
        default:
            break;
    }
    return nil;
}

- (FHHouseFindSelectModel *)selectModelWithType:(FHHouseType)ht
{
    FHHouseFindSelectModel *model = self.selectMap[@(ht)];
    if (!model) {
        model = [[FHHouseFindSelectModel alloc] init];
        self.selectMap[@(ht)] = model;
    }
    return model;
}

#pragma mark - UICollectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.titlesArray.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *filter = [self filterOfHouseType:_houseType];
    if (filter.count > section) {
        FHSearchFilterConfigItem *item = filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
            return 1;
        }
        FHSearchFilterConfigOption *options = [item.options firstObject];
        return options.options.count;
    }

    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    FHHouseType ht = _houseType;
    NSArray *filter = [self filterOfHouseType:ht];

    // add by zjing for test
    if (indexPath.section == 3) {
        FHHouseFindHelpContactCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_CONTACT_CELL_ID forIndexPath:indexPath];
        pcell.delegate = self;
        self.contactCell = pcell;
        return pcell;
    }
    
    FHHouseFindHelpRegionCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_REGION_CELL_ID forIndexPath:indexPath];
    return pcell;

    if (filter.count > section) {

        FHHouseFindSelectModel *model = [self selectModelWithType:ht];
        FHSearchFilterConfigItem *item = filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {

            FHHouseFindPriceCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_PRICE_CELL_ID forIndexPath:indexPath];
            pcell.tag = ht;
            pcell.delegate = self;

            FHHouseFindSelectItemModel *priceItem = [model selectItemWithTabId:FHSearchTabIdTypePrice];
            if (!priceItem) {
                priceItem = [model makeItemWithTabId:FHSearchTabIdTypePrice];
                priceItem.rate = item.rate;
                priceItem.configOption = [item.options firstObject];
            }else{
                priceItem.rate = item.rate;
                priceItem.configOption = [item.options firstObject];
            }
            if (priceItem) {
                [pcell updateWithLowerPrice:priceItem.lowerPrice higherPrice:priceItem.higherPrice];
            }

            return pcell;

        }else{

            FHHouseFindTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_NORMAL_CELL_ID forIndexPath:indexPath];
            NSString *text = nil;

            FHSearchFilterConfigOption *options = [item.options firstObject];
            if (options.options.count > indexPath.item) {
                FHSearchFilterConfigOption *option = options.options[indexPath.item];
                text = option.text;
            }else{
                text = options.text;
            }

            BOOL selected = NO;

            if (model) {
                FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
                selected = [model selecteItem:selectItem containIndex:indexPath.item];
            }

            [tcell updateWithTitle:text highlighted:selected];

            return tcell;
        }

    }
    return [[UICollectionViewCell alloc] init];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HELP_HEADER_ID forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [headerView updateTitle:@"您的购房预算是多少？" showDelete:NO];
    }else if (indexPath.section == 1) {
        
        [headerView updateTitle:@"您想买的户型是？" showDelete:NO];
//        NSInteger section = indexPath.section;
//        if (histories.count > 0) {
//            section -= 1;
//        }
//        NSArray *filter = [self filterOfHouseType:ht];
//        if (filter.count > section) {
//            FHSearchFilterConfigItem *item =  filter[section];
//            [headerView updateTitle:item.text showDelete:NO];
//        }else{
//            return nil;
//        }
    }else if (indexPath.section == 2) {
        
        [headerView updateTitle:@"您想买的区域是？" showDelete:NO];

    }else if (indexPath.section == 3) {
        
        [headerView updateTitle:@"您的联系方式？" showDelete:NO];
    }
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // add by zjing for test
    if (indexPath.section == 3) {
        return CGSizeMake(collectionView.frame.size.width, 180);
    }
    return CGSizeMake(collectionView.frame.size.width, 36);

    FHHouseType ht = _houseType;
    NSInteger section = indexPath.section;
    NSArray *filter = [self filterOfHouseType:ht];
    if (filter.count > section) {
        FHSearchFilterConfigItem *item =  filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
            return CGSizeMake(collectionView.frame.size.width - 2*HELP_ITEM_HOR_MARGIN, 36);
        }else{
            return CGSizeMake(74, 30);
        }
    }
    return CGSizeMake(collectionView.frame.size.width, 60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    FHHouseType ht = collectionView.tag;
//    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
//
//    NSArray *filter = [self filterOfHouseType:ht];
//    NSArray *histories = self.historyMap[@(ht)];
//
//    NSInteger section = indexPath.section;
//    if (histories.count > 0) {
//        section -= 1;
//    }
//
//    if (filter.count > section) {
//
//        FHSearchFilterConfigItem *item = filter[section];
//
//        FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
//        if (!selectItem) {
//            selectItem = [model makeItemWithTabId:item.tabId.integerValue];
//        }
//        if (!selectItem.configOption) {
//            selectItem.configOption = [item.options firstObject];
//        }
//
//        if([model selecteItem:selectItem containIndex:indexPath.item]){
//            //反选
//            [model delSelecteItem:selectItem withIndex:indexPath.item];
//        }else{
//            //添加选择
//            FHSearchFilterConfigOption *option = nil;
//            if (item.options.count > 0) {
//                option = [item.options firstObject];
//            }
//            if ([option.supportMulti boolValue]) {
//                [model addSelecteItem:selectItem withIndex:indexPath.item];
//            }else{
//                [model clearAddSelecteItem:selectItem withIndex:indexPath.item];
//            }
//        }
//
//        [CATransaction begin ];
//        [CATransaction setDisableActions:YES];
//        //        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
//        [CATransaction commit];
//    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return UIEdgeInsetsZero;
    }
    //    FHHouseType ht = collectionView.tag;
    //    NSArray *histories = self.historyMap[@(ht)];
    //
    //    if (section == 0 && histories.count > 0) {
    //        return UIEdgeInsetsZero;
    //    }
    
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 13;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height = 68;
    if (section == 0) {
        height -= 10;
    }
    
    return CGSizeMake(collectionView.frame.size.width - 2*HELP_ITEM_HOR_MARGIN, height);
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.collectionView endEditing:YES];
//}

- (void)registerCell:(UICollectionView *)collectionview
{
    [collectionview registerClass:[FHHouseFindHelpRegionCell class] forCellWithReuseIdentifier:HELP_REGION_CELL_ID];
    [collectionview registerClass:[FHHouseFindPriceCell class] forCellWithReuseIdentifier:HELP_PRICE_CELL_ID];
    [collectionview registerClass:[FHHouseFindTextItemCell class] forCellWithReuseIdentifier:HELP_NORMAL_CELL_ID];
    [collectionview registerClass:[FHHouseFindHelpContactCell class] forCellWithReuseIdentifier:HELP_CONTACT_CELL_ID];
    
    [collectionview registerClass:[FHHouseFindHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HELP_HEADER_ID];
}

#pragma mark - login相关
- (void)keyboardWillShowNotifiction:(NSNotification *)notification
{
    if(_isHideKeyBoard){
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyBoardBounds = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    self.lastY = [self.collectionView convertPoint:self.contactCell.phoneInput.origin toView:self.viewController.view].y;
    NSLog(@"zjing self.contactCell:%@ lastY:%f,keyboard %@",self.contactCell,self.lastY,userInfo[UIKeyboardFrameEndUserInfoKey]);

    CGFloat offset = 0;
    if (keyBoardBounds.origin.y < [UIScreen mainScreen].bounds.size.height && (self.lastY + keyBoardBounds.size.height > [UIScreen mainScreen].bounds.size.height)) {
        offset = self.lastY + self.lastY + keyBoardBounds.size.height - [UIScreen mainScreen].bounds.size.height;
    }else {
        offset = self.lastY;
    }
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.collectionView.contentOffset = CGPointMake(0, offset);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.collectionView.contentOffset = CGPointMake(0, self.lastY);

    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardFrameWillChange:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    CGRect keyBoardBounds = [userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    self.lastY = [self.collectionView convertPoint:self.contactCell.origin toView:self.viewController.view].y;
    
    NSLog(@"zjing self.contactCell:%@ lastY:%f,keyboard %@",self.contactCell,self.lastY,userInfo[UIKeyboardFrameEndUserInfoKey]);
    
    CGFloat contentViewHeight = self.contactCell.height;

    CGFloat tempOffset = [UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y;
    CGFloat offset = 0;

    BOOL isDismissing = CGRectGetMinY(keyBoardBounds) >= [[[UIApplication sharedApplication] delegate] window].bounds.size.height;
    if (isDismissing) {
//        offset = (keyBoardBounds.origin.y - contentViewHeight) / 2;
        offset = self.lastY;
    }else {
        
        if (keyBoardBounds.origin.y < [UIScreen mainScreen].bounds.size.height && (self.lastY + keyBoardBounds.size.height > [UIScreen mainScreen].bounds.size.height)) {
            offset = self.lastY + self.lastY + keyBoardBounds.size.height - [UIScreen mainScreen].bounds.size.height;
        }else {
            offset = self.lastY;
        }
//        if (tempOffset > 0) {
//            CGFloat offsetKeybord = 30;
//            offset = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y) - contentViewHeight) - offsetKeybord;
//        }else {
//            offset = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height - keyBoardBounds.origin.y) - contentViewHeight) / 2;
//        }
    }
    NSLog(@"zjing offset:%f ",offset);
    // add by zjing for test
//    offset = 800;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.collectionView.contentOffset = CGPointMake(0, offset);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    NSString *text = textField.text;
    NSInteger limit = 0;
    if(textField == self.contactCell.phoneInput) {
        limit = 11;
        
        //设置登录和获取验证码是否可点击
        if(text.length > 0){
            [self setVerifyCodeButtonAndConfirmBtnEnabled:YES];
        }else{
            [self setVerifyCodeButtonAndConfirmBtnEnabled:NO];
        }
    }else if(textField == self.contactCell.varifyCodeInput) {
        limit = 6;
    }
    
    if(text.length > limit) {
        textField.text = [text substringToIndex:limit];
    }
}

- (void)sendVerifyCode
{
    [self.collectionView endEditing:YES];
    __weak typeof(self) weakSelf = self;
    NSString *phoneNumber = self.contactCell.phoneInput.text;

    if(![phoneNumber hasPrefix:@"1"] || phoneNumber.length != 11 || ![self isPureInt:phoneNumber]){
        [[ToastManager manager] showToast:@"手机号错误"];
        return;
    }
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    
    if(self.isRequestingSMS){
        return;
    }
    
    self.isRequestingSMS = YES;
    [[ToastManager manager] showToast:@"正在获取验证码"];
    
    __weak typeof(self)wself = self;
    [self requestSendVerifyCode:phoneNumber completion:^(NSNumber * _Nonnull retryTime, UIImage * _Nonnull captchaImage, NSError * _Nonnull error) {
        wself.isRequestingSMS = NO;
        if(!error){
            [wself blockRequestSendMessage:[retryTime integerValue]];
            [[ToastManager manager] showToast:@"短信验证码发送成功"];
            wself.isVerifyCodeRetry = YES;
        }else{
            NSString *errorMessage = [wself errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
        }
    }];
}

- (void)blockRequestSendMessage:(NSInteger)retryTime
{
    self.verifyCodeRetryTime = retryTime;
    [self startTimer];
}

- (void)setVerifyCodeButtonAndConfirmBtnEnabled:(BOOL)enabled
{
    [self.contactCell enableSendVerifyCodeBtn:(enabled && self.verifyCodeRetryTime <= 0)];
}

- (BOOL)isPureInt:(NSString *)str
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    int val = 0;
    return [scanner scanInt:&val] && scanner.isAtEnd;
}

- (void)requestSendVerifyCode:(NSString *)phoneNumber completion:(void(^_Nullable)(NSNumber *retryTime, UIImage *captchaImage, NSError *error))completion
{
    [TTAccountManager startSendCodeWithPhoneNumber:phoneNumber captcha:nil type:TTASMSCodeScenarioQuickLogin unbindExist:NO completion:completion];
}

- (void)requestQuickLogin:(NSString *)phoneNumber smsCode:(NSString *)smsCode completion:(void(^_Nullable)(UIImage *captchaImage, NSNumber *newUser, NSError *error))completion
{
    [TTAccountManager startQuickLoginWithPhoneNumber:phoneNumber code:smsCode captcha:nil completion:completion];
}

- (NSString *)errorMessageByErrorCode:(NSError *)error {
    switch (error.code) {
        case -106:
            return @"网络异常";
            break;
            
        default:
            return error.localizedDescription;
            break;
    }
}

- (void)setVerifyCodeButtonCountDown
{
    if(self.verifyCodeRetryTime < 0){
        self.verifyCodeRetryTime = 0;
    }
    
    if(self.verifyCodeRetryTime == 0){
        [self stopTimer];
        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateHighlighted];
        [self.contactCell.sendVerifyCodeBtn setTitle:@"重新发送" forState:UIControlStateDisabled];
        self.contactCell.sendVerifyCodeBtn.enabled = (self.contactCell.phoneInput.text.length > 0);
        self.isRequestingSMS = NO;
    }else{
        self.contactCell.sendVerifyCodeBtn.enabled = NO;
        [self.contactCell.sendVerifyCodeBtn setTitle:[NSString stringWithFormat:@"重新发送(%lis)",(long)self.verifyCodeRetryTime] forState:UIControlStateDisabled];
    }
    self.verifyCodeRetryTime--;
    
    // add by zjing for test
    NSLog(@"zjing verifyCodeRetryTime:%ld",self.verifyCodeRetryTime);
}

- (void)startTimer
{
    if(_timer){
        [self stopTimer];
    }
    [self.timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (NSTimer *)timer {
    if(!_timer){
        _timer  =  [NSTimer timerWithTimeInterval:1 target:self selector:@selector(setVerifyCodeButtonCountDown) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

-(void)dealloc
{
    [self.configDisposable dispose];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

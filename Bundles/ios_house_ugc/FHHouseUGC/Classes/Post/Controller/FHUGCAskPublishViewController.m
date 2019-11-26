//
//  FHUGCAskPublishViewController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/22.
//

#import "FHUGCAskPublishViewController.h"
#import <FHPostUGCMainView.h>
#import <IMConsDefine.h>
#import <FHUGCConfig.h>
#import <FHCommunityList.h>
#import <WDDefines.h>
#import <TTAccountManager.h>
#import <FHEnvContext.h>
#import <FHUserTracker.h>
#import <FHPostUGCSelectedGroupHistoryView.h>
#import <TTUGCTextView.h>
#import <TTUGCToolbar.h>
#import <FRAddMultiImagesView.h>
#import <ToastManager.h>
#import <TTReachability.h>
#import <FRUploadImageManager.h>
#import <FRUploadImageModel.h>
#import <UIViewController+HUD.h>
#import <TTPostThreadDefine.h>
#import <FHHouseUGCAPI.h>
#import <HMDTTMonitor.h>
#import <FHUGCAskModel.h>
#import <FHPostUGCViewController.h>

#define ENTRY_HEIGHT 44
#define TITLE_TEXT_VIEW_HEIGHT 60
#define DESC_TEXT_VIEW_HEIGHT 100
#define ADD_IMAGES_HEIGHT 120
#define LEFT_PADDING 20
#define RIGHT_PADDING 20
#define TITLE_MAX_COUNT 40
#define DESC_MAX_COUNT 2000
#define IMAGE_MAX_COUNT 3

@interface FHUGCAskPublishViewController () <TTUGCToolbarDelegate, TTUGCTextViewDelegate, FRAddMultiImagesViewDelegate>
@property (nonatomic, assign) BOOL hasSocialGroup;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FHPostUGCMainView *socialGroupSelectEntry;
@property (nonatomic, strong) FHPostUGCSelectedGroupHistoryView *selectedGrouplHistoryView;
@property (nonatomic, strong) TTUGCTextView *titleTextView;
@property (nonatomic, strong) UIView *horizontalSeparatorLine;
@property (nonatomic, strong) TTUGCTextView *descriptionTextView;
@property (nonatomic, strong) FRAddMultiImagesView * addImagesView;
@property (nonatomic, strong) TTUGCToolbar *toolbar;
@property (nonatomic, strong) SSThemedLabel *tipLabel;
@property (nonatomic, strong) FRUploadImageManager *uploadImageManager;
@end

@implementation FHUGCAskPublishViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.title = @"提问";
        self.hasSocialGroup = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 必须实现该方法
    
    [self setupUI];
    
    [self registerNotification];
}

- (void)setupUI {
    
    [self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.socialGroupSelectEntry];
    [self.containerView addSubview:self.selectedGrouplHistoryView];
    
    [self.containerView addSubview:self.titleTextView];
    [self.containerView addSubview:self.horizontalSeparatorLine];
    [self.containerView addSubview:self.descriptionTextView];
    [self.containerView addSubview:self.addImagesView];
    
    // 工具条加在最外层视图
    [self.view addSubview:self.toolbar];
    [self.toolbar addSubview:self.tipLabel];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma makr - 通知

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    CGRect beginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    BOOL isShrinking = beginFrame.origin.y < endFrame.origin.y;
    // 键盘收起
    if(isShrinking) {
        self.toolbar.top =  self.containerView.height - [self toolbarHeight];
    }
    // 键盘弹出
    else {
        self.toolbar.top = self.containerView.height - [self toolbarHeight] - (SCREEN_HEIGHT - endFrame.origin.y);
        
    }
}

#pragma mark - FHUGCPublishBaseViewControllerProtocol

- (BOOL)isEdited {
    
    BOOL ret = NO;
    
    if(self.titleTextView.text.length > 0) {
        ret = YES;
    }
    
    else if(self.descriptionTextView.text.length > 0) {
        ret = YES;
    }
    
    else if(self.addImagesView.selectedImages.count > 0) {
        ret = YES;
    }
    
    return ret;
}

- (void)cancelAction: (UIButton *)cancelBtn {
    if([self isEdited]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"编辑未完成" message: @"退出后编辑的内容将不会被保存" preferredStyle:UIAlertControllerStyleAlert];
        
        WeakSelf;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            StrongSelf;
            [self exitPage];
        }];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self exitPage];
    }
}

- (void)publishAction: (UIButton *)publishBtn {
    
    // 检查网络状态
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    // 收起键盘
    [self.view endEditing:YES];
    
    // 发布提问内容
    [self publishAskContent];
}

#pragma makr - 懒加载成员
- (UIView *)containerView {
    if(!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kNavigationBarHeight)];
    }
    return _containerView;
}

- (FHPostUGCMainView *)socialGroupSelectEntry {
    if(!_socialGroupSelectEntry) {
        _socialGroupSelectEntry = [[FHPostUGCMainView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.hasSocialGroup ? 0 : ENTRY_HEIGHT) type:FHPostUGCMainViewType_Ask];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialGroupSelectEntryAction:)];
        
        [_socialGroupSelectEntry addGestureRecognizer:tapGestureRecognizer];
    }
    return _socialGroupSelectEntry;
}

- (FHPostUGCSelectedGroupHistoryView *)selectedGrouplHistoryView {
    if(!_selectedGrouplHistoryView) {
        FHPostUGCSelectedGroupModel *selectedGroup = [self loadSelectedGroup];
        CGFloat height = selectedGroup ? ENTRY_HEIGHT: 0;
        _selectedGrouplHistoryView = [[FHPostUGCSelectedGroupHistoryView alloc] initWithFrame:CGRectMake(0, self.socialGroupSelectEntry.bottom, SCREEN_WIDTH, height) delegate:self historyModel:selectedGroup];
        _selectedGrouplHistoryView.clipsToBounds = YES;
    }
    return _selectedGrouplHistoryView;
}

- (TTUGCTextView *)titleTextView {
    if(!_titleTextView) {
        _titleTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(LEFT_PADDING, self.selectedGrouplHistoryView.bottom + 24, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, TITLE_TEXT_VIEW_HEIGHT)];
        _titleTextView.internalGrowingTextView.frame = _titleTextView.bounds;
        _titleTextView.clipsToBounds = YES;
        _titleTextView.internalGrowingTextView.font = [UIFont themeFontRegular:22];
        _titleTextView.internalGrowingTextView.placeholder = @"请输入问题";
        _titleTextView.internalGrowingTextView.placeholderColor = [UIColor themeGray3];
        _titleTextView.internalGrowingTextView.internalTextView.textAttributes = @{ NSForegroundColorAttributeName: [UIColor themeGray1], NSFontAttributeName: [UIFont themeFontRegular:22]};
        _titleTextView.internalGrowingTextView.tintColor = [UIColor themeRed1];
        _titleTextView.delegate = self;
    }
    return _titleTextView;
}

- (TTUGCTextView *)descriptionTextView {
    if(!_descriptionTextView) {
        _descriptionTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(LEFT_PADDING, self.horizontalSeparatorLine.bottom + 20, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, DESC_TEXT_VIEW_HEIGHT)];
        _descriptionTextView.clipsToBounds = YES;
        _descriptionTextView.internalGrowingTextView.font = [UIFont themeFontRegular:16];
        _descriptionTextView.internalGrowingTextView.placeholderColor = [UIColor themeGray3];
        _descriptionTextView.internalGrowingTextView.placeholder = @"增加描述和配图（选填）";
        _descriptionTextView.internalGrowingTextView.internalTextView.textAttributes = @{ NSForegroundColorAttributeName: [UIColor themeGray1], NSFontAttributeName: [UIFont themeFontRegular:16]};
        _descriptionTextView.internalGrowingTextView.tintColor = [UIColor themeRed1];
        _descriptionTextView.delegate = self;
    }
    return _descriptionTextView;
}

- (UIView *)horizontalSeparatorLine {
    if(!_horizontalSeparatorLine) {
        _horizontalSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, self.titleTextView.bottom + 16, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, 1)];
        _horizontalSeparatorLine.backgroundColor = [UIColor colorWithHexStr:@"E8E8E8"];
    }
    return _horizontalSeparatorLine;
}

- (TTUGCToolbar *)toolbar {
    if(!_toolbar) {
        CGFloat height = [self toolbarHeight];
        _toolbar = [[TTUGCToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - height, self.view.width, height)];
        
        self.toolbar.banEmojiInput = YES;
        self.toolbar.banHashtagInput = YES;
        self.toolbar.banLongText = YES;
        self.toolbar.banAtInput = YES;
        
        self.toolbar.delegate = self;
        
        WeakSelf;
        self.toolbar.picButtonClkBlk = ^{
            StrongSelf;
            
            // 添加图片
            [self.addImagesView showImagePicker];
        };
    }
    return _toolbar;
}

- (CGFloat)toolbarHeight {
    CGFloat height = 80.f + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    return height;
}

- (SSThemedLabel *)tipLabel {
    if(!_tipLabel) {
        _tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 11, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, 25.f)];
        _tipLabel.backgroundColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont themeFontRegular:11];
        _tipLabel.textAlignment = NSTextAlignmentRight;
        _tipLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        [_tipLabel setTextColor:[UIColor themeGray4]];
    }
    return _tipLabel;
}

- (FRAddMultiImagesView *)addImagesView {
    if(!_addImagesView) {
        _addImagesView = [[FRAddMultiImagesView alloc] initWithFrame:CGRectMake(LEFT_PADDING, self.descriptionTextView.bottom, self.view.width - LEFT_PADDING - RIGHT_PADDING, ADD_IMAGES_HEIGHT) assets:@[]
                                                            images:@[]];
        _addImagesView.delegate = self;
        _addImagesView.hideAddImagesButtonWhenEmpty = YES;
        _addImagesView.selectionLimit = IMAGE_MAX_COUNT;
        [_addImagesView startTrackImagepicker];
    }
    return _addImagesView;
}

- (FRUploadImageManager *)uploadImageManager {
    if (!_uploadImageManager) {
        _uploadImageManager = [[FRUploadImageManager alloc] init];
    }
    return _uploadImageManager;
}

#pragma mark - FHPostUGCSelectedGroupHistoryViewDelegate
// 圈子选择历史选中
-(void)selectedHistoryGroup:(FHPostUGCSelectedGroupModel *)item {
    if (item) {
        self.socialGroupSelectEntry.groupId = item.socialGroupId;
        self.socialGroupSelectEntry.communityName = item.socialGroupName;
        self.socialGroupSelectEntry.followed = NO;

        // 如果选中圈子选择历史，更新UI
        [self updateSelectedGroupHistoryWithItem:item];
    }
    
    [self checkIfEnablePublish];
}

#pragma mark - TTUGCToolbarDelegate

- (void)toolbarDidClickKeyboardButton:(BOOL)switchToKeyboardInput {
    if (switchToKeyboardInput) {
    }
    else {
        [self.view endEditing:YES];
    }
}

#pragma makr - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    
    if(textView == self.titleTextView) {
        if(self.titleTextView.text.length > TITLE_MAX_COUNT) {
            self.titleTextView.text = [self.titleTextView.text substringToIndex: TITLE_MAX_COUNT];
        }
        self.tipLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.titleTextView.text.length, TITLE_MAX_COUNT];
        
        [self checkIfEnablePublish];
    }
    
    else if(textView == self.descriptionTextView) {
        if(self.descriptionTextView.text.length > DESC_MAX_COUNT) {
            self.descriptionTextView.text = [self.descriptionTextView.text substringToIndex: DESC_MAX_COUNT];
        }
        self.tipLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.descriptionTextView.text.length, DESC_MAX_COUNT];
    }
}

- (void)textViewDidBeginEditing:(TTUGCTextView *)textView {
    if(textView == self.titleTextView) {
        self.tipLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.titleTextView.text.length, TITLE_MAX_COUNT];
    }
    
    else if (textView == self.descriptionTextView) {
        self.tipLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.descriptionTextView.text.length, DESC_MAX_COUNT];
    }
}

#pragma mark - FRAddMultiImagesViewDelegate

- (void)addImagesButtonDidClickedOfAddMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView {
    [self.view endEditing:YES];
}

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView clickedImageAtIndex:(NSUInteger)index {
    [self.view endEditing:YES];
}

- (void)addMultiImagesViewPresentedViewControllerDidDismiss {
}

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView changeToSize:(CGSize)size {
}

- (void)addMultiImagesViewNeedEndEditing {
    [self.view endEditing:YES];
}

- (void)addMultiImageViewDidBeginDragging:(FRAddMultiImagesView *)addMultiImagesView {
}

- (void)addMultiImageViewDidFinishDragging:(FRAddMultiImagesView *)addMultiImagesView {
}

#pragma mark - 保存、读取选择圈子历史

- (FHPostUGCSelectedGroupModel *)loadSelectedGroup {
    
    FHPostUGCSelectedGroupModel *selectedGroup = nil;
    
    FHPostUGCSelectedGroupHistory *selectedGroupHistory = [[FHUGCConfig sharedInstance] loadAskPublisherHistoryData];
    
    NSString *currentUserID = [TTAccountManager currentUser].userID.stringValue;
    NSString *currentCityID = [FHEnvContext getCurrentSelectCityIdFromLocal];
    
    if(selectedGroupHistory && currentCityID.length > 0 && currentUserID.length > 0) {
        NSString *saveKey = [currentUserID stringByAppendingString:currentCityID];
        selectedGroup = [selectedGroupHistory.historyInfos objectForKey:saveKey];
    }
    
    return selectedGroup;
}

- (void)saveSelectedGroup {
    // 存储发布历史
    NSString* currentUserID = [TTAccountManager currentUser].userID.stringValue;
    NSString *currentCityID = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(currentCityID.length > 0 && currentUserID.length > 0) {
        FHPostUGCSelectedGroupHistory *selectedGroupHistory = [[FHUGCConfig sharedInstance] loadAskPublisherHistoryData];
        if(!selectedGroupHistory) {
            selectedGroupHistory = [FHPostUGCSelectedGroupHistory new];
            selectedGroupHistory.historyInfos = [NSMutableDictionary dictionary];
        }
        
        FHPostUGCSelectedGroupModel *selectedGroup = [FHPostUGCSelectedGroupModel new];
        selectedGroup.socialGroupId = self.socialGroupSelectEntry.groupId;
        selectedGroup.socialGroupName = self.socialGroupSelectEntry.communityName;
        NSString *saveKey = [currentUserID stringByAppendingString:currentCityID];
        [selectedGroupHistory.historyInfos setObject:selectedGroup forKey:saveKey];
        
        [[FHUGCConfig sharedInstance] saveAskPublisherHistoryDataWithModel:selectedGroupHistory];
    }
}

#pragma mark - 选择圈子逻辑
// 点击选择圈子入口，跳转圈子选择列表
- (void)socialGroupSelectEntryAction:(UITapGestureRecognizer *)sender {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"action_type"] = @(FHCommunityListTypeChoose);
    //无关注定位到推荐
    dict[@"select_district_tab"] = [FHUGCConfig sharedInstance].followList.count > 0 ? @(FHUGCCommunityDistrictTabIdFollow) :  @(FHUGCCommunityDistrictTabIdRecommend);
    
    NSHashTable *chooseDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [chooseDelegateTable addObject:self];
    dict[@"choose_delegate"] = chooseDelegateTable;
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    dict[TRACER_KEY] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

// 从圈子选择列表中选中圈子回带
- (void)selectedItem:(FHUGCScialGroupDataModel *)item {
    // 选择 圈子
    if (item) {
        self.socialGroupSelectEntry.groupId = item.socialGroupId;
        self.socialGroupSelectEntry.communityName = item.socialGroupName;
        self.socialGroupSelectEntry.followed = [item.hasFollow boolValue];
        
        // 如果选中的圈子和上一次一样就隐藏选择历史模块
        [self updateSelectedGroupHistoryWithItem:item];
    }
    
    [self checkIfEnablePublish];
}

// 更新圈子选择历史UI
- (void)updateSelectedGroupHistoryWithItem:(FHUGCScialGroupDataModel *)item {
    
    BOOL hasHistory = self.selectedGrouplHistoryView.model.socialGroupId.length > 0;
    BOOL isShow = hasHistory && ![self.selectedGrouplHistoryView.model.socialGroupId isEqualToString:item.socialGroupId];
    self.selectedGrouplHistoryView.height = isShow ? ENTRY_HEIGHT : 0;
    
    [self refreshUI];
}

// 刷新UI布局
- (void)refreshUI {
    
    // 标题文本输入
    CGRect titleFrame = self.titleTextView.frame;
    titleFrame.origin.y = self.selectedGrouplHistoryView.bottom + 24;
    self.titleTextView.frame = titleFrame;
    
    // 水平分割线
    self.horizontalSeparatorLine.top = self.titleTextView.bottom + 16;
    
    // 描述文本输入
    CGRect descriptionFrame = self.descriptionTextView.frame;
    descriptionFrame.origin.y = self.horizontalSeparatorLine.bottom + 20;
    self.descriptionTextView.frame = descriptionFrame;
}

// 检查是否使用发布按钮逻辑
- (void)checkIfEnablePublish {
    BOOL isEnable = NO;
    
    NSString *titleString = [self validStringFrom:self.titleTextView.text];
    
    NSString *socialGroupId = self.socialGroupSelectEntry.groupId;
    
    if(titleString.length > 0 && socialGroupId.length > 0) {
        isEnable = YES;
    }

    [self enablePublish:isEnable];
}

// 字符串去除首尾空格和包含的换行符
- (NSString *)validStringFrom:(NSString *)originString {
    NSString *ret = [originString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ret;
}

#pragma mark - 发布逻辑

- (void)publishAskContent {
    
    if ([TTAccountManager isLogin]) {
        TTAccountUserEntity *userInfo = [TTAccount sharedAccount].user;
        [self checkSocialGroupFollowedStatusAndPublish];
    } else {
        // 应该不会走到当前位置，UGC外面限制强制登录
        [self gotoLogin];
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"feed_publisher" forKey:@"enter_from"];
    [params setObject:@"click" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    
    WeakSelf;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        StrongSelf;
        
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self publishAskContent];
                });
            }
        }
    }];
}

- (void)checkSocialGroupFollowedStatusAndPublish {
    if (self.socialGroupSelectEntry.followed) {
        // 已关注，直接发帖
        [self publishAskContentAfterFollowedSocialGroup];
    } else {
        // 先关注
        WeakSelf;
        [[FHUGCConfig sharedInstance] followUGCBy:self.socialGroupSelectEntry.groupId isFollow:YES enterFrom:@"feed_publisher" enterType:@"click" completion:^(BOOL isSuccess) {
            StrongSelf;
            if (isSuccess) {
                [self publishAskContentAfterFollowedSocialGroup];
            } else {
                [[ToastManager manager] showToast:@"提问发布失败"];
            }
        }];
    }
}

- (NSArray<FRUploadImageModel*> *)needUploadImgModels {
    NSMutableArray<FRUploadImageModel*> * ary = (NSMutableArray <FRUploadImageModel*> *)[NSMutableArray arrayWithCapacity:10];
    for (FRUploadImageModel * model in self.addImagesView.selectedImages) {
        if (isEmptyString(model.webURI)) {
            [ary addObject:model];
        }
    }
    return ary;
}

- (void)publishAskContentAfterFollowedSocialGroup {
    
    // 有选中图片就先上传图片再发布提问
    if(self.addImagesView.selectedImages.count > 0) {
        [self uploadImages];
    }
    // 没有选中图片就直接发布提问
    else {
        [self postAskRequestWithUploadImageModels: nil];
    }
}

- (void)uploadImages {
    
    NSMutableArray<FRUploadImageModel *> * images = (NSMutableArray<FRUploadImageModel*> *)[NSMutableArray arrayWithCapacity:IMAGE_MAX_COUNT];
    
    // 图片压缩任务
    NSArray<TTUGCImageCompressTask*> *taskImages = self.addImagesView.selectedImageCacheTasks;
    // 选中的图片
    NSArray<UIImage*> *thumbImages = self.addImagesView.selectedThumbImages;
    
    // 构造图片上传数据模型
    for (int i = 0; i < [taskImages count]; i ++) {
        TTUGCImageCompressTask* task = [taskImages objectAtIndex:i];
        UIImage* thumbImage = nil;
        if (thumbImages.count > i) {
            thumbImage = thumbImages[i];
        }
        FRUploadImageModel * model = [[FRUploadImageModel alloc] initWithCacheTask:task thumbnail:thumbImage];
        model.webURI = task.assetModel.imageURI;
        model.imageOriginWidth = task.assetModel.width;
        model.imageOriginHeight = task.assetModel.height;
        [images addObject:model];
    }
    
    [self showLoadingAlert:@"正在上传图片..."];
    WeakSelf;
    [self.uploadImageManager uploadPhotos:images extParameter:@{} progressBlock:^(int expectCount, int receivedCount) {
        StrongSelf;
        // TODO: 展示进度
        
    } finishBlock:^(NSError *error, NSArray<FRUploadImageModel*> *finishUpLoadModels) {
        StrongSelf;
        
        [self dismissLoadingAlert];
        NSError *finishError = nil;
        for (FRUploadImageModel *model in finishUpLoadModels) {
            if (isEmptyString(model.webURI)) {
                finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeUploadImgError userInfo:nil];
                break;
            }
        }
        
        if (error || finishError) {
            //端监控
            //图片上传失败
            NSMutableDictionary * monitorDictionary = [NSMutableDictionary dictionary];
            [monitorDictionary setValue:@(images.count) forKey:@"img_count"];
            NSMutableArray * imageNetworks = [NSMutableArray arrayWithCapacity:images.count];
            
            for (FRUploadImageModel * imageModel in images) {
                NSInteger status = isEmptyString(imageModel.webURI)?0:1;
                NSInteger code = 0;
                if (imageModel.error) {
                    code = imageModel.error.code;
                }
                [imageNetworks addObject:@{@"network":@(imageModel.networkConsume)
                                           , @"local":@(imageModel.localCompressConsume)
                                           , @"status":@(status)
                                           , @"code":@(code)
                                           , @"count":@(imageModel.uploadCount)
                                           , @"size":@(imageModel.size)
                                           , @"gif":@(imageModel.isGIF)
                                           }];
            }
            [monitorDictionary setValue:imageNetworks.copy forKey:@"img_networks"];
            if (error) {
                [monitorDictionary setValue:@(error.code) forKey:@"error"];
            }
            [[ToastManager manager] showToast:@"图片上传失败！"];
        }
        else {
            [self postAskRequestWithUploadImageModels:finishUpLoadModels];
        }
    }];
}

- (void)postAskRequestWithUploadImageModels:(NSArray<FRUploadImageModel*> *) finishUpLoadModels {
    
    // 收集请求参数
    NSString *title = [self validStringFrom:self.titleTextView.text];
    NSString *description = [self validStringFrom:self.descriptionTextView.text];
    NSString *socialGroupId = self.socialGroupSelectEntry.groupId;
    
    NSMutableArray<NSString *> *image_urls = [NSMutableArray arrayWithCapacity:finishUpLoadModels.count];
    [finishUpLoadModels enumerateObjectsUsingBlock:^(FRUploadImageModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isEmptyString(model.webURI)) {
            [image_urls addObject:model.webURI];
        }
    }];
    
    // 组合请求参数
    NSMutableDictionary *requestParams = @{}.mutableCopy;
    requestParams[@"title"] = title;
    requestParams[@"desc"] = description;
    requestParams[@"social_group_id"] = socialGroupId;
    requestParams[@"image_uris"] = image_urls;
    requestParams[@"enter_from"] = @"";
    requestParams[@"page_type"] = @"";
    requestParams[@"element_from"] = @"";
    
    WeakSelf;
    // 开始发送提问发布请求
    [FHHouseUGCAPI requestPublishAskWithParam: requestParams completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        // 成功 status = 0 请求失败 status = 1 数据解析失败 status = 2
        if(error) {
            [[ToastManager manager] showToast:@"发布提问失败!"];
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_ask_publish" metric:nil category:@{@"status":@(1)} extra:nil];
            return;
        }
        
        if([model isKindOfClass:[FHUGCAskModel class]]) {
            FHUGCAskModel *askModel = (FHUGCAskModel *)model;
            if(askModel.data.length > 0) {
                
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"askData"] = askModel.data;
                userInfo[@"social_group_ids"] = socialGroupId;
                
                // 存储历史发布圈子信息
                [self saveSelectedGroup];
                
                // 退出当前页面
                [self exitPage];
                
                // 如果是在附近列表，发布投票完成后，跳转到关注页面
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCForumPostThreadFinish object:nil];
                
                // 发通知进行数据插入操作
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHAskPublishNotificationName object:nil userInfo:userInfo];
                
                [[ToastManager manager] showToast:@"发布提问成功!"];
                
                [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_ask_publish" metric:nil category:@{@"status":@(0)} extra:nil];
                
            }
            else {
                [[ToastManager manager] showToast:@"发布提问失败!"];
                [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_ask_publish" metric:nil category:@{@"status":@(2)} extra:nil];
            }
        }
    }];
}
@end

//
//  FHUGCWendaPublishViewController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/22.
//

#import "FHUGCWendaPublishViewController.h"
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
#import <FHUGCWendaModel.h>
#import <FHPostUGCViewController.h>
#import <FHFeedUGCCellModel.h>
#import <TTUGCDefine.h>
#import <FHUserTracker.h>

// 选择小区圈子控件的高度
#define ENTRY_HEIGHT                44

// 标题输入框尺寸
#define TITLE_TEXT_VIEW_HEIGHT      44
#define TITLE_TEXT_VIEW_MIN_HEIGHT  44
#define TITLE_TEXT_VIEW_MAX_HEIGHT  200

// 描述输入框尺寸
#define DESC_TEXT_VIEW_HEIGHT       100
#define DESC_TEXT_VIEW_MIN_HEIGHT   100
#define DESC_TEXT_VIEW_MAX_HEIGHT   200

// 添加图片控件的高度
#define ADD_IMAGES_HEIGHT           120

// 页面内容左右边距
#define LEFT_PADDING                20
#define RIGHT_PADDING               20

// 输入文本长度限制
#define TITLE_MAX_COUNT             40  // 问题标题文字长度限制
#define DESC_MAX_COUNT              100  // 问题描述文字长度限制
#define IMAGE_MAX_COUNT             3   // 问题副带图片个数限制

// 控件的垂直间距
#define VGAP_HIST_TITLE             24
#define VGAP_TITLE_SEP              16
#define VGAP_SEP_DESC               20
#define VGAP_DESC_ADDIMAGE          10


@interface FHUGCWendaPublishViewController () <TTUGCToolbarDelegate, TTUGCTextViewDelegate, FRAddMultiImagesViewDelegate>

// 控件区
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FHPostUGCMainView *socialGroupSelectEntry;
@property (nonatomic, strong) FHPostUGCSelectedGroupHistoryView *selectedGrouplHistoryView;
@property (nonatomic, strong) UIScrollView *textContentScrollView;
@property (nonatomic, strong) TTUGCTextView *titleTextView;
@property (nonatomic, strong) UIView *horizontalSeparatorLine;
@property (nonatomic, strong) TTUGCTextView *descriptionTextView;
@property (nonatomic, strong) FRAddMultiImagesView * addImagesView;
@property (nonatomic, strong) SSThemedLabel *tipLabel;
@property (nonatomic, strong) TTUGCToolbar *toolbar;

@property (nonatomic, assign) BOOL hasSocialGroup;      // 是否外部带入圈子信息

// 数据区
@property (nonatomic, copy) NSString *selectGroupId;
@property (nonatomic, copy) NSString *selectGroupName;
@property (nonatomic, assign) BOOL isSelectectGroupFollowed;

// 辅助变量
@property (nonatomic, assign) BOOL isKeyboardWillHide;
@property (nonatomic, assign) BOOL keyboardVisibleFlagForToolbarPicPresent;
@property (nonatomic, weak) UIResponder *lastResponder;
@property (nonatomic, strong) FRUploadImageManager *uploadImageManager;

@end

@implementation FHUGCWendaPublishViewController

#pragma mark - 生命周期

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.title = @"提问";
        self.selectGroupId = [paramObj.allParams tt_stringValueForKey:@"select_group_id"];
        self.selectGroupName = [paramObj.allParams tt_stringValueForKey:@"select_group_name"];
        self.isSelectectGroupFollowed = [paramObj.allParams tta_boolForKey:@"select_group_followed"];
        self.hasSocialGroup = self.selectGroupId.length > 0 && self.selectGroupName.length > 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 必须实现该方法
    
    [self setupUI];
    
    [self registerNotification];
    
    [self addGestures];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.lastResponder) {
        if(!self.lastResponder.isFirstResponder) {
            [self.lastResponder becomeFirstResponder];
        }
    }
    else if(!self.titleTextView.isFirstResponder) {
        [self.titleTextView becomeFirstResponder];
    }
}

- (void)setupUI {
    
    [self.view addSubview:self.containerView];
    
    // 顶部圈子选择和圈子历史区
    [self.containerView addSubview:self.socialGroupSelectEntry];
    [self.containerView addSubview:self.selectedGrouplHistoryView];
    
    //  中间内容编辑区
    [self.containerView addSubview:self.textContentScrollView];
    [self.textContentScrollView addSubview:self.titleTextView];
    [self.textContentScrollView addSubview:self.horizontalSeparatorLine];
    [self.textContentScrollView addSubview:self.descriptionTextView];
    [self.textContentScrollView addSubview:self.addImagesView];
    
    // 工具条加在最外层视图
    [self.view addSubview:self.toolbar];
    [self.toolbar addSubview:self.tipLabel];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)addGestures {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.containerView addGestureRecognizer: tap];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self configFirstResponderWithKeyboardShow:self.isKeyboardWillHide];
}

#pragma mark - 键盘高度变化通知

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    self.isKeyboardWillHide = endFrame.origin.y >= SCREEN_HEIGHT;
    
    CGFloat height = SCREEN_HEIGHT - kNavigationBarHeight - self.selectedGrouplHistoryView.bottom -  [self toolbarHeight] - (self.isKeyboardWillHide ? 0 : endFrame.size.height - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom);
    self.textContentScrollView.height = height;
    
    [self updateTextContentScrollViewContentSize];
}

-(void)keyboardDidShow:(NSNotification *)notification {
    if(self.titleTextView.isFirstResponder) {
        [self scrollToCursorVisibleForTextView:self.titleTextView];
    }
    else if(self.descriptionTextView.isFirstResponder) {
        [self scrollToCursorVisibleForTextView:self.descriptionTextView];
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

    [self tracePublisherCancelClick];
    
    if([self isEdited]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"编辑未完成" message: @"退出后编辑的内容将不会被保存" preferredStyle:UIAlertControllerStyleAlert];
        
        WeakSelf;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            StrongSelf;
            [self exitPage];
            [self tracePublisherCancelAlertClickConfirm:YES];
        }];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            StrongSelf;
            [self tracePublisherCancelAlertClickConfirm:NO];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        [self tracePublisherCancelAlertShow];
        
    } else {
        [self exitPage];
    }
}

- (void)publishAction: (UIButton *)publishBtn {
    
    [self tracePublishButtonClick];
    
    // 检查网络状态
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    // 检查是否选择了要发布的小区
    NSString *socialGroupId = self.selectGroupId;
    if(socialGroupId.length <= 0) {
        [[ToastManager manager] showToast:@"请选择要发布的小区！"];
        return;
    }
    
    // 收起键盘
    [self.view endEditing:YES];
    // 发布提问内容
    [self publishWendaContent];
}

#pragma mark - 懒加载成员

- (UIView *)containerView {
    if(!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kNavigationBarHeight)];
    }
    return _containerView;
}

- (FHPostUGCMainView *)socialGroupSelectEntry {
    if(!_socialGroupSelectEntry) {
        BOOL isShow = !(self.hasSocialGroup);
        _socialGroupSelectEntry = [[FHPostUGCMainView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, isShow ? ENTRY_HEIGHT : 0) type:FHPostUGCMainViewType_Wenda];
        _socialGroupSelectEntry.clipsToBounds = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialGroupSelectEntryAction:)];
        
        [_socialGroupSelectEntry addGestureRecognizer:tapGestureRecognizer];
        
        if(isShow) {
            [self traceSocialGroupSelectEntryShow];
        }
    }
    return _socialGroupSelectEntry;
}

- (FHPostUGCSelectedGroupHistoryView *)selectedGrouplHistoryView {
    if(!_selectedGrouplHistoryView) {
        FHPostUGCSelectedGroupModel *selectedGroup = [self loadSelectedGroup];
        BOOL isShow = (selectedGroup && !self.hasSocialGroup);
        CGFloat height = isShow ? ENTRY_HEIGHT: 0;
        _selectedGrouplHistoryView = [[FHPostUGCSelectedGroupHistoryView alloc] initWithFrame:CGRectMake(0, self.socialGroupSelectEntry.bottom, SCREEN_WIDTH, height) delegate:self historyModel:selectedGroup];
        _selectedGrouplHistoryView.clipsToBounds = YES;
        
        if(isShow) {
            [self traceGroupHistoryViewShow];
        }
    }
    return _selectedGrouplHistoryView;
}

- (UIScrollView *)textContentScrollView {
    if(!_textContentScrollView) {
        _textContentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.selectedGrouplHistoryView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - kNavigationBarHeight - self.selectedGrouplHistoryView.bottom - [self toolbarHeight])];
    }
    return _textContentScrollView;
}

- (TTUGCTextView *)titleTextView {
    if(!_titleTextView) {
        _titleTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(LEFT_PADDING, VGAP_HIST_TITLE, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, TITLE_TEXT_VIEW_HEIGHT)];
        _titleTextView.clipsToBounds = YES;
        _titleTextView.delegate = self;
        
        _titleTextView.internalGrowingTextView.minHeight = TITLE_TEXT_VIEW_MIN_HEIGHT;
        _titleTextView.internalGrowingTextView.maxHeight = TITLE_TEXT_VIEW_MAX_HEIGHT;
        _titleTextView.textViewFontSize = 22;
        _titleTextView.typingAttributes = @{ NSForegroundColorAttributeName: [UIColor themeGray1], NSFontAttributeName: [UIFont themeFontRegular:22]};
        _titleTextView.internalGrowingTextView.placeholder = @"请输入问题";
        _titleTextView.internalGrowingTextView.placeholderColor = [UIColor themeGray3];
        _titleTextView.internalGrowingTextView.tintColor = [UIColor themeRed1];
        
        // 调整文字内容垂直偏移
        UIEdgeInsets textContaineriInset = _titleTextView.internalGrowingTextView.internalTextView.textContainerInset;
        textContaineriInset.top = 5;
        _titleTextView.internalGrowingTextView.internalTextView.textContainerInset = textContaineriInset;
    }
    return _titleTextView;
}

- (UIView *)horizontalSeparatorLine {
    if(!_horizontalSeparatorLine) {
        _horizontalSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, self.titleTextView.bottom + VGAP_TITLE_SEP, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, 1)];
        _horizontalSeparatorLine.backgroundColor = [UIColor colorWithHexStr:@"E8E8E8"];
    }
    return _horizontalSeparatorLine;
}

- (TTUGCTextView *)descriptionTextView {
    if(!_descriptionTextView) {
        _descriptionTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(LEFT_PADDING, self.horizontalSeparatorLine.bottom + VGAP_SEP_DESC, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, DESC_TEXT_VIEW_HEIGHT)];
        _descriptionTextView.clipsToBounds = YES;
        _descriptionTextView.delegate = self;
    
        _descriptionTextView.internalGrowingTextView.minHeight = DESC_TEXT_VIEW_MIN_HEIGHT;
        _descriptionTextView.internalGrowingTextView.maxHeight = DESC_TEXT_VIEW_MAX_HEIGHT;
        _descriptionTextView.internalGrowingTextView.font = [UIFont themeFontRegular:16];
        _descriptionTextView.internalGrowingTextView.placeholderColor = [UIColor themeGray3];
        _descriptionTextView.internalGrowingTextView.placeholder = @"增加描述和配图（选填）";
        _descriptionTextView.internalGrowingTextView.internalTextView.textAttributes = @{ NSForegroundColorAttributeName: [UIColor themeGray1], NSFontAttributeName: [UIFont themeFontRegular:16]};
        _descriptionTextView.internalGrowingTextView.tintColor = [UIColor themeRed1];
    }
    return _descriptionTextView;
}

- (FRAddMultiImagesView *)addImagesView {
    if(!_addImagesView) {
        CGFloat y = MAX(self.descriptionTextView.top + DESC_TEXT_VIEW_HEIGHT, self.descriptionTextView.bottom) + VGAP_DESC_ADDIMAGE;
        _addImagesView = [[FRAddMultiImagesView alloc] initWithFrame:CGRectMake(LEFT_PADDING, y, self.view.width - LEFT_PADDING - RIGHT_PADDING, ADD_IMAGES_HEIGHT) assets:@[] images:@[]];
        _addImagesView.delegate = self;
        _addImagesView.hideAddImagesButtonWhenEmpty = YES;
        _addImagesView.selectionLimit = IMAGE_MAX_COUNT;
        [_addImagesView startTrackImagepicker];
    }
    return _addImagesView;
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
            
            self.keyboardVisibleFlagForToolbarPicPresent = !self.isKeyboardWillHide;
            
            [self updateLastResponder];
            
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
        _tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 11, SCREEN_WIDTH - LEFT_PADDING - RIGHT_PADDING, 25)];
        _tipLabel.backgroundColor = [UIColor themeWhite];
        _tipLabel.font = [UIFont themeFontRegular:11];
        _tipLabel.textAlignment = NSTextAlignmentRight;
        _tipLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        [_tipLabel setTextColor:[UIColor themeGray4]];
    }
    return _tipLabel;
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
    
    [self traceGroupHistoryViewClick];
    
    if (item) {
        self.socialGroupSelectEntry.groupId = item.socialGroupId;
        self.socialGroupSelectEntry.communityName = item.socialGroupName;
        self.socialGroupSelectEntry.followed = NO;
        
        self.selectGroupId = self.socialGroupSelectEntry.groupId;
        self.selectGroupName = self.socialGroupSelectEntry.communityName;
        self.isSelectectGroupFollowed = self.socialGroupSelectEntry.followed;

        // 如果选中圈子选择历史，更新UI
        [self updateSelectedGroupHistoryWithItem:item];
    }
    
    [self checkIfEnablePublish];
}

#pragma mark - TTUGCToolbarDelegate

- (void)toolbarDidClickKeyboardButton:(BOOL)switchToKeyboardInput {
    [self configFirstResponderWithKeyboardShow:switchToKeyboardInput];
}

- (void)configFirstResponderWithKeyboardShow:(BOOL)isKeyboardShow {
    
    if (isKeyboardShow) {
        if(self.lastResponder) {
            [self.lastResponder becomeFirstResponder];
        } else {
            [self.titleTextView becomeFirstResponder];
        }
    }
    else {
        [self updateLastResponder];
        [self.lastResponder resignFirstResponder];
    }
}

#pragma mark - TTUGCTextViewDelegate

- (BOOL)textView:(TTUGCTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *replacedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if(textView == self.titleTextView) {
        return ![text isEqualToString:@"\n"] && replacedString.length <= TITLE_MAX_COUNT;
    } else if(textView == self.descriptionTextView) {
        return replacedString.length <= DESC_MAX_COUNT;
    }
    return YES;
}

- (void)textViewDidChange:(TTUGCTextView *)textView {

    if(textView == self.titleTextView) {
        
        NSString *textViewContent = self.titleTextView.text;
        if([textViewContent containsString:@"\n"]) {
            textViewContent = [textViewContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
            
        if(textViewContent.length > TITLE_MAX_COUNT) {
            self.titleTextView.text = [textViewContent substringToIndex: TITLE_MAX_COUNT];
        }
        [self updateTipLabelWithText:self.titleTextView.text maxLength:TITLE_MAX_COUNT];
        
        [self checkIfEnablePublish];
    }
    
    else if(textView == self.descriptionTextView) {
        if(self.descriptionTextView.text.length > DESC_MAX_COUNT) {
            self.descriptionTextView.text = [self.descriptionTextView.text substringToIndex: DESC_MAX_COUNT];
        }
        [self updateTipLabelWithText:self.descriptionTextView.text maxLength:DESC_MAX_COUNT];
    }
    
    [self refreshUI];
    [self scrollToCursorVisibleForTextView:textView];
}

- (void)textViewDidBeginEditing:(TTUGCTextView *)textView {
    if(textView == self.titleTextView) {
        [self updateTipLabelWithText:self.titleTextView.text maxLength:TITLE_MAX_COUNT];
    }
    
    else if (textView == self.descriptionTextView) {
        [self updateTipLabelWithText:self.descriptionTextView.text maxLength:DESC_MAX_COUNT];
        
    }
}

- (void)scrollToCursorVisibleForTextView:(TTUGCTextView *)textView {

    UITextRange *range = textView.internalGrowingTextView.internalTextView.selectedTextRange;
    
    CGRect rect = [textView.internalGrowingTextView.internalTextView caretRectForPosition:range.start];
    
    CGRect targetRect = [self.textContentScrollView convertRect:rect fromView:textView.internalGrowingTextView.internalTextView];
    
    CGPoint contentOffset = self.textContentScrollView.contentOffset;
    
    CGFloat targetBottom = targetRect.origin.y + targetRect.size.height;
    
    CGFloat caretOffset = targetBottom - contentOffset.y;
    
    CGFloat scrollViewHeight = self.textContentScrollView.frame.size.height;
    
    if(caretOffset > 0) {
        if(caretOffset > scrollViewHeight) {
            CGFloat contentOffsetYDelta = caretOffset - scrollViewHeight;
            [self.textContentScrollView setContentOffset:CGPointMake(0, contentOffset.y + contentOffsetYDelta) animated:YES];
        }
    } else {
        [self.textContentScrollView setContentOffset:CGPointMake(0, contentOffset.y + caretOffset - targetRect.size.height) animated:YES];
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
    if(self.keyboardVisibleFlagForToolbarPicPresent) {
        [self configFirstResponderWithKeyboardShow:self.keyboardVisibleFlagForToolbarPicPresent];
    }
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
    
    FHPostUGCSelectedGroupHistory *selectedGroupHistory = [[FHUGCConfig sharedInstance] loadPublisherHistoryData];
    
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
        FHPostUGCSelectedGroupHistory *selectedGroupHistory = [[FHUGCConfig sharedInstance] loadPublisherHistoryData];
        if(!selectedGroupHistory) {
            selectedGroupHistory = [FHPostUGCSelectedGroupHistory new];
            selectedGroupHistory.historyInfos = [NSMutableDictionary dictionary];
        }
        
        FHPostUGCSelectedGroupModel *selectedGroup = [FHPostUGCSelectedGroupModel new];
        selectedGroup.socialGroupId = self.selectGroupId;
        selectedGroup.socialGroupName = self.selectGroupName;
        NSString *saveKey = [currentUserID stringByAppendingString:currentCityID];
        [selectedGroupHistory.historyInfos setObject:selectedGroup forKey:saveKey];
        
        [[FHUGCConfig sharedInstance] savePublisherHistoryDataWithModel:selectedGroupHistory];
    }
}

#pragma mark - 选择圈子逻辑
// 点击选择圈子入口，跳转圈子选择列表
- (void)socialGroupSelectEntryAction:(UITapGestureRecognizer *)sender {
    
    [self traceSocialGroupSelectEntryClick];
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"action_type"] = @(FHCommunityListTypeChoose);
    //无关注定位到推荐
    dict[@"select_district_tab"] = [FHUGCConfig sharedInstance].followList.count > 0 ? @(FHUGCCommunityDistrictTabIdFollow) :  @(FHUGCCommunityDistrictTabIdRecommend);
    
    NSHashTable *chooseDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [chooseDelegateTable addObject:self];
    dict[@"choose_delegate"] = chooseDelegateTable;
    
    [self updateLastResponder];
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[UT_ELEMENT_FROM] = @"select_like_publisher_neighborhood";
    traceParam[UT_ENTER_FROM] = [self pageType];
    traceParam[UT_ENTER_TYPE] = @"click";
    dict[TRACER_KEY] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)updateLastResponder {
    if(self.titleTextView.isFirstResponder) {
        self.lastResponder = self.titleTextView;
    } else if(self.descriptionTextView.isFirstResponder) {
        self.lastResponder = self.descriptionTextView;
    }
}

// 从圈子选择列表中选中圈子回带
- (void)selectedItem:(FHUGCScialGroupDataModel *)item {
    // 选择 圈子
    if (item) {
        self.socialGroupSelectEntry.groupId = item.socialGroupId;
        self.socialGroupSelectEntry.communityName = item.socialGroupName;
        self.socialGroupSelectEntry.followed = [item.hasFollow boolValue];
        
        self.selectGroupId = self.socialGroupSelectEntry.groupId;
        self.selectGroupName = self.socialGroupSelectEntry.communityName;
        self.isSelectectGroupFollowed = self.socialGroupSelectEntry.followed;
        
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
    
    // 内容滚动视图位置调整
    CGRect contentScrollViewFrame = self.textContentScrollView.frame;
    contentScrollViewFrame.origin.y = self.selectedGrouplHistoryView.bottom;
    self.textContentScrollView.frame = contentScrollViewFrame;

    // 水平分割线
    self.horizontalSeparatorLine.top = self.titleTextView.bottom + VGAP_TITLE_SEP;
    
    // 描述文本输入
    CGRect descriptionFrame = self.descriptionTextView.frame;
    descriptionFrame.origin.y = self.horizontalSeparatorLine.bottom + VGAP_SEP_DESC;
    self.descriptionTextView.frame = descriptionFrame;
    
    // 添加图片视图
    CGRect addImageViewFrame = self.addImagesView.frame;
    addImageViewFrame.origin.y = MAX(self.descriptionTextView.top + DESC_TEXT_VIEW_HEIGHT, self.descriptionTextView.bottom) + VGAP_DESC_ADDIMAGE;
    self.addImagesView.frame = addImageViewFrame;
    
    // 更新scrollView内容大小
    [self updateTextContentScrollViewContentSize];
}

- (void)updateTextContentScrollViewContentSize {
    CGSize contentSize = self.textContentScrollView.contentSize;
    if(self.addImagesView.selectedImages.count > 0) {
        contentSize.height = self.addImagesView.top + ADD_IMAGES_HEIGHT;
    } else {
        contentSize.height = self.descriptionTextView.bottom;
    }
    self.textContentScrollView.contentSize = contentSize;
}

// 检查是否使用发布按钮逻辑
- (void)checkIfEnablePublish {
    BOOL isEnable = NO;
    
    NSString *titleString = [self validStringFrom:self.titleTextView.text];
    
    if(titleString.length > 0) {
        isEnable = YES;
    }

    [self enablePublish:isEnable];
}

// 字符串去除首尾空格和包含的换行符
- (NSString *)validStringFrom:(NSString *)originString {
    NSString *ret = [originString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ret;
}

// 更新提示标签文本
- (void)updateTipLabelWithText: (NSString *)text maxLength:(NSUInteger)maxLength {
    NSString *textString = [NSString stringWithFormat:@"%ld/%lu",text.length, maxLength];
    NSRange range = [textString rangeOfString:@"/"];
    if(range.location != NSNotFound) {
        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:textString];
        [attributeText addAttributes:@{NSForegroundColorAttributeName:[UIColor themeGray1],NSFontAttributeName: [UIFont themeFontRegular:11]} range:NSMakeRange(0, range.location)];
        [attributeText addAttributes:@{NSForegroundColorAttributeName:[UIColor themeGray3],NSFontAttributeName:[UIFont themeFontRegular:11]} range:NSMakeRange(range.location, textString.length - range.location)];
        self.tipLabel.attributedText = attributeText;
    }
}

#pragma mark - 发布逻辑

- (void)publishWendaContent {
    
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
    [params setObject:[self pageType] forKey:@"enter_from"];
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
                    [self publishWendaContent];
                });
            }
        }
    }];
}

- (void)checkSocialGroupFollowedStatusAndPublish {
    if (self.isSelectectGroupFollowed) {
        // 已关注，直接发帖
        [self publishWendaContentAfterFollowedSocialGroup];
    } else {
        // 先关注
        WeakSelf;
        [[FHUGCConfig sharedInstance] followUGCBy:self.selectGroupId isFollow:YES enterFrom:[self pageType]  enterType:@"click" completion:^(BOOL isSuccess) {
            StrongSelf;
            if (isSuccess) {
                [self publishWendaContentAfterFollowedSocialGroup];
            } else {
                //[[ToastManager manager] showToast:@"发布失败"];
            }
        }];
    }
}

- (void)publishWendaContentAfterFollowedSocialGroup {
    
    [self startLoading];
    
    // 有选中图片就先上传图片再发布提问
    if(self.addImagesView.selectedImages.count > 0) {
        [self uploadImages];
    }
    // 没有选中图片就直接发布提问
    else {
        [self postWendaRequestWithUploadImageModels: nil];
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
    
    WeakSelf;
    [self.uploadImageManager uploadPhotos:images extParameter:@{} progressBlock:^(int expectCount, int receivedCount) {
        StrongSelf;
        // TODO: 展示进度
        
    } finishBlock:^(NSError *error, NSArray<FRUploadImageModel*> *finishUpLoadModels) {
        StrongSelf;
        NSError *finishError = nil;
        for (FRUploadImageModel *model in finishUpLoadModels) {
            if (isEmptyString(model.webURI)) {
                finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeUploadImgError userInfo:nil];
                break;
            }
        }
        
        if (error || finishError) {
            [self endLoading];
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
            [[ToastManager manager] showToast:@"发布失败！"];
        }
        else {
            [self postWendaRequestWithUploadImageModels:finishUpLoadModels];
        }
    }];
}

- (void)postWendaRequestWithUploadImageModels:(NSArray<FRUploadImageModel*> *) finishUpLoadModels {
    
    // 收集请求参数
    NSString *title = [self validStringFrom:self.titleTextView.text];
    NSString *description = [self validStringFrom:self.descriptionTextView.text];
    NSString *socialGroupId = self.selectGroupId;
    
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
    
    
    // 开始发送提问发布请求
    WeakSelf;
    [FHHouseUGCAPI requestPublishWendaWithParam: requestParams completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        [self endLoading];
        // 成功 status = 0 请求失败 status = 1 数据解析失败 status = 2
        if(error) {
            [[ToastManager manager] showToast: (error.code == 2001 && error.domain.length > 0) ? error.domain : @"发布失败!"];
            [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_wenda_publish" metric:nil category:@{@"status":@(1)} extra:nil];
            return;
        }
        
        if([model isKindOfClass:[FHUGCWendaModel class]]) {
            FHUGCWendaModel *wendaModel = (FHUGCWendaModel *)model;
            if(wendaModel.data.length > 0) {
                
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"social_group_id"] = socialGroupId;
                userInfo[@"publish_type"] = @(FHUGCPublishTypeQuestion);
                
                FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:wendaModel.data];
                if(cellModel) {
                    userInfo[@"cell_model"] = cellModel;
                }
                
                // 存储历史发布圈子信息
                [self saveSelectedGroup];
                
                // 退出当前页面
                [self exitPage];
                
                // 如果是在附近列表，发布投票完成后，跳转到关注页面
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCForumPostThreadFinish object:nil];
                
                [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_wenda_publish" metric:nil category:@{@"status":@(0)} extra:nil];
                
                [[ToastManager manager] showToast:@"发布成功!"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 发通知进行数据插入操作
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostThreadSuccessNotification object:nil userInfo:userInfo];
                });
            }
            else {
                [[ToastManager manager] showToast:@"发布失败!"];
                [[HMDTTMonitor defaultManager] hmdTrackService:@"ugc_wenda_publish" metric:nil category:@{@"status":@(2)} extra:nil];
            }
        }
    }];
}

- (void)startLoading {
    [self publishBtnClickable:NO];
    [self showLoadingAlert:@"正在发布"];
}

- (void)endLoading {
    [self publishBtnClickable:YES];
    [self dismissLoadingAlert];
}

#pragma mark - 埋点区

- (void)tracePublisherCancelClick {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    dict[UT_CLICK_POSITION] = @"publisher_cancel";
    TRACK_EVENT(@"click_options", dict);
}

- (void)tracePublisherCancelAlertShow {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    TRACK_EVENT(@"publisher_cancel_popup_show", dict);
}

- (void)tracePublisherCancelAlertClickConfirm:(BOOL)isConfirm {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    dict[UT_CLICK_POSITION] = isConfirm ? @"confirm" : @"cancel";
    TRACK_EVENT(@"publisher_cancel_popup_click", dict);
}

- (void)traceGroupHistoryViewShow {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_ELEMENT_TYPE] = @"last_published_neighborhood";
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    dict[@"group_id"] = self.selectedGrouplHistoryView.model.socialGroupId;
    TRACK_EVENT(@"element_show", dict);
}

- (void)traceGroupHistoryViewClick {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    dict[UT_CLICK_POSITION] = @"last_published_neighborhood";
    TRACK_EVENT(@"click_last_published_neighborhood", dict);
}

- (void)traceSocialGroupSelectEntryShow {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_ELEMENT_TYPE] = @"select_like_publisher_neighborhood";
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    TRACK_EVENT(@"element_show", dict);
}

- (void)traceSocialGroupSelectEntryClick {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    dict[UT_CLICK_POSITION] = @"select_like_publisher_neighborhood";
    TRACK_EVENT(@"click_like_publisher_neighborhood", dict);
}

- (void)tracePublishButtonClick {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[UT_PAGE_TYPE] = [self pageType];
    dict[UT_ENTER_FROM] = self.tracerModel.enterFrom?:UT_BE_NULL;
    dict[UT_CLICK_POSITION] = @"passport_publisher";
    TRACK_EVENT(@"feed_publish_click", dict);
}

# pragma mark - 埋点辅助函数

- (NSString *)pageType {
    return @"question_publisher";
}
@end

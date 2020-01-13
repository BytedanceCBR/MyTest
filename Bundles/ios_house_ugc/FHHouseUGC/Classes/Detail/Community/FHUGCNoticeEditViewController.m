//
//  FHUGCNoticeEditViewController.m
//  Pods
//
//  Created by wangzhizhou on 2019/9/20.
//

#import "FHUGCNoticeEditViewController.h"
#import "UIViewController+Track.h"
#import "Masonry.h"
#import <FHHouseUGCAPI.h>
#import <ToastManager.h>
#import "FHUserTracker.h"
#import "TTUGCToolbar.h"
#import "TTUGCTextViewMediator.h"
#import "UIViewAdditions.h"
#import "NSObject+MultiDelegates.h"
#import <TTUGCEmojiParser.h>
#import "FHUGCNoticeModel.h"
#import "TTNavigationController.h"

typedef enum : NSUInteger {
    ActionTypeSaveOnly = 0,
    ActionTypeSMS = 1,
    ActionTypePush = 2,
    ActionTypePushAndSMS = 3
} ActionType;

#define MAX_WORD_COUNT 200

#define TEXT_VIEW_FONT_SIZE 16
#define TEXT_VIEW_LINE_HEIGHT 24
#define TEXT_VIEW_LEFT_PADDING 20
#define TEXT_VIEW_RIGHT_PADDING 20
#define VGAP_BETWEEN_NAV_AND_TEXT_VIEW 15
#define WORD_COUNT_LABEL_HEIGHT 32

@interface FHUGCNoticeEditViewController ()<TTUGCTextViewDelegate>

@property (nonatomic, strong) UIButton              *completeButton;
@property (nonatomic, strong) TTUGCTextView         *textView;
@property (nonatomic, strong) UILabel               *wordCountLabel;
@property (nonatomic, strong) TTUGCToolbar          *toolbar;

@property (nonatomic, copy)   NSString              *content;
@property (nonatomic, strong) TTUGCTextViewMediator *textViewMediator;
@property (nonatomic, copy)   void (^callback)(NSString *);
@property (nonatomic, assign) BOOL isReadOnly;
@property (nonatomic, assign) BOOL isSystemKeyboardVisible;
@property (nonatomic, assign) CGFloat systemKeyboardHeight;
@property (nonatomic, copy)   NSString *socialGroupId;
@end

@implementation FHUGCNoticeEditViewController

// MARK: 属性成员

- (UIButton *)completeButton {
    if(!_completeButton) {
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_completeButton setTitle:@"完成" forState:UIControlStateNormal];
        [_completeButton setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [_completeButton setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
        _completeButton.enabled = NO;
        [_completeButton addTarget:self action:@selector(completeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeButton;
}

// MARK: 生命周期

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        self.isReadOnly = [paramObj.allParams[@"isReadOnly"] boolValue];
        self.content = paramObj.allParams[@"content"];
        self.callback = paramObj.allParams[@"callback"];
        self.title = self.isReadOnly ? @"圈子公告" : @"编辑公告";
        self.socialGroupId = paramObj.allParams[@"socialGroupId"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNavBar];
    [self configContent];
    [self configNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self navigationControllerPanGestureDisable:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    [self navigationControllerPanGestureDisable:NO];
}


// MARK: UI

- (void)configNavBar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.textColor = [UIColor themeGray1];
    self.customNavBarView.title.font = [UIFont themeFontMedium:16];
    self.customNavBarView.title.text = self.title;
    
    __weak typeof(self) wself = self;
    self.customNavBarView.leftButtonBlock = ^{
        if(wself.isReadOnly) {
            [wself exitPage];
        } else {
            [wself showAlertToAskUserDecision: YES];
        }
    };
    
    [self.customNavBarView addSubview:self.completeButton];
    
    [self.completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.customNavBarView.title);
        make.right.equalTo(self.customNavBarView).offset(-20);
        make.width.height.mas_offset(40);
    }];
}

- (CGFloat)navbarHeight {
    CGFloat navbarHeight = 65;
    if (@available(iOS 11.0 , *)) {
        navbarHeight =  44.f + self.view.tt_safeAreaInsets.top;
    }
    return navbarHeight;
}

- (CGFloat)toolbarHeightWithKeyboardShow:(BOOL)isShow {
    return  80 + (isShow ? 0 : [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom);
}

- (void)configContent {
    
    CGFloat navbarHeight = [self navbarHeight];
    CGFloat toolbarHeight = [self toolbarHeightWithKeyboardShow:NO];
    CGRect textViewFrame = CGRectMake(TEXT_VIEW_LEFT_PADDING, navbarHeight + VGAP_BETWEEN_NAV_AND_TEXT_VIEW, self.view.bounds.size.width - TEXT_VIEW_LEFT_PADDING - TEXT_VIEW_RIGHT_PADDING, self.view.bounds.size.height - navbarHeight - toolbarHeight);
    
    // textView
    self.textView = [[TTUGCTextView alloc] initWithFrame: textViewFrame];;
    self.textView.keyboardAppearance = UIKeyboardAppearanceLight;
    self.textView.isBanAt = YES;
    self.textView.isBanHashtag = YES;
    self.textView.source = @"community_notice_edit_detail";
    self.textView.internalGrowingTextView.placeholder = @"请编辑群公告";
    self.textView.internalGrowingTextView.placeholderColor = [UIColor themeGray3];
        
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.maximumLineHeight = TEXT_VIEW_LINE_HEIGHT;
    paragraphStyle.minimumLineHeight = TEXT_VIEW_LINE_HEIGHT;
    self.textView.typingAttributes = @{
        NSForegroundColorAttributeName: [UIColor themeGray1],
        NSFontAttributeName: [UIFont themeFontRegular:TEXT_VIEW_FONT_SIZE],
        NSParagraphStyleAttributeName: paragraphStyle
    };
    self.textView.internalGrowingTextView.tintColor = [UIColor themeRed1];
    [self.view addSubview:self.textView];
    
    // 圈子公告，只读模式
    if(self.isReadOnly) {
        [self configContentForReadOnly];
    }
    // 圈子公告，编辑模式
    else {
        [self configContentForEdit];
    }
    
    // 所有textView配置完成后再设置内容
    self.textView.text = self.content;
}

- (void)configContentForReadOnly {
    // 使内部growTextView的大小和外部一致
    CGRect textViewFrame = self.textView.frame;
    self.textView.internalGrowingTextView.maxHeight = textViewFrame.size.height;
    CGRect interTextViewFrame = self.textView.internalGrowingTextView.frame;
    CGFloat interTextViewContentHeight = [self.textView.internalGrowingTextView measureHeight];
    interTextViewFrame.size.height = (interTextViewContentHeight < textViewFrame.size.height) ? interTextViewContentHeight : textViewFrame.size.height;
    self.textView.internalGrowingTextView.frame = interTextViewFrame;
    self.textView.internalGrowingTextView.editable = NO;
    self.completeButton.hidden = YES;
}

- (void)configContentForEdit {
    [self.textView addGestureRecognizer:[self toggleKeyboardTapGesture]];
    [self.textView becomeFirstResponder];
    // toolbar
    CGFloat toolbarHeight = [self toolbarHeightWithKeyboardShow:NO];
    CGRect toolbarFrame = CGRectMake(0, self.view.bounds.size.height - toolbarHeight, self.view.bounds.size.width, toolbarHeight);
    self.toolbar = [[TTUGCToolbar alloc] initWithFrame:toolbarFrame];
    self.toolbar.emojiInputView.source = @"community_notice_edit_detail";
    self.toolbar.banHashtagInput = YES;
    self.toolbar.banLongText = YES;
    self.toolbar.banAtInput = YES;
    self.toolbar.banShoppingInput = YES;
    self.toolbar.banPicInput = YES;
    self.toolbar.picButtonClkBlk = nil;
    [self.view addSubview:self.toolbar];
    
    // 字数限制标签
    CGRect wordCountLabelFrame = CGRectMake(20, 0, self.toolbar.size.width - 40, WORD_COUNT_LABEL_HEIGHT);
    self.wordCountLabel = [[UILabel alloc] initWithFrame:wordCountLabelFrame];
    self.wordCountLabel.textAlignment = NSTextAlignmentRight;
    self.wordCountLabel.attributedText = [self wordCountAttributeStringWithTextCount:self.content.length];
    self.wordCountLabel.userInteractionEnabled = YES;
    [self.wordCountLabel addGestureRecognizer:[self toggleKeyboardTapGesture]];
    [self.toolbar addSubview:self.wordCountLabel];
    
    self.textViewMediator.textView = self.textView;
    self.textViewMediator.toolbar = self.toolbar;
    self.toolbar.emojiInputView.delegate = self.textView;
    self.toolbar.delegate = self.textViewMediator;
    [self.toolbar tt_addDelegate:self asMainDelegate:NO];
    self.textView.delegate = self.textViewMediator;
    [self.textView tt_addDelegate:self asMainDelegate:NO];
    self.textView.textLenDelegate = self;
}

- (void)configNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// MARK: Logic

- (void)keyboardWillShow:(NSNotification *)notification {
    self.isSystemKeyboardVisible = YES;
    CGFloat duration = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyboardRect = [notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    self.systemKeyboardHeight = keyboardRect.size.height;
    [self animateTextViewWithDuration:duration keyboardHeight:self.systemKeyboardHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.isSystemKeyboardVisible = NO;
    
    CGFloat duration = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];

    self.systemKeyboardHeight = 0;
    [self animateTextViewWithDuration:duration keyboardHeight:self.systemKeyboardHeight];
}

- (void)animateTextViewWithDuration:(CGFloat)duration keyboardHeight:(CGFloat)height {
    CGFloat navbarHeight = [self navbarHeight];
    CGFloat toolbarHeight = [self toolbarHeightWithKeyboardShow:self.isSystemKeyboardVisible];
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.size.height = self.view.bounds.size.height - navbarHeight - VGAP_BETWEEN_NAV_AND_TEXT_VIEW - toolbarHeight - height;
    self.textView.internalGrowingTextView.maxHeight = textViewFrame.size.height;
    CGRect interTextViewFrame = self.textView.internalGrowingTextView.frame;
    CGFloat interTextViewContentHeight = [self.textView.internalGrowingTextView measureHeight];
    interTextViewFrame.size.height = (interTextViewContentHeight < textViewFrame.size.height) ? interTextViewContentHeight : textViewFrame.size.height;
    self.textView.internalGrowingTextView.frame = interTextViewFrame;
    [UIView animateWithDuration:duration animations:^{
        self.textView.frame = textViewFrame;
    }];
}

- (NSAttributedString *)wordCountAttributeStringWithTextCount: (NSInteger)textLength {
    NSString *wordCountString = [NSString stringWithFormat:@"%@/%@", @(textLength), @(MAX_WORD_COUNT)];
    NSInteger wordCountLength = @(textLength).stringValue.length;
    NSMutableAttributedString *wordCountAttributeString = [[NSMutableAttributedString alloc] initWithString:wordCountString];
    [wordCountAttributeString addAttribute:NSForegroundColorAttributeName value:(textLength >= MAX_WORD_COUNT) ? [UIColor themeRed1] : [UIColor themeGray1] range:NSMakeRange(0, wordCountLength)];
    [wordCountAttributeString addAttribute:NSFontAttributeName value:[UIFont themeFontRegular:14] range:NSMakeRange(0, wordCountLength)];
    [wordCountAttributeString addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray3] range:NSMakeRange(wordCountLength, wordCountString.length - wordCountLength)];
    [wordCountAttributeString addAttribute:NSFontAttributeName value:[UIFont themeFontRegular:14] range:NSMakeRange(wordCountLength, wordCountString.length - wordCountLength)];
    return wordCountAttributeString;
}

- (void)completeButtonPressed:(UIButton *)sender {
    [self traceCompletedButtonPressed];
    if(self.textView.text.length == 0) {
        [self showAlertToAskUserDecision:NO];
    } else {
        [self showActionSheet];
    }
}

- (void)showActionSheet {
    [self traceAlertShowWhenCompletedPressed];
    [self.textView resignFirstResponder];
    
    NSString *title = @"向圈子中的人发送公告？";
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: title message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *saveOnlyAction = [UIAlertAction actionWithTitle:@"仅保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionWithType:ActionTypeSaveOnly];
    }];
    
    UIAlertAction *sendSMSAction = [UIAlertAction actionWithTitle:@"消息通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionWithType:ActionTypeSMS];
    }];
    
    UIAlertAction *pushAction = [UIAlertAction actionWithTitle:@"推送通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionWithType:ActionTypePush];
    }];
    
    UIAlertAction *pushAndSMSAction = [UIAlertAction actionWithTitle:@"消息加推送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionWithType:ActionTypePushAndSMS];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.textView becomeFirstResponder];
    }];
    
    [alertVC addAction:saveOnlyAction];
    [alertVC addAction:sendSMSAction];
    [alertVC addAction:pushAction];
    [alertVC addAction:pushAndSMSAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)actionWithType:(ActionType)actionType {
    
    [[ToastManager manager] showCustomLoading:@"正在保存"];
    // 弹窗选项点击埋点
    [self traceAlertOptionClickWhenCompletedPressedWithActionType:actionType];
    
    // 发送请求
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"social_group_id"] = @(self.socialGroupId.longLongValue);
    params[@"announcement"] = self.textView.text;
    params[@"push_type"] = @(actionType);

    [FHHouseUGCAPI requestUpdateUGCNoticeWithParam:params completion:^(FHUGCNoticeModel *model, NSError * _Nonnull error) {
        
        [[ToastManager manager] dismissCustomLoading];
        
        if(error) {
            [[ToastManager manager] showToast:@"网络不佳， 公告更新失败，请重试"];
            [self.textView becomeFirstResponder];
        }
        else {
            [[ToastManager manager] showToast:@"操作成功"];
            if(self.callback) {
                self.callback(model.data.announcement);
            }
            [self exitPage];
        }
        
    }];
}

- (void)exitPage {
    [self.textView endEditing:YES];
    [self goBack];
}

- (void)showAlertToAskUserDecision:(BOOL)isLeftButtonAction {
    
    [self.textView resignFirstResponder];
    
    BOOL isEmpty = (self.textView.text.length == 0) && ![self.textView.text isEqualToString:self.content];
    BOOL isShowEmptyAlert = isEmpty && !isLeftButtonAction;
    
    NSString *title = isShowEmptyAlert ? @"确定清空公告栏?" : @"退出编辑?";
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    if(isShowEmptyAlert) {
        [self traceAlertShowWhenUserDecideWithEventName:@"notice_empty_popup_show"];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self traceAlertClickWhenUserDecideWithOptionName:@"cancel"];
        }];
        UIAlertAction *confirmEmptyAction = [UIAlertAction actionWithTitle:@"清空" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actionWithType:ActionTypeSaveOnly];
            [self traceAlertClickWhenUserDecideWithOptionName:@"empty"];
        }];
        [alertVC addAction:cancelAction];
        [alertVC addAction:confirmEmptyAction];
    }
    else {
        [self traceAlertShowWhenUserDecideWithEventName:@"notice_quit_popup_show"];
        UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self exitPage];
            [self traceAlertClickWhenUserDecideWithOptionName:@"quit"];
        }];
        UIAlertAction *continueEditAction = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.textView becomeFirstResponder];
            [self traceAlertClickWhenUserDecideWithOptionName:@"continue_edit"];
        }];
        [alertVC addAction:exitAction];
        [alertVC addAction:continueEditAction];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (TTUGCTextViewMediator *)textViewMediator {
    if(!_textViewMediator) {
        _textViewMediator = [TTUGCTextViewMediator new];
        _textViewMediator.showCanBeCreatedHashtag = NO;
    }
    return _textViewMediator;
}

- (UITapGestureRecognizer *)toggleKeyboardTapGesture {
    return [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleKeyboard:)];
}

- (void)toggleKeyboard: (UITapGestureRecognizer*)tap {
    if(self.isSystemKeyboardVisible) {
        [self.textView resignFirstResponder];
    }
    else {
        [self.textView becomeFirstResponder];
    }
}
 
- (void)navigationControllerPanGestureDisable:(BOOL)isDisable {
    if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
        [(TTNavigationController*)self.navigationController panRecognizer].enabled = self.isReadOnly || !isDisable;
    }
}

// MARK: 埋点

- (void)traceCompletedButtonPressed {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    param[@"click_position"] = @"passport_publisher";
    TRACK_EVENT(@"feed_publish_click", param);
}

- (void)traceAlertShowWhenCompletedPressed {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    TRACK_EVENT(@"notice_sendtype_popup_show", param);
}

- (void)traceAlertOptionClickWhenCompletedPressedWithActionType: (ActionType)actionType {
    NSString *traceClickNameString = @"";
    
    switch (actionType) {
        case ActionTypeSaveOnly:
            traceClickNameString = @"only_save";
            break;
        case ActionTypeSMS:
            traceClickNameString = @"save_message";
            break;
        case ActionTypePush:
            traceClickNameString = @"save_push";
            break;
        case ActionTypePushAndSMS:
            traceClickNameString = @"save_push_message";
            break;
        default:
            break;
    }
    
    if(traceClickNameString.length > 0) {
        NSMutableDictionary *param = @{}.mutableCopy;
        param[UT_PAGE_TYPE] = [self pageTypeString];
        param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
        param[@"click_position"] = traceClickNameString;
        TRACK_EVENT(@"notice_sendtype_popup_click", param);
    }
}

- (void)traceAlertShowWhenUserDecideWithEventName: (NSString *)eventName {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    TRACK_EVENT(eventName, param);
}

- (void)traceAlertClickWhenUserDecideWithOptionName:(NSString *)optionName {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    param[@"click_position"] = optionName;
    TRACK_EVENT(@"notice_empty_popup_click", param);
}

- (NSString *)pageTypeString {
    return @"community_notice_edit_detail";
}

// MARK: TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    
    if(textView.attributedText.length > MAX_WORD_COUNT) {
        textView.text = [TTUGCEmojiParser stringify:[textView.attributedText attributedSubstringFromRange:NSMakeRange(0, MAX_WORD_COUNT)]];
    }
    
    self.wordCountLabel.attributedText = [self wordCountAttributeStringWithTextCount: textView.attributedText.length];
    
    self.completeButton.enabled = ![self.content isEqualToString:self.textView.text];
}

- (void)toolbarDidClickEmojiButton:(BOOL)switchToEmojiInput {
    CGFloat emojiInputViewHeight = self.toolbar.emojiInputView.frame.size.height;
    if(switchToEmojiInput) {
        [self animateTextViewWithDuration:0.25 keyboardHeight:emojiInputViewHeight];
    }
    else {
        [self animateTextViewWithDuration:0.25 keyboardHeight:self.systemKeyboardHeight];
    }
}

- (void)toolbarDidClickKeyboardButton:(BOOL)switchToKeyboardInput {
    if(switchToKeyboardInput) {
        // nothing for now
    }
    else {
        [self animateTextViewWithDuration:0.25 keyboardHeight:self.systemKeyboardHeight];
    }
}
@end

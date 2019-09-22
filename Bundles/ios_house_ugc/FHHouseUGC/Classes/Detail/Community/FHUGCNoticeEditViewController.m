//
//  FHUGCNoticeEditViewController.m
//  Pods
//
//  Created by wangzhizhou on 2019/9/20.
//

#import "FHUGCNoticeEditViewController.h"
#import "UIViewController+Track.h"
#import <Masonry.h>
#import <FHHouseUGCAPI.h>
#import <ToastManager.h>
#import "FHUserTracker.h"

typedef enum : NSUInteger {
    ActionTypeSaveOnly,
    ActionTypeSMS,
    ActionTypePush,
    ActionTypePushAndSMS
} ActionType;

#define MAX_WORD_COUNT 200

#define TEXT_VIEW_FONT_SIZE 16
#define TEXT_VIEW_LINE_HEIGHT 24

@interface FHUGCNoticeTextView: UITextView
@end
@implementation FHUGCNoticeTextView
// 定制光标高度
-(CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect originalRect = [super caretRectForPosition:position];
    originalRect.size.height = TEXT_VIEW_FONT_SIZE + 2;
    originalRect.origin.y += 2 + (TEXT_VIEW_LINE_HEIGHT - originalRect.size.height) / 2.0;
    return originalRect;
}
@end

@interface FHUGCNoticeEditViewController () <UITextViewDelegate>
@property (nonatomic, strong) FHUGCNoticeTextView *textView;
@property (nonatomic, strong) UILabel *wordCountLabel;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UIButton *completeButton;
@property (nonatomic, copy) void (^callback)(NSString *);
@end

@implementation FHUGCNoticeEditViewController

#pragma mark - 属性成员

- (FHUGCNoticeTextView *)textView {
    if(!_textView) {
        _textView = [FHUGCNoticeTextView new];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.maximumLineHeight = TEXT_VIEW_LINE_HEIGHT;
        paragraphStyle.minimumLineHeight = TEXT_VIEW_LINE_HEIGHT;
        _textView.typingAttributes = @{
            NSForegroundColorAttributeName: [UIColor themeGray1],
            NSFontAttributeName: [UIFont themeFontRegular:TEXT_VIEW_FONT_SIZE],
            NSParagraphStyleAttributeName: paragraphStyle
        };
        _textView.tintColor = [UIColor themeRed1];
        _textView.delegate = self;
        [_textView becomeFirstResponder];
        _textView.text = self.content;
    }
    return _textView;
}

- (UILabel *)wordCountLabel {
    if(!_wordCountLabel) {
        _wordCountLabel = [UILabel new];
        _wordCountLabel.textAlignment = NSTextAlignmentRight;
        _wordCountLabel.hidden = YES;
        
        _wordCountLabel.attributedText = [self wordCountAttributeStringWithTextCount:self.content.length];
        _wordCountLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkKeyboard:)];
        [_wordCountLabel addGestureRecognizer:tapGesture];
    }
    return _wordCountLabel;
}

-(UIButton *)completeButton {
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

#pragma mark - 生命周期

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        self.content = paramObj.allParams[@"content"];
        self.callback = paramObj.allParams[@"callback"];
        self.title = @"编辑公告";
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

#pragma mark - UI

- (void)configNavBar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.textColor = [UIColor themeGray1];
    self.customNavBarView.title.font = [UIFont themeFontMedium:16];
    self.customNavBarView.title.text = self.title;
    
    __weak typeof(self) wself = self;
    self.customNavBarView.leftButtonBlock = ^{
        if(![wself.textView.text isEqualToString:wself.content]) {
            [wself showAlertToAskUserDecision];
        } else {
            [wself exitPage];
        }
    };
    
    [self.customNavBarView addSubview:self.completeButton];
    
    [self.completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.customNavBarView.title);
        make.right.equalTo(self.customNavBarView).offset(-20);
        make.width.height.mas_offset(40);
    }];
}


-(void)configContent {
    [self.view addSubview:self.textView];
    [self.view addSubview:self.wordCountLabel];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.customNavBarView.mas_bottom).offset(15);
        make.bottom.equalTo(self.wordCountLabel.mas_top);
    }];
    
    [self.wordCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(32);
        make.bottom.equalTo(self.view);
    }];
}

-(void)configNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Logic

-(void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat durition = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];

    CGRect keyboardRect = [notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];

    CGFloat keyboardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:durition animations:^{
        [self.wordCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-keyboardHeight-4);
        }];
        self.wordCountLabel.hidden = NO;
    }];
    
    [self.wordCountLabel.superview layoutIfNeeded];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    CGFloat duration = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];

    [UIView animateWithDuration:duration animations:^{
        [self.wordCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(0);
        }];
        self.wordCountLabel.hidden = YES;
    }];
    
    [self.wordCountLabel.superview layoutIfNeeded];
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
        [self showAlertToAskUserDecision];
    } else {
        [self showActionSheet];
    }
}

- (void)showActionSheet {
    [self traceAlertShowWhenCompletedPressed];
    [self.textView resignFirstResponder];
    
    NSString *title = @"向圈子中的人发送公告";
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

-(void)actionWithType:(ActionType)actionType {
    
    NSString *requestType = @"";
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
    // 弹窗选项点击埋点
    [self traceAlertOptionClickWhenCompletedPressedWithOptionName:traceClickNameString];
    
    // 发送请求
    [[ToastManager manager] showCustomLoading:@"正在保存"];
    [FHHouseUGCAPI requestUpdateUGCNoticeContent:self.textView.text actionType:requestType completion:^(NSError * _Nonnull error) {
        
        [[ToastManager manager] dismissCustomLoading];
        
        if(error) {
            [[ToastManager manager] showToast:@"网络不佳， 公告更新失败，请重试" duration:3 isUserInteraction:YES];
            [self.textView becomeFirstResponder];
        }
        else {
            if(self.callback) {
                self.callback(self.textView.text);
            }
            [self exitPage];
        }
        
    }];
}

- (void)exitPage {
    [self.textView endEditing:YES];
    [self goBack];
}

- (void)showAlertToAskUserDecision {
    
    [self.textView resignFirstResponder];
    
    BOOL isEmpty = (self.textView.text.length == 0);
    NSString *title = isEmpty ? @"确定清空公告栏?" : @"退出编辑?";
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    if(isEmpty) {
        [self traceAlertShowWhenUserDecideWithEventName:@"notice_empty_popup_show"];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.textView becomeFirstResponder];
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

- (void)shrinkKeyboard: (UITapGestureRecognizer *)tap {
    [self.textView resignFirstResponder];
}

#pragma mark - 埋点

-(void)traceCompletedButtonPressed {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    param[@"click_position"] = @"passport_publisher";
    TRACK_EVENT(@"feed_publish_click", param);
}

-(void)traceAlertShowWhenCompletedPressed {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = [self pageTypeString];
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    TRACK_EVENT(@"notice_sendtype_popup_show", param);
}

-(void)traceAlertOptionClickWhenCompletedPressedWithOptionName: (NSString *)name {
    if(name.length > 0) {
        NSMutableDictionary *param = @{}.mutableCopy;
        param[UT_PAGE_TYPE] = [self pageTypeString];
        param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
        param[@"click_position"] = name;
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

-(NSString *)pageTypeString {
    return @"community_notice_edit_detail";
}
#pragma mark - UItextViewDelegate
-(void)textViewDidChange:(UITextView *)textView {
    
    if(textView.text.length > MAX_WORD_COUNT) {
        textView.text = [textView.text substringWithRange:NSMakeRange(0, MAX_WORD_COUNT)];
    }
    
    self.wordCountLabel.attributedText = [self wordCountAttributeStringWithTextCount: textView.text.length];
    
    self.completeButton.enabled = ![self.content isEqualToString:self.textView.text];
}
@end

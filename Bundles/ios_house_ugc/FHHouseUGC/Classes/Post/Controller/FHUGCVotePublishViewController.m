//
//  FHUGCVotePublishViewController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import "FHUGCVotePublishViewController.h"
#import "FHUGCVoteViewModel.h"
#import "SSNavigationBar.h"
#import <WDDefines.h>
#import <FHCommonDefines.h>
#import <ReactiveObjC.h>
#import "FHUserTracker.h"
#import <TTAccount.h>
#import <FHBubbleTipManager.h>
#import "TTAccountManager.h"

@interface FHUGCVotePublishViewController()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) FHUGCVoteViewModel *viewModel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *publishBtn;

// 数据区
@property (nonatomic, assign) BOOL hasSocialGroup;      // 是否外部带入圈子信息
@property (nonatomic, copy) NSString *selectGroupId;
@property (nonatomic, copy) NSString *selectGroupName;
@property (nonatomic, assign) BOOL isSelectectGroupFollowed;
@property (nonatomic, assign) BOOL  lastCanShowMessageTip;

@property (nonatomic, assign) CGRect keyboardEndFrame;
@property (nonatomic, assign) BOOL keyboardIsShow;
@end

@implementation FHUGCVotePublishViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.selectGroupId = [paramObj.allParams tt_stringValueForKey:@"select_group_id"];
        self.selectGroupName = [paramObj.allParams tt_stringValueForKey:@"select_group_name"];
        self.isSelectectGroupFollowed = [paramObj.allParams tta_boolForKey:@"select_group_followed"];
        self.hasSocialGroup = self.selectGroupId.length > 0 && self.selectGroupName.length > 0;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 禁止在发布器页面弹出IM顶部消息弹窗
    self.lastCanShowMessageTip = [FHBubbleTipManager shareInstance].canShowTip;
    [FHBubbleTipManager shareInstance].canShowTip = NO;
    
    // 配置导航条
    [self configNavigation];
    // 添加ScrollView
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#EBEBF0"];
    self.viewModel = [[FHUGCVoteViewModel alloc] initWithScrollView:self.scrollView ViewController:self];
    
    // 从圈子详情页带入的圈子信息
    if(self.hasSocialGroup) {
        [self.viewModel configModelForSocialGroupId:self.selectGroupId socialGroupName:self.selectGroupName hasFollowed:self.isSelectectGroupFollowed];
    }
    // 注册通知
    [self registerNotification];
}

-(void)dealloc {
    [FHBubbleTipManager shareInstance].canShowTip = self.lastCanShowMessageTip;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)keyboardWillChangeFrame: (NSNotification *)notification {
    CGRect beginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    BOOL isShrinking = beginFrame.origin.y < endFrame.origin.y;
    
    CGRect scrollViewFrame = self.scrollView.frame;
    
    if(isShrinking) {
        scrollViewFrame.size.height = self.view.bounds.size.height - kNavigationBarHeight;
    } else {
        scrollViewFrame.size.height = self.view.bounds.size.height - kNavigationBarHeight - endFrame.size.height;
    }
    
    self.scrollView.frame = scrollViewFrame;
}

- (void)keyboardDidChangeFrame: (NSNotification *)notification {
    CGRect beginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardIsShow = beginFrame.origin.y >= self.keyboardEndFrame.origin.y;
    
    // 键盘弹起时，如果有输入焦点视图，则滚动到其露出
    [self scrollToVisibleForFirstResponderView];

}

- (void)scrollToVisibleForFirstResponderView {
    if(self.firstResponderView && self.keyboardIsShow) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        CGRect keyboardRect = [keyWindow convertRect:self.keyboardEndFrame toView:self.scrollView];
        
        CGRect rect = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:self.scrollView];
        
        CGFloat offsetY = (rect.origin.y + rect.size.height) - keyboardRect.origin.y;
        
        if(offsetY > 0) {
            CGPoint contentOffset = self.scrollView.contentOffset;
            contentOffset.y += offsetY;
            [self.scrollView setContentOffset:contentOffset animated:YES];
        }
    }
    self.firstResponderView = nil;
}

- (void)configNavigation {
    
    [self setupDefaultNavBar:YES];
    
    // 标题
    self.navigationItem.titleView = self.titleLabel;
    
    // 取消按钮
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn]];
    
    // 发布按钮
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.publishBtn]];
    
}

- (void)cancelAction: (UIButton *)cancelBtn {
    
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.size.height = self.view.bounds.size.height - kNavigationBarHeight;
    self.scrollView.frame = scrollViewFrame;
    [self.scrollView endEditing:YES];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_PAGE_TYPE] = @"vote_publisher";
    params[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
    params[@"click_position"] = @"publisher_cancel";
    TRACK_EVENT(@"click_options", params);
    
    if([self.viewModel isEditedVote]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"编辑未完成" message: @"退出后编辑的内容将不会被保存" preferredStyle:UIAlertControllerStyleAlert];
        
        WeakSelf;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            StrongSelf;
            [self exitPage];
            
            NSMutableDictionary *params = @{}.mutableCopy;
            params[UT_PAGE_TYPE] = @"vote_publisher";
            params[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
            params[@"click_position"] = @"confirm";
            TRACK_EVENT(@"publisher_cancel_popup_click", params);
        }];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary *params = @{}.mutableCopy;
            params[UT_PAGE_TYPE] = @"vote_publisher";
            params[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
            params[@"click_position"] = @"cancel";
            TRACK_EVENT(@"publisher_cancel_popup_click", params);
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSMutableDictionary *params = @{}.mutableCopy;
        params[UT_PAGE_TYPE] = @"vote_publisher";
        params[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
        TRACK_EVENT(@"publisher_cancel_popup_show", params);
        
    } else {
        [self exitPage];
    }
}

- (void)exitPage {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers && viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)publishAction: (UIButton *)publishBtn {
    
    if(self.viewModel.isPublishing) {
        // 防止连点发布
        return ;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_PAGE_TYPE] = @"vote_publisher";
    params[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
    params[@"click_position"] = @"passport_publisher";
    TRACK_EVENT(@"feed_publish_click", params);
    
    if ([TTAccountManager isLogin]) {
        [self.viewModel publish];
    } else {
        // 应该不会走到当前位置，UGC外面限制强制登录
        [self gotoLogin];
    }
    
    
}

- (NSString *)pageType {
    return @"vote_publisher";
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
                    [self.viewModel publish];
                });
            }
        }
    }];
}

- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, self.view.bounds.size.height - kNavigationBarHeight)];
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIButton *)cancelBtn {
    if(!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_cancelBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(0, 0, 32, 44);
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"投票";
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UIButton *)publishBtn {
    if(!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishBtn.frame = CGRectMake(0, 0, 32, 44);
        _publishBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_publishBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [_publishBtn setTitle:@"发布" forState:UIControlStateNormal];
        [_publishBtn addTarget:self action:@selector(publishAction:) forControlEvents:UIControlEventTouchUpInside];
        _publishBtn.enabled = NO;
    }
    return _publishBtn;
}

- (void)enablePublish:(BOOL)isEnable {
    if(isEnable) {
        [self.publishBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    } else {
        [self.publishBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
    }
    self.publishBtn.enabled = isEnable;
}
@end
                      
                      

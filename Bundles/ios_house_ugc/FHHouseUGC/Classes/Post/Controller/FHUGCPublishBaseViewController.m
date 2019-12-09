//
//  FHUGCPublishBaseViewController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/22.
//

#import "FHUGCPublishBaseViewController.h"
#import <FHBubbleTipManager.h>

@interface FHUGCPublishBaseViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *publishBtn;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL lastCanShowMessageTip;

@end

@implementation FHUGCPublishBaseViewController

// 进入页面初始化成员
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        NSString *title  = paramObj.allParams[@"title"];
        if(title.length > 0) {
            self.title = title;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigation];
    
    // 发布器内禁止接收IM消息弹窗
    self.lastCanShowMessageTip = [FHBubbleTipManager shareInstance].canShowTip;
    [FHBubbleTipManager shareInstance].canShowTip = NO;
}

- (void)dealloc {
    
    [FHBubbleTipManager shareInstance].canShowTip = self.lastCanShowMessageTip;
}

// 配置导航条
- (void)configNavigation {
    
    [self setupDefaultNavBar:YES];
    
    // 标题
    self.navigationItem.titleView = self.titleLabel;
    
    // 取消按钮
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn]];
    
    // 发布按钮
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.publishBtn]];
    
    [self enablePublish:NO];
}

- (void)publishBtnClickable:(BOOL)isClickable {
    self.publishBtn.userInteractionEnabled = isClickable;
}

# pragma mark - UI 控件区

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
        _titleLabel.text = self.title;
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UIButton *)publishBtn {
    if(!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishBtn.frame = CGRectMake(0, 0, 32, 44);
        [_publishBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [_publishBtn setTitle:@"发布" forState:UIControlStateNormal];
        _publishBtn.titleLabel.font = [UIFont themeFontMedium:16];
        [_publishBtn addTarget:self action:@selector(publishAction:) forControlEvents:UIControlEventTouchUpInside];
        _publishBtn.enabled = NO;
    }
    return _publishBtn;
}

#pragma mark - 控件事件区

- (void)cancelAction: (UIButton *)cancelBtn {
    [self exitPage];
}

- (void)publishAction: (UIButton *)publishBtn {
    // 默认行为， 子类覆盖改写
    [self exitPage];
}

- (void)exitPage {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 成员方法

- (void)enablePublish:(BOOL)isEnable {
    if(isEnable) {
        [self.publishBtn setTitleColor:[UIColor themeRed] forState:UIControlStateNormal];
    } else {
        [self.publishBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
    }
    self.publishBtn.enabled = isEnable;
}

@end

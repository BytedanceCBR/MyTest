//
//  FHUGCPublishBaseViewController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/22.
//

#import "FHUGCPublishBaseViewController.h"
#import <ReactiveObjC.h>

@interface FHUGCPublishBaseViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *publishBtn;

@property (nonatomic, copy) NSString *title;

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
    
    @weakify(self);
    [[[[self.publishBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(__kindof UIButton * _Nullable sender) {
        @strongify(self);
        
        // 设置防止连续点击逻辑
        self.publishBtn.userInteractionEnabled = NO;
        [self performSelector:@selector(recoverPublishButtonClickable) withObject:nil afterDelay:1];
        
        // 按钮点击事件处理函数，可由子类覆盖
        [self publishAction: sender];
        
    }];
}

- (void)recoverPublishButtonClickable {
    self.publishBtn.userInteractionEnabled = YES;
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

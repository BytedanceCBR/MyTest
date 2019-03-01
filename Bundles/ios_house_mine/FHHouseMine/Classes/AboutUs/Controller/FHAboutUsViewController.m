//
//  FHAboutUsViewController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/15.
//

#import "FHAboutUsViewController.h"
#import "SSNavigationBar.h"
#import "TTNavigationController.h"
#import <Masonry/Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <TTSandBoxHelper.h>

@interface FHAboutUsViewController ()

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *versionLabel;

@end

@implementation FHAboutUsViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNaviBar];
    [self initViews];
    [self initContraints];
}

- (void)initNaviBar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"关于我们";
}

- (void)initViews {
    self.iconView = [[UIImageView alloc] init];
    _iconView.image = [UIImage imageNamed:@"about"];
    [self.view addSubview:_iconView];
    
    self.versionLabel = [[UILabel alloc] init];
    _versionLabel.font = [UIFont themeFontRegular:16];
    _versionLabel.textColor = [UIColor themeGray];
    _versionLabel.text = [NSString stringWithFormat:@"版本号%@",[TTSandBoxHelper versionName]];
    [self.view addSubview:_versionLabel];
    
}

- (void)initContraints {
    CGFloat bottom = 0.0f;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(14);
        make.bottom.mas_equalTo(self.view).offset(-bottom-20);
    }];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

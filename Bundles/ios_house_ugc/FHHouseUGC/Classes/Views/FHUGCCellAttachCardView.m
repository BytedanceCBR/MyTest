//
//  FHUGCCellAttachCardView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/3/19.
//

#import "FHUGCCellAttachCardView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"
#import "FHUserTracker.h"
#import "UIImageView+BDWebImage.h"
#import "TTRoute.h"
#import "JSONAdditions.h"
#import "FHUGCCellHelper.h"

@interface FHUGCCellAttachCardView ()

@property(nonatomic ,strong) UIImageView *iconView;
@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UIView *spLine;
@property(nonatomic ,strong) UIButton *button;

@end

@implementation FHUGCCellAttachCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor themeGray7];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    //这里有个坑，加上手势会导致@不能点击
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDetail)];
    [self addGestureRecognizer:singleTap];
    
    self.iconView = [[UIImageView alloc] init];
    _iconView.backgroundColor = [UIColor whiteColor];
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    _iconView.layer.cornerRadius = 4;
    _iconView.layer.masksToBounds = YES;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    [self addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self addSubview:_descLabel];
    
    self.spLine = [[UIView alloc] init];
    _spLine.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
    [self addSubview:_spLine];
    
    self.button = [[UIButton alloc] init];
    [_button setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    _button.titleLabel.font = [UIFont themeFontRegular:12];
    [_button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

- (void)initConstraints {
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-15);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(50);
    }];
    
    [self.spLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.button.mas_left).offset(-9.5);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(17);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(8);
        make.right.mas_equalTo(self.spLine.mas_left).offset(-5);
        make.top.mas_equalTo(self).offset(9);
        make.height.mas_equalTo(22);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.right.mas_equalTo(self.titleLabel.mas_right);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo(17);
    }];
}

- (void)refreshWithdata:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        self.cellModel = cellModel;
        
        [self.iconView bd_setImageWithURL:[NSURL URLWithString:cellModel.attachCardInfo.coverImage.url] placeholder:nil];
        self.titleLabel.text = cellModel.attachCardInfo.title;
        self.descLabel.text = cellModel.attachCardInfo.desc;
        
        NSString *buttonTitle = cellModel.attachCardInfo.button.name;
        if(buttonTitle.length > 0 && cellModel.attachCardInfo.button.schema.length > 0){
            self.button.hidden = NO;
            self.spLine.hidden = NO;
            if(buttonTitle.length > 4){
                buttonTitle = [buttonTitle substringToIndex:4];
            }
            [_button setTitle:buttonTitle forState:UIControlStateNormal];
            [self.button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_lessThanOrEqualTo(50);
            }];
            [self.spLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.button.mas_left).offset(-9.5);
            }];
        }else{
            self.button.hidden = YES;
            self.spLine.hidden = YES;
            [self.button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_lessThanOrEqualTo(0);
            }];
            [self.spLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.button.mas_left).offset(0);
            }];
        }
    }
}

- (void)goToDetail {
    NSString *routeUrl = self.cellModel.attachCardInfo.schema;
    if(routeUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

- (void)buttonClick {
    NSString *routeUrl = self.cellModel.attachCardInfo.button.schema;
//    routeUrl = @"sslocal://ugc_post?post_content=%23%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%23+&post_content_rich_span=%7b%22links%22%3a%5b%7b%22link%22%3a%22sslocal%3a%5c%2f%5c%2fconcern%3fcid%3d1657155140612119%26name%3d%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%22%2c%22flag%22%3a0%2c%22length%22%3a9%2c%22user_info%22%3a%7b%22forum_name%22%3a%22%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%22%2c%22concern_id%22%3a%221657155140612119%22%2c%22color_info%22%3a%7b%22day%22%3a%22%23FF8151%22%2c%22night%22%3a%22%23FF8151%22%7d%2c%22forum_id%22%3a%221657155140612119%22%7d%2c%22type%22%3a2%2c%22start%22%3a0%7d%5d%7d";
    
    
    
    if(routeUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        if(([openUrl.host isEqualToString:@"ugc_post"] || [openUrl.host isEqualToString:@"ugc_vote_publish"] || [openUrl.host isEqualToString:@"ugc_wenda_publish"]) && ![TTAccountManager isLogin]){
            //发布器
            [self gotoLogin];
        }else{
//            NSMutableDictionary *dict = @{}.mutableCopy;
//            dict[@"from_page"] = self.cellModel.tracerDic[@"page_type"] ? self.cellModel.tracerDic[@"page_type"] : @"default";
//            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            
            TTRouteParamObj *params = [[TTRoute sharedRoute] routeParamObjWithURL:openUrl];
            
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
        }
    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}


- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *page_type = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    [params setObject:page_type forKey:@"enter_from"];
    [params setObject:@"click_publisher_moments" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self gotoJumpVC];
                });
            }
        }
    }];
}

// 跳转
- (void)gotoJumpVC {
    NSString *routeUrl = self.cellModel.attachCardInfo.button.schema;
//    routeUrl = @"sslocal://ugc_post?post_content=%23%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%23+&post_content_rich_span=%7b%22links%22%3a%5b%7b%22link%22%3a%22sslocal%3a%5c%2f%5c%2fconcern%3fcid%3d1657155140612119%26name%3d%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%22%2c%22flag%22%3a0%2c%22length%22%3a9%2c%22user_info%22%3a%7b%22forum_name%22%3a%22%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%22%2c%22concern_id%22%3a%221657155140612119%22%2c%22color_info%22%3a%7b%22day%22%3a%22%23FF8151%22%2c%22night%22%3a%22%23FF8151%22%7d%2c%22forum_id%22%3a%221657155140612119%22%7d%2c%22type%22%3a2%2c%22start%22%3a0%7d%5d%7d";
    
    if(routeUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

@end

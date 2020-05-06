//
//  FHUGCSearchView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/21.
//

#import "FHUGCSearchView.h"
#import "Masonry.h"
#import "UIViewAdditions.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTRoute.h"
#import "FHUserTracker.h"
#import "UIImage+FIconFont.h"

@interface FHUGCSearchView ()

@property(nonatomic , strong) UIImageView *icon;
@property(nonatomic , strong) UILabel *placeHolder;

@end

@implementation FHUGCSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [[UIColor themeGray6] CGColor];
    self.layer.borderWidth = 0.5f;
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSearch)];
    [self addGestureRecognizer:singleTap];
    
    self.icon = [[UIImageView alloc] init];
    _icon.image = ICON_FONT_IMG(16,@"\U0000e675",[UIColor themeGray3]);
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_icon];
    
    self.placeHolder = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    _placeHolder.textAlignment = NSTextAlignmentLeft;
    _placeHolder.text = @"搜索圈子";
    [self addSubview:_placeHolder];
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(10);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.placeHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.icon.mas_right).offset(4);
        make.right.mas_equalTo(self).offset(-10);
        make.height.mas_equalTo(20);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.height/2;
}

//进入搜索页
- (void)goToSearch {
    [self addGoToSearchLog];
    NSString *routeUrl = @"sslocal://ugc_search_list";
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary* searchTracerDict = [NSMutableDictionary dictionary];
    searchTracerDict[@"element_type"] = @"community_search";
    searchTracerDict[@"enter_from"] = @"neighborhood_tab";
    paramDic[@"tracer"] = searchTracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:paramDic];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)addGoToSearchLog {
    NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
    reportParams[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    reportParams[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    reportParams[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ?: @"be_null";
    [FHUserTracker writeEvent:@"click_community_search" params:reportParams];
}

@end

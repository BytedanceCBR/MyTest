//
//  FHPersonalHomePageHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHPersonalHomePageHeaderView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "TTDeviceHelper.h"
#import <UIView+XWAddForRoundedCorner.h>
#import "FHPersonalHomePageItemView.h"
#import <UIImageView+BDWebImage.h>
#import <TTRoute.h>
#import "TTPhotoScrollViewController.h"
#import "TTBaseMacro.h"
#import "TTInteractExitHelper.h"

#define iconWidth 60
#define topMargin 20
#define leftMargin 20
#define rightMargin 20
#define middleMargin 10

@interface FHPersonalHomePageHeaderView ()

@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *userNameLabel;
@property(nonatomic, strong) UIView *spLine;
@property(nonatomic, strong) FHPersonalHomePageItemView *commentView;
@property(nonatomic, strong) FHPersonalHomePageItemView *focusView;
@property(nonatomic, strong) FHPersonalHomePageModel *model;

@end

@implementation FHPersonalHomePageHeaderView

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
    
    self.icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    [_icon xw_roundedCornerWithRadius:iconWidth/2 cornerColor:[UIColor whiteColor]];
    [self addSubview:_icon];
    
    _icon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigAvatar:)];
    [_icon addGestureRecognizer:tap];
    
    self.userNameLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    [self addSubview:_userNameLabel];
    
    __weak typeof(self) wself = self;
    self.commentView = [[FHPersonalHomePageItemView alloc] initWithFrame:CGRectZero];
    _commentView.itemClickBlock = ^{
        [wself commentClicked];
    };
    [self addSubview:_commentView];
    
    self.focusView = [[FHPersonalHomePageItemView alloc] initWithFrame:CGRectZero];
    _focusView.itemClickBlock = ^{
        [wself focusClicked];
    };
    [self addSubview:_focusView];
    
    self.spLine = [[UIView alloc] init];
    _spLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_spLine];
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(topMargin);
        make.left.mas_equalTo(self).offset(leftMargin);
        make.width.height.mas_equalTo(iconWidth);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(25);
        make.left.mas_equalTo(self.icon.mas_right).offset(middleMargin);
        make.height.mas_equalTo(25);
    }];
    
//    CGFloat x = leftMargin + iconWidth + middleMargin;
//    CGFloat width = ([UIScreen mainScreen].bounds.size.width - x - rightMargin)/2;
    
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(middleMargin);
        make.top.mas_equalTo(self.userNameLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(17);
//        make.width.mas_equalTo(80);
    }];
    
    [self.spLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.commentView.mas_right).offset(middleMargin);
        make.centerY.mas_equalTo(self.commentView);
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(10);
    }];

    [self.focusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.spLine.mas_right).offset(9.5);
        make.centerY.mas_equalTo(self.commentView);
        make.height.mas_equalTo(17);
//        make.width.mas_equalTo(80);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateData:(FHPersonalHomePageModel *)model {
    self.model = model;
    self.userNameLabel.text = model.data.name;
    [self.icon bd_setImageWithURL:[NSURL URLWithString:model.data.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    [self.commentView updateWithTopContent:model.data.fCommentCount bottomContent:@"评论"];
    [self.focusView updateWithTopContent:model.data.fFollowSgCount bottomContent:@"关注"];
}

- (void)commentClicked {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"person_id"] = @"";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    //跳转到评论列表
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_comment_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)focusClicked {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"person_id"] = @"";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    //跳转到关注列表
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_focus_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)showBigAvatar:(UIView *)sender {
    TTPhotoScrollViewController * controller = [[TTPhotoScrollViewController alloc] init];
    controller.mode = PhotosScrollViewSupportBrowse;
    controller.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    NSMutableArray * infoModels = [NSMutableArray arrayWithCapacity:10];
   
    TTImageInfosModel * iModel = [[TTImageInfosModel alloc] initWithURL:self.model.data.bigAvatarUrl];
    if (iModel) {
        [infoModels addObject:iModel];
    }

    controller.imageInfosModels = infoModels;
    [controller setStartWithIndex:0];
    
    NSMutableArray * frames = [NSMutableArray arrayWithCapacity:9];
    CGRect frame = [self.icon convertRect:self.icon.bounds toView:nil];
    [frames addObject:[NSValue valueWithCGRect:frame]];
        
    controller.placeholderSourceViewFrames = frames;
    controller.placeholders = [self photoObjs];
    [controller presentPhotoScrollView];
}

- (NSArray *)photoObjs {
    NSMutableArray *photoObjs = [NSMutableArray array];
    if (self.icon.image) {
        [photoObjs addObject:self.icon.image];
    }
    return photoObjs;
}

@end

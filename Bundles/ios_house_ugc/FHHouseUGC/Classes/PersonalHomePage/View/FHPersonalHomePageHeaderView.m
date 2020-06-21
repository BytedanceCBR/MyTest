//
//  FHPersonalHomePageHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHPersonalHomePageHeaderView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import "FHPersonalHomePageItemView.h"
#import "UIImageView+BDWebImage.h"
#import "TTRoute.h"
#import "TTPhotoScrollViewController.h"
#import "TTBaseMacro.h"
#import "TTInteractExitHelper.h"
#import "FHUserTracker.h"
#import "TTAccountManager.h"
#import "TTUGCAttributedLabel.h"
#import "YYTextLayout.h"

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
@property(nonatomic, strong) NSDictionary *tracerDic;
@property(nonatomic ,strong) TTUGCAttributedLabel *descLabel;

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
    self.headerViewheight = 100;// 默认值
    self.backgroundColor = [UIColor whiteColor];
    
    self.icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = iconWidth/2;
    _icon.layer.borderWidth = 1;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
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
    
    self.descLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20 * 2, 0)];
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont themeFontRegular:13];
    _descLabel.layer.masksToBounds = YES;
    _descLabel.backgroundColor = [UIColor whiteColor];
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor themeGray3],
                                     NSFontAttributeName : [UIFont themeFontRegular:13]
                                     };
    self.descLabel.linkAttributes = linkAttributes;
    self.descLabel.activeLinkAttributes = linkAttributes;
    self.descLabel.inactiveLinkAttributes = linkAttributes;
    _descLabel.delegate = nil;
    self.descLabel.hidden = YES;
    [self addSubview:_descLabel];
    
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
    
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right);
        make.top.mas_equalTo(self.userNameLabel.mas_bottom);
        make.height.mas_equalTo(33);
    }];
    
    [self.spLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.commentView.mas_right);
        make.centerY.mas_equalTo(self.commentView);
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(10);
    }];

    [self.focusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.spLine.mas_right);
        make.centerY.mas_equalTo(self.commentView);
        make.height.mas_equalTo(33);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateData:(FHPersonalHomePageModel *)model tracerDic:(nonnull NSDictionary *)tracerDic refreshAvatar:(BOOL)refreshAvatar {
    self.model = model;
    self.tracerDic = tracerDic;
    self.userNameLabel.text = model.data.name;
    
    if(refreshAvatar){
        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.data.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    }
    
    if([model.data.fHomepageAuth integerValue] == 0 || [[TTAccountManager userID] isEqualToString:self.model.data.userId]){
        [self.commentView updateWithTopContent:(isEmptyString(model.data.fCommentCount) ? @"0" : model.data.fCommentCount) bottomContent:@"评论"];
        [self.focusView updateWithTopContent:(isEmptyString(model.data.fFollowSgCount) ? @"0" : model.data.fFollowSgCount) bottomContent:@"关注"];
    }else{
        [self.commentView updateWithTopContent:@"*" bottomContent:@"评论"];
        [self.focusView updateWithTopContent:@"*" bottomContent:@"关注"];
    }
    if (model.data.desc && [model.data.desc isKindOfClass:[NSString class]] && model.data.desc.length > 0) {
        self.descLabel.hidden = NO;
        NSString *descText = [NSString stringWithFormat:@"简介：%@",model.data.desc];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:descText attributes:@{NSForegroundColorAttributeName : [UIColor themeGray3],NSFontAttributeName : [UIFont themeFontRegular:13]}];
        self.descLabel.attributedText = attributedString;
        
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20 * 2, MAXFLOAT) text:attributedString];
        CGFloat height= layout.textBoundingSize.height;
        self.headerViewheight = 100 + height;
        [self.descLabel setText:attributedString];
        [self.descLabel sizeToFit];
    } else {
        self.descLabel.hidden = YES;
        self.headerViewheight = 100;
    }
}

- (void)commentClicked {
    if(([[TTAccountManager userID] isEqualToString:self.model.data.userId]) && [self.model.data.fCommentCount integerValue] != 0){
        [self tracerClickOptions:@"personal_comment_list"];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"uid"] = self.model.data.userId;
        dict[@"enter_from"] = @"personal_homepage_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到评论列表
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_comment_list"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)focusClicked {
    if(([self.model.data.fHomepageAuth integerValue] == 0 || [[TTAccountManager userID] isEqualToString:self.model.data.userId]) && [self.model.data.fFollowSgCount integerValue] != 0){
        [self tracerClickOptions:@"personal_join_list"];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"uid"] = self.model.data.userId;
        dict[@"enter_from"] = @"personal_homepage_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到关注列表
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_focus_list"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)showBigAvatar:(UIView *)sender {
    [self tracerClickOptions:@"personal_picture"];
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

#pragma mark - 埋点

- (void)tracerClickOptions:(NSString *)clickPosition {
    NSMutableDictionary *tracerDict = self.tracerDic.mutableCopy;
    
    tracerDict[@"click_position"] = clickPosition;
    [tracerDict removeObjectsForKeys:@[@"enter_type"]];
    
    TRACK_EVENT(@"click_options", tracerDict);
}

@end

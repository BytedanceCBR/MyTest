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
#import "TTSettingsManager.h"
#import "FHUserTracker.h"
#import "FHHouseContactDefines.h"

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
    _button.titleLabel.font = [UIFont themeFontRegular:14];
    [_button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
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
        make.width.mas_lessThanOrEqualTo(60);
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
                make.width.mas_lessThanOrEqualTo(60);
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
        
        if(cellModel.isFromDetail){
            [self trackCardShow:cellModel rank:0];
        }
    }
}

- (void)trackCardShow:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    if(cellModel.attachCardInfo.extra && cellModel.attachCardInfo.extra.event.length > 0){
        //是房源卡片
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"page_type"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
        dict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"] ?: @"be_null";
        dict[@"group_id"] = cellModel.attachCardInfo.extra.groupId ?: @"be_null";
        dict[@"from_gid"] = cellModel.attachCardInfo.extra.fromGid ?: @"be_null";
        dict[@"group_source"] = cellModel.attachCardInfo.extra.groupSource ?: @"be_null";
        dict[@"impr_id"] = cellModel.attachCardInfo.extra.imprId ?: @"be_null";
        dict[@"house_type"] = cellModel.attachCardInfo.extra.houseType ?: @"be_null";
        TRACK_EVENT(cellModel.attachCardInfo.extra.event ?: @"card_show", dict);
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"page_type"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
        dict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"] ?: @"be_null";
        dict[@"from_gid"] = cellModel.groupId;
        dict[@"group_source"] = @(5);
        dict[@"impr_id"] = cellModel.tracerDic[@"log_pb"][@"impr_id"] ?: @"be_null";
        dict[@"card_type"] = cellModel.attachCardInfo.cardType ?: @"be_null";
        dict[@"card_id"] = cellModel.attachCardInfo.id ?: @"be_null";
        TRACK_EVENT(@"card_show", dict);
    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)goToDetail {
    NSString *routeUrl = self.cellModel.attachCardInfo.schema;
    if(routeUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [self goToJump:openUrl];
    }
}

- (void)buttonClick {
    NSString *routeUrl = self.cellModel.attachCardInfo.button.schema;
//    routeUrl = @"sslocal://old_house_detail?house_id=6728303665725047048&realtor_id=2546093270238963";
//    routeUrl = @"sslocal://ugc_post?post_content=%23%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%23+&post_content_rich_span=%7b%22links%22%3a%5b%7b%22link%22%3a%22sslocal%3a%5c%2f%5c%2fconcern%3fcid%3d1657155140612119%26name%3d%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%22%2c%22flag%22%3a0%2c%22length%22%3a9%2c%22user_info%22%3a%7b%22forum_name%22%3a%22%e5%b0%8f%e5%8c%ba%e9%98%b2%e7%96%ab%e8%bf%9b%e8%a1%8c%e6%97%b6%22%2c%22concern_id%22%3a%221657155140612119%22%2c%22color_info%22%3a%7b%22day%22%3a%22%23FF8151%22%2c%22night%22%3a%22%23FF8151%22%7d%2c%22forum_id%22%3a%221657155140612119%22%7d%2c%22type%22%3a2%2c%22start%22%3a0%7d%5d%7d";
//    routeUrl = @"sslocal://concern?cid=1657234501953559";
//    routeUrl = @"sslocal://open_single_chat?target_user_id=3773114268258967&chat_title=%E7%8E%8B%E6%99%BA%E6%9D%B0&house_id=6728303665725047048&house_type=2&house_cover=http%3A%2F%2Fsf1-ttcdn-tos.pstatp.com%2Fimg%2Ff100-image%2FRSJnd5OAuXrV8C~750x0.jpeg&house_title=5%E5%AE%A41%E5%8E%85+%E7%89%A1%E4%B8%B9%E5%9B%AD&house_des=120%E5%B9%B3%2F%E4%B8%9C%2F%E9%AB%98%E6%A5%BC%E5%B1%82%2F%E9%9D%92%E9%BE%99%E5%A4%A7%E8%A1%97&house_price=2800%E4%B8%87&house_avg_price=233313%E5%85%83%2F%E5%B9%B3";
    
    if(routeUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [self goToJump:openUrl];
    }
}

- (void)goToJump:(NSURL *)openUrl {
    if([openUrl.host isEqualToString:@"ugc_post"]){
        //发布器
        if([TTAccountManager isLogin]){
            [self gotoPostVC:openUrl];
        }else{
            [self gotoLogin:openUrl];
        }
    }else if([openUrl.host isEqualToString:@"old_house_detail"]){
        //二手房房源详情页
        [self gotoHouseDetailVC:openUrl];
    }else if([openUrl.host isEqualToString:@"concern"]){
        //话题详情页
        [self gotoTopicDetailVC:openUrl];
    }else if([openUrl.host isEqualToString:@"open_single_chat"]){
        //跳im卡片
        [self imAction:openUrl];
    }else{
        //其他类型 直接跳转
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

- (void)gotoLogin:(NSURL *)openUrl {
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
                    [self gotoPostVC:openUrl];
                });
            }
        }
    }];
}

// 跳转
- (void)gotoPostVC:(NSURL *)openUrl {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"enter_from"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    dict[@"element_from"] = [self elementFrom];
    dict[@"group_id"] = self.cellModel.groupId;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

// 跳转二手房详情页
- (void)gotoHouseDetailVC:(NSURL *)openUrl {
    NSMutableDictionary *dict = @{}.mutableCopy;
    
    NSMutableDictionary *traceParam = [NSMutableDictionary new];
    traceParam[@"enter_from"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    traceParam[@"log_pb"] = self.cellModel.tracerDic[@"log_pb"] ?: @"be_null";
    traceParam[@"card_type"] = @"left_pic";
    traceParam[@"rank"] = self.cellModel.tracerDic[@"rank"] ?: @"be_null";
    traceParam[@"element_from"] = [self elementFrom];
    traceParam[@"from_gid"] = self.cellModel.groupId;
    
    dict[@"house_type"] = @(2);
    dict[@"tracer"] = traceParam;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

// 跳转话题详情页
- (void)gotoTopicDetailVC:(NSURL *)openUrl {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_from"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    traceParam[@"element_from"] = [self elementFrom];
    traceParam[@"enter_type"] = @"click";
    traceParam[@"rank"] = self.cellModel.tracerDic[@"rank"] ?: @"be_null";
    traceParam[@"log_pb"] = self.cellModel.tracerDic[@"log_pb"] ?: @"be_null";
    dict[@"tracer"] = traceParam;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)imAction:(NSURL *)openUrl {
    TTRouteParamObj *obj =[[TTRoute sharedRoute] routeParamObjWithURL:openUrl];
    [self addClickIM:obj];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *from = @"";
    if(self.cellModel.isFromDetail){
        from = @"app_weitoutiao";
        dict[kFHClueEndpoint] = @(FHClueEndPointTypeC);
        dict[kFHCluePage] = @(FHClueIMPageTypeUGCDetail);
    }else{
        from = @"app_feed_weitoutiao";
        dict[kFHClueEndpoint] = @(FHClueEndPointTypeC);
        dict[kFHCluePage] = @(FHClueIMPageTypeUGCFeed);
    }
    
    dict[@"from"] = from;
    dict[@"target_type"] = @(2);
    dict[@"enter_from"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    dict[@"element_from"] = [self elementFrom];
    dict[@"log_pb"] = self.cellModel.tracerDic[@"log_pb"] ?: @"be_null";
    dict[@"rank"] = self.cellModel.tracerDic[@"rank"] ?: @"be_null";
    dict[@"card_type"] = self.cellModel.tracerDic[@"card_type"] ? : @"be_null";
    dict[@"page_type"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    dict[@"realtor_id"] = obj.queryParams[@"target_user_id"] ?: @"be_null";
    dict[@"house_type"] = @"old";
    dict[@"impr_id"] = self.cellModel.tracerDic[@"log_pb"][@"impr_id"] ?: @"be_null";
    dict[@"group_id"] = self.cellModel.groupId;
    dict[@"group_type"] = @"weitoutiao";

    NSMutableDictionary * userInfoDict = @{@"tracer":dict, @"from": from}.mutableCopy;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)addClickIM:(TTRouteParamObj *)obj {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"] ?: @"be_null";
    dict[@"page_type"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    dict[@"house_type"] = @"old";
    dict[@"impr_id"] = self.cellModel.tracerDic[@"log_pb"][@"impr_id"] ?: @"be_null";
    dict[@"group_id"] = obj.queryParams[@"house_id"] ?: @"be_null";
    dict[@"from_gid"] = self.cellModel.groupId;
    dict[@"realtor_id"] = obj.queryParams[@"target_user_id"] ?: @"be_null";
//    event_type:
//    enter_from: neighborhood_tab（群聊tab）
//    page_type: hot_discuss_feed"（推荐列表页）
//    house_type:old(二手房)/new（新房）
//    impr_id: 继承微头条的impr_id即可
//    group_id:房源id
//    from_gid:微头条id
//    realtor_id:经纪人id
    
    TRACK_EVENT(@"click_im", dict);
}

- (NSString *)elementFrom {
    return @"feed_card";
}

@end

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
#import "UIViewAdditions.h"
#import "TTImageView+TrafficSave.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"

@interface FHUGCCellAttachCardView ()

@property(nonatomic ,strong) TTImageView *iconView;
@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UIView *spLine;
@property(nonatomic ,strong) UIButton *button;
@property(nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property(nonatomic, strong) FHFeedUGCCellRealtorModel *realtorModel;

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
    
    self.iconView = [[TTImageView alloc] init];
    _iconView.backgroundColor = [UIColor whiteColor];
    _iconView.imageContentMode = TTImageViewContentModeScaleAspectFill;
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
    [_button setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    _button.titleLabel.font = [UIFont themeFontRegular:14];
    _button.backgroundColor = [UIColor themeGray7];
    _button.layer.masksToBounds = YES;
    _button.titleLabel.backgroundColor = [UIColor themeGray7];
    _button.titleLabel.layer.masksToBounds = YES;
    [_button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

- (void)initConstraints {
    self.iconView.left = 10;
    self.iconView.width = 40;
    self.iconView.height = 40;
    self.iconView.top = (self.height - self.iconView.height)/2;
    
    self.titleLabel.left = self.iconView.right + 8;
    self.titleLabel.width = self.width - 58 - 75 - 10.5 - 5;
    self.titleLabel.top = 9;
    self.titleLabel.height = 22;
    
    self.descLabel.left = self.titleLabel.left;
    self.descLabel.top = self.titleLabel.bottom;
    self.descLabel.width = self.titleLabel.width;
    self.descLabel.height = 17;
    
    self.spLine.width = 1;
    self.spLine.height = 17;
    self.spLine.left = self.titleLabel.right + 5;
    self.spLine.centerY = self.iconView.centerY;
    
    self.button.width = 60;
    self.button.height = self.height;
    self.button.top = 0;
    self.button.left = self.spLine.right + 9.5;
}

- (void)refreshWithdata:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        if(self.cellModel == cellModel && !cellModel.ischanged){
            return;
        }
        
        self.cellModel = cellModel;
        
//        [self.iconView bd_setImageWithURL:[NSURL URLWithString:cellModel.attachCardInfo.coverImage.url] placeholder:nil];
        
        if (cellModel.attachCardInfo.imageModel && cellModel.attachCardInfo.imageModel.url.length > 0) {
            TTImageInfosModel *imageInfoModel = [FHUGCCellHelper convertTTImageInfosModel:cellModel.attachCardInfo.imageModel];
            __weak typeof(self) wSelf = self;
            [self.iconView setImageWithModelInTrafficSaveMode:imageInfoModel placeholderImage:nil success:nil failure:^(NSError *error) {
                [wSelf.iconView setImage:nil];
            }];
        }else{
            [self.iconView setImage:nil];
        }
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
            [_button sizeToFit];
            
            self.titleLabel.width = self.width - 58 - 15 - self.button.width - 10.5 - 5;
            self.descLabel.width = self.titleLabel.width;
            self.spLine.left = self.titleLabel.right + 5;
            self.button.height = self.height;
            self.button.left = self.spLine.right + 9.5;
        }else{
            self.button.hidden = YES;
            self.spLine.hidden = YES;
            
            self.titleLabel.width = self.width - 58 - 15;
            self.descLabel.width = self.titleLabel.width;
            self.spLine.left = self.titleLabel.right + 5;
            self.button.width = 0;
        }
        
        if(cellModel.isFromDetail){
            [self trackCardShow:cellModel rank:0];
        }
        FHFeedUGCContentAttachCardInfoExtraModel *extra = self.cellModel.attachCardInfo.extra;
        self.realtorPhoneCallModel = [[FHRealtorEvaluatingPhoneCallModel alloc]initWithHouseType:[NSString stringWithFormat:@"%@",extra.houseType].intValue houseId:extra.fromGid];
         self.realtorPhoneCallModel.tracerDict = self.cellModel.tracerDic;
        self.realtorModel = [[FHFeedUGCCellRealtorModel alloc]init];
        self.realtorModel.associateInfo = [[FHClueAssociateInfoModel alloc]initWithString:extra.associateInfo error:nil];
        self.realtorModel.realtorId = extra.realtorId;
    }
}

- (void)trackCardShow:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    if(cellModel.attachCardInfo.extra && cellModel.attachCardInfo.extra.event.length > 0){
        //是房源卡片
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
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
        dict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
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
//    label.backgroundColor = [UIColor themeGray7];
//    label.layer.masksToBounds = YES;
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
    traceParam[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
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
    traceParam[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
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
    FHFeedUGCContentAttachCardInfoExtraModel *extra = self.cellModel.attachCardInfo.extra;
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"realtor_position"] = @"realtor_evaluate";
    imExtra[@"from_gid"] = extra.fromGid;
    self.realtorModel.chatOpenurl = openUrl.absoluteString;
    [self.realtorPhoneCallModel imchatActionWithPhone:self.realtorModel realtorRank:@"0" extraDic:self.cellModel.tracerDic];
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
    TRACK_EVENT(@"click_im", dict);
}

- (NSString *)elementFrom {
    return @"feed_card";
}

@end

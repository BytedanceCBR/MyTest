//
//  FHHouseDetailContactViewModel.h
//  Pods
//
//  Created by 张静 on 2019/2/13.
//

#import <Foundation/Foundation.h>
#import "FHDetailNavBar.h"
#import "FHHouseType.h"
#import "FHDetailBottomBar.h"
#import <FHHouseBase/FHHouseContactDefines.h>
#import <FHHouseBase/FHFillFormAgencyListItemModel.h>

NS_ASSUME_NONNULL_BEGIN

@class FHHouseDetailFollowUpViewModel;
@class FHDetailImShareInfoModel;
@class FHHouseContactConfigModel;
@class FHHouseNewsSocialModel,FHAssociatePhoneModel;

typedef enum : NSUInteger {
    FHUGCCommunityLoginTypeMemberTalk = 1, // 群聊按钮
    FHUGCCommunityLoginTypeTip = 2,// 群聊引导弹窗
} FHUGCCommunityLoginType;

@interface FHHouseDetailContactViewModel : NSObject
typedef  void(^fillFormSubmit)();
@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@property (nonatomic, strong) FHDetailShareInfoModel *shareInfo;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, assign) NSInteger followStatus;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据
@property (nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, assign)   BOOL       showenOnline;// 是否显示在线联系，默认不显示
@property (nonatomic, copy)     NSString       *onLineName;// 在线联系 名称
@property (nonatomic, copy)     NSString       *phoneCallName;// 电话咨询 或者 询底价 名称
//@property (nonatomic, copy, nullable) NSString *customHouseId;// floor_plan_detail:floor_plan_id
//@property (nonatomic, copy, nullable) NSString *fromStr;//floor_plan_detail:app_floor_plan
//@property (nonatomic, assign) NSInteger targetType;//新房子页面电话线索新增类型
@property (nonatomic, strong) FHDetailImShareInfoModel* imShareInfo;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel *> *chooseAgencyList;
@property (nonatomic, copy , nullable) NSString *subTitle;
@property (nonatomic, copy , nullable) NSString *toast;//表单提交成功的提示语
@property (nonatomic, strong)   FHHouseNewsSocialModel       *socialInfo;// 新房圈子信息
@property (nonatomic, strong)   FHAssociatePhoneModel    *socialContactConfig;// 圈子拨打电话存储数据
@property (nonatomic, assign)   BOOL  needRefetchSocialGroupData;// 进入下个页面返回 是否需要重新拉取圈子数据
@property (nonatomic, assign)   FHUGCCommunityLoginType       ugcLoginType; // 1：community_member_talk(底部群聊入口), 2：community_tip(群聊引导弹窗)
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *highlightedRealtorAssociateInfo;
@property (nonatomic, copy) fillFormSubmit fillFormSubmitBlock;


- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBar *)bottomBar;
- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBar *)bottomBar houseType:(FHHouseType)houseType houseId:(NSString *)houseId;
// 在线联系点击
- (void)onlineActionWithExtraDict:(NSDictionary *)extraDict;
// 拨打电话 + 询底价填表单
- (void)contactActionWithExtraDict:(NSDictionary *)extraDict;
- (void)contactAction;

// 基本埋点数据
- (NSDictionary *)baseParams;

//- (void)fillFormActionWithActionType:(FHFollowActionType)actionType;
//- (void)fillFormActionWithExtraDict:(NSDictionary *)extraDict;

#pragma mark - associate refactor
- (void)fillFormActionWithParams:(NSDictionary *)formParamsDict;

// 关注
- (void)followActionWithExtra:(NSDictionary *)extra;
// 取消关注
- (void)cancelFollowAction;

// 携带埋点参数的分享
- (void)shareActionWithShareExtra:(NSDictionary *)extra;

//为IM提供房源卡片
- (void)generateImParams:(NSString *)houseId houseTitle:(NSString *)houseTitle houseCover:(NSString *)houseCover houseType:(NSString *)houseType houseDes:(NSString *)houseDes housePrice:(NSString *)housePrice houseAvgPrice:(NSString *)houseAvgPrice;
- (void)refreshMessageDot;
- (void)hideFollowBtn;

- (void)destroyRNPreLoadCache;

- (void)updateLoadFinish;

- (void)checkSocialPhoneCall;

- (void)groupChatAction;

// 回调方法
- (void)vc_viewDidAppear:(BOOL)animated;

- (void)vc_viewDidDisappear:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

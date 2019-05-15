//
//  TTContactsRedPacketManager.h
//  Article
//  通讯录红包管理，负责 UIViewController 弹出，网络请求
//
//  Created by Jiyee Sheng on 8/1/17.
//
//

@class TTRedPacketDetailBaseViewModel;
typedef NS_ENUM(NSInteger, TTContactsRedPacketViewControllerType) {
    TTContactsRedPacketViewControllerTypeContactsRedpacket,  //通讯录红包
    TTContactsRedPacketViewControllerTypeRecommendRedpacket, //猛烈推人红包，已登录状态
    TTContactsRedPacketViewControllerTypeRecommendRedpacketNoLogin, //猛烈推人红包，未登录状态
};

extern NSString *const kNotificationFollowAndGainMoneySuccessNotification;

@interface TTContactsRedPacketManager : NSObject

+ (instancetype)sharedManager;

- (void)presentInViewController:(UIViewController *)fromViewController contactUsers:(NSArray *)contactUsers;

/**
 展现

 @param fromViewController 起点viewController
 @param contactUsers 需要关注的人
 @param type 普通或猛烈推人
 @param viewModel 红包数据，用于登录用户外部关注完成之后直接弹出红包
 @param extraParams 额外参数
 @param needPush 是否需要present/push
 */
- (void)presentInViewController:(UIViewController *)fromViewController
                   contactUsers:(NSArray *)contactUsers
                           type:(TTContactsRedPacketViewControllerType)type
                      viewModel:(TTRedPacketDetailBaseViewModel *)viewModel
                    extraParams:(NSDictionary *)extraParams
                       needPush:(BOOL)needPush;

@end

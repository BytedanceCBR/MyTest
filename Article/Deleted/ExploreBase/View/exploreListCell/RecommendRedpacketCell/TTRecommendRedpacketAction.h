//
//  TTRecommendRedpacketAction.h
//  Article
//
//  Created by lipeilun on 2017/10/26.
//

#import <Foundation/Foundation.h>
@class ExploreOrderedData;
@class RecommendRedpacketData;
@class TTRecommendUserModel;
@class SSViewControllerBase;
@class TTRedPacketDetailBaseViewModel;

@interface TTRecommendRedpacketAction : NSObject
@property (nonatomic, strong) ExploreOrderedData *orderedData;

- (void)dislikeAction:(UIView *)senderView;

/**
 * 弹出更多好友选择页面
 * @param title 标题
 * @param buttonFormat 关注按钮样式
 * @param data 推人红包数据
 * @param completionBlock 关闭后的回调，用于刷新cell的文案
 */
- (void)presentRecommendUsersViewControllerWithTitle:(NSString *)title
                                        buttonFormat:(NSString *)buttonFormat
                              recommendRedpacketData:(RecommendRedpacketData *)data
                                     completionBlock:(void (^)(NSSet *userSet))completionBlock;

/**
 * 直接关注用户选择的推人列表
 * @param selectedUsers 用户最终确认勾选的推人列表
 * @param extraParams 统计参数
 * @param fromViewController 来源页面
 * @param completionBlock 关注成功或失败之后的回调
 */
- (void)multiFollowSelectedUsers:(NSArray<TTRecommendUserModel *> *)selectedUsers
                     extraParams:(NSDictionary *)extraParams
              fromViewController:(SSViewControllerBase *)fromViewController
                 completionBlock:(void (^)(BOOL completed, TTRedPacketDetailBaseViewModel *viewModel, NSArray <TTRecommendUserModel *> *contactUsers))completionBlock;

@end

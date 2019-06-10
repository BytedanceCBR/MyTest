//
//  TTRecommendRedpacketAction.m
//  Article
//
//  Created by lipeilun on 2017/10/26.
//

#import "TTRecommendRedpacketAction.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTFeedDislikeView.h"
#import "RecommendRedpacketData.h"
#import "ExploreMixListDefine.h"
#import "TTContactsRedPacketManager.h"
#import "TTNavigationController.h"
#import <TTAccountManager.h>
#import "TTRecommendRedpacketUserViewController.h"
#import "TTContactsRecommendUserTableViewCell.h"
#import "TTFollowManager.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSViewControllerBase.h"
#import "TTContactsRedPacketView.h"
#import "TTFollowNotifyServer.h"
#import "TTRedPacketDetailBaseView.h"


@implementation TTRecommendRedpacketAction

- (void)dislikeAction:(UIView *)senderView {
    if (!self.orderedData) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:@"list_follow_card_with_redpacket" forKey:@"source"];
    [TTTrackerWrapper eventV3:@"rt_dislike" params:dict];
    
    [TTFeedDislikeView dismissIfVisible];
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = nil;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.recommendRedpacketData.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = senderView.center;
    [dislikeView showAtPoint:point
                    fromView:senderView
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)presentRecommendUsersViewControllerWithTitle:(NSString *)title
                                        buttonFormat:(NSString *)buttonFormat
                              recommendRedpacketData:(RecommendRedpacketData *)data
                                     completionBlock:(void (^)(NSSet *userSet))completionBlock {
    TTRecommendRedpacketUserViewController *addFriendsViewController = [[TTRecommendRedpacketUserViewController alloc] initWithRelatedUsers:[self transformUserCardsToUserModel:data.userDataList] title:title buttonFormat:buttonFormat];
    addFriendsViewController.action = self;
    addFriendsViewController.recommendRedpacketData = data;
    addFriendsViewController.dismissBlock = completionBlock;
    addFriendsViewController.categoryName = self.orderedData.categoryID;
    addFriendsViewController.recommendType = data.userDataList.count > 0 ? [[data.userDataList[0] recommend_type] stringValue] : @"0";

    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:addFriendsViewController];
    navigationController.ttNavBarStyle = @"White";
    navigationController.ttHideNavigationBar = NO;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [[TTUIResponderHelper topmostViewController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)multiFollowSelectedUsers:(NSArray<TTRecommendUserModel *> *)selectedUsers
                     extraParams:(NSDictionary *)extraParams
              fromViewController:(SSViewControllerBase *)fromViewController
                 completionBlock:(void (^)(BOOL completed, TTRedPacketDetailBaseViewModel *viewModel, NSArray <TTRecommendUserModel *> *contactUsers))completionBlock {
    NSMutableArray *userIdsArray = [NSMutableArray array];
    for (TTRecommendUserModel *model in selectedUsers) {
        if (!isEmptyString(model.user_id) && model.selected) {
            [userIdsArray addObject:model.user_id];
        }
    }

    if (userIdsArray.count == 0) {
        if (completionBlock) {
            completionBlock(NO, nil, nil);
        }

        return;
    }

    NSInteger rel_type = [extraParams tt_integerValueForKey:@"rel_type"];
    TTFollowNewSource server_source;
    if (rel_type == 2) {
        server_source = TTFollowNewSourceFeedRecommendStarsRedpacketCard;
    } else {
        server_source = TTFollowNewSourceFeedRecommendRedpacketCard;
    }

    TTContactsRedPacketParam *params = [TTContactsRedPacketParam paramWithDict:extraParams];

    FRUserRelationCredibleFriendsRequestModel *requestModel = [[FRUserRelationCredibleFriendsRequestModel alloc] init];
    requestModel.user_ids = [userIdsArray componentsJoinedByString:@","];
    requestModel.rel_type = @(rel_type);
    requestModel.redpack_id = params.redpacketId;
    requestModel.token = params.redpacketToken;

    [FRRequestManager requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (!error) {
            FRUserRelationCredibleFriendsResponseModel *model = (FRUserRelationCredibleFriendsResponseModel *) responseModel;

            if (model && [model.message isEqualToString:@"success"]) {
                TTRedPacketDetailBaseViewModel *viewModel = [[TTRedPacketDetailBaseViewModel alloc] init];
                viewModel.userName = params.redpacketIconText;
                viewModel.title = params.redpacketTitle;
                viewModel.avatar = params.redpacketIconUrl;
                viewModel.desc = model.data.redpack.sub_title;
                viewModel.money = [NSString stringWithFormat:@"%.2f", [model.data.redpack.amount floatValue] / 100];
                viewModel.withdrawUrl = model.data.redpack.schema;
                viewModel.listTitle = model.data.title;

                NSMutableArray *contactUsers = [NSMutableArray array];
                for (FRCommonUserStructModel *userModel in model.data.users) {
                    TTRecommendUserModel *newModel = [TTRecommendUserModel new];
                    newModel.user_id = userModel.info.user_id;
                    newModel.screen_name = userModel.info.name;
                    newModel.recommend_reason = userModel.info.desc;
                    newModel.mobile_name = userModel.info.desc;
                    newModel.avatar_url = userModel.info.avatar_url;
                    newModel.user_auth_info = userModel.info.user_auth_info;
                    newModel.selected = YES;
                    newModel.selectable = NO;
                    [contactUsers addObject:newModel];
                }

                NSString *to_user_list = [userIdsArray componentsJoinedByString:@","];

                // 关注成功之后发送 rt_follow 埋点
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:to_user_list forKey:@"to_user_id_list"];
                [dict setValue:@(userIdsArray.count) forKey:@"follow_num"];
                [dict setValue:@"from_recommend" forKey:@"follow_type"];
                [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
                [dict setValue:[extraParams tt_stringValueForKey:@"enter_from"] forKey:@"enter_from"];
                [dict setValue:[extraParams tt_stringValueForKey:@"recommend_type"] forKey:@"recommend_type"];
                [dict setValue:@"all_follow_card" forKey:@"source"];
                [dict setValue:@(server_source) forKey:@"server_source"];
                [dict setValue:self.orderedData.logPb forKey:@"log_pb"];
                [dict setValue:@([extraParams tt_integerValueForKey:@"head_image_num"]) forKey:@"head_image_num"];
                [dict setValue:@(0) forKey:@"is_redpacket"];
                [dict setValue:[extraParams tt_stringValueForKey:@"relation_type"] forKey:@"relation_type"];
                [TTTrackerWrapper eventV3:@"rt_follow" params:dict];

                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFollowAndGainMoneySuccessNotification object:nil userInfo:@{
                    @"show_label" : model.data.show_label ?: @"",
                    @"button_text" : model.data.button_text ?: @"",
                    @"button_schema" : model.data.button_schema ?: @"",
                }];

                [fromViewController dismissViewControllerAnimated:YES completion:^{
                    if (completionBlock) {
                        completionBlock(YES, viewModel, contactUsers);
                    }
                }];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络异常，请再试一次" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                });

                if (!isEmptyString([error.userInfo tt_stringValueForKey:@"description"])) {
                    [TTTrackerWrapper eventV3:@"red_button" params:@{
                        @"position" : @"list",
                        @"action_type" : @"fail_over",
                        @"source" : @"all_follow_card",
                        @"category_name" : self.orderedData.categoryID ?: @"",
                    }];
                }

                if (completionBlock) {
                    completionBlock(NO, nil, nil);
                }
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:!isEmptyString([error.userInfo tt_stringValueForKey:@"description"])?[error.userInfo tt_stringValueForKey:@"description"]:@"网络异常，请再试一次"
                                         indicatorImage:nil
                                            autoDismiss:YES
                                         dismissHandler:nil];

            });

            if (!isEmptyString([error.userInfo tt_stringValueForKey:@"description"])) {
                [TTTrackerWrapper eventV3:@"red_button" params:@{
                    @"position" : @"list",
                    @"action_type" : @"fail_over",
                    @"source" : @"all_follow_card",
                    @"category_name" : self.orderedData.categoryID ?: @"",
                }];
            }

            if (completionBlock) {
                completionBlock(NO, nil, nil);
            }
        }
    }];
}

- (NSArray <TTRecommendUserModel *> *)transformUserCardsToUserModel:(NSArray <FRRecommendUserLargeCardStructModel *> *)array {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:20];

    for (FRRecommendUserLargeCardStructModel *model in array) {
        TTRecommendUserModel *newModel = [TTRecommendUserModel new];
        newModel.user_id = model.user.info.user_id;
        newModel.screen_name = model.user.info.name;
        newModel.mobile_name = model.user.info.desc;
        newModel.avatar_url = model.user.info.avatar_url;
        newModel.user_auth_info = model.user.info.user_auth_info;
        newModel.user_decoration = model.user.info.user_decoration;
        newModel.recommend_reason = model.recommend_reason;
        newModel.selected = [model.selected boolValue];
        newModel.selectable = YES;
        [models addObject:newModel];
    }

    return models;
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    if (!self.orderedData) {
        return;
    }

    NSArray *filterWords = [view selectedWords];
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = filterWords;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

@end

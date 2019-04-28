//
//  TSVRecUserCardCollectionViewCellViewModel.m
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import "TSVRecUserCardCollectionViewCellViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TSVRecUserSinglePersonCollectionViewCellViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVRecUserCardOriginalData.h"
#import "AWEVideoUserInfoManager.h"
#import "HTSVideoPlayToast.h"
#import "AWEUserModel.h"
#import <TTRoute/TTRoute.h>
#import "AWEVideoPlayTransitionBridge.h"

@interface TSVRecUserCardCollectionViewCellViewModel()

@property (nonatomic, strong, readwrite) ExploreOrderedData *cellData;
@property (nonatomic, strong) TSVRecUserCardModel *cardModel;
@property (nonatomic, copy) NSArray<TSVRecUserSinglePersonCollectionViewCellViewModel *> *cellViewModelArray;
@property (nonatomic, copy, readwrite) NSString *listEntrance;
@property (nonatomic, copy, readwrite) NSString *categoryName;
@property (nonatomic, copy, readwrite) NSString *enterFrom;
@property (nonatomic, copy, readwrite) NSString *cardID;
@property (nonatomic, copy) NSString *logPbJSONString;

@end

@implementation TSVRecUserCardCollectionViewCellViewModel

- (instancetype)initWithOrderedData:(ExploreOrderedData *)data
{
    if (self = [super init]) {
        _cellData = data;
        _cardModel = data.tsvRecUserCardOriginalData.cardModel;
        [self bindModel];
    }
    return self;
}

- (void)bindModel
{
    RACChannelTo(self, title) = RACChannelTo(self, cardModel.title);
    RACChannelTo(self, cardID) = RACChannelTo(self, cardModel.cardID);
    [RACObserve(self, cardModel.logPb) subscribeNext:^(NSDictionary *logPb) {
        NSString *logPbJSONString = nil;
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logPb options:0 error:&parseError];
        if (jsonData && parseError == nil) {
            logPbJSONString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        NSAssert(logPbJSONString, @"log_pb should not be nil");
        self.logPbJSONString = logPbJSONString;
    }];
    RACChannelTo(self, listEntrance) = RACChannelTo(self, cardModel.listEntrance);
    RACChannelTo(self, categoryName) = RACChannelTo(self, cardModel.categoryName);
    RACChannelTo(self, enterFrom) = RACChannelTo(self, cardModel.enterFrom);
    
    @weakify(self);
    [RACObserve(self, cardModel) subscribeNext:^(TSVRecUserCardModel *cardModel) {
        @strongify(self);
        NSMutableArray *cellViewModelArray = [NSMutableArray arrayWithCapacity:cardModel.userList.count];
        for (TSVRecUserSinglePersonModel *model in cardModel.userList) {
            [cellViewModelArray addObject:[[TSVRecUserSinglePersonCollectionViewCellViewModel alloc] initWithModel:model]];
        }
        self.cellViewModelArray = [cellViewModelArray copy];
    }];
}

- (NSInteger)numberOfSinglePersonCollectionViewCellViewModel
{
    return [self.cellViewModelArray count];
}

- (TSVRecUserSinglePersonCollectionViewCellViewModel *)singlePersonCollectionViewCellViewModelAtIndex:(NSInteger)index
{
    TSVRecUserSinglePersonCollectionViewCellViewModel *viewModel = [self.cellViewModelArray objectAtIndex:index];
    return viewModel;
}

- (void)didSelectSinglePersonCollectionViewCellAtIndex:(NSInteger)index
{
    TSVRecUserSinglePersonCollectionViewCellViewModel *viewModel = [self.cellViewModelArray objectAtIndex:index];
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    [paramsDict setValue:self.categoryName forKey:@"category_name"];
    [paramsDict setValue:@"list_follow_card_horizon_shortvideo" forKey:@"from_page"];
    NSDictionary *enterHomepageV3ExtraParams = [self trackParamsWithExtraParams:@{
                                                                                  @"to_user_id": viewModel.userID ?: @"",
                                                                                  @"from_page": @"list_follow_card_horizon_shortvideo",
                                                                                  @"order": [@(index + 1) stringValue]
                                                                                  }];
    NSDictionary *userInfo = @{@"enter_homepage_v3_extra_params": enterHomepageV3ExtraParams};
    [AWEVideoPlayTransitionBridge openProfileViewWithUserId:viewModel.userID params:paramsDict userInfo:userInfo pushWithTransitioningAnimationEnable:NO];
}

- (void)willDisplaySinglePersonCollectionViewCellAtIndex:(NSInteger)index
{
    [self trackWithEvent:@"follow_card" extraParams:@{
                                                      @"action_type": @"show",
                                                      @"is_direct": @1,
                                                      @"source": @"list",
                                                      @"show_num": @([self.cellViewModelArray count]),
                                                      }];
}

- (void)handleSinglePersonCollectionViewCellFollowBtnTapAtIndex:(NSInteger)index
{
    TSVRecUserSinglePersonCollectionViewCellViewModel *viewModel = [self.cellViewModelArray objectAtIndex:index];
    NSString *userID = viewModel.userID?: @"";
    @weakify(self);
    if (viewModel.isFollowing) {
        [self trackWithEvent:@"rt_unfollow" extraParams:@{
                                                          @"to_user_id": userID,
                                                          @"follow_type": @"from_recommend",
                                                          @"order": [@(index + 1) stringValue],
                                                          @"source": @"list_follow_card_horizon",
                                                          @"server_source": [@91 stringValue],
                                                          @"position": @"list",
                                                          @"log_pb": self.logPbJSONString ?: @"",
                                                          }];
        [AWEVideoUserInfoManager unfollowUser:userID completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && !error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userID,
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @12
                                                                             }
                 ];
            }
        }];
    } else {
        [self trackWithEvent:@"rt_follow" extraParams:@{
                                                        @"to_user_id": userID,
                                                        @"follow_type": @"from_recommend",
                                                        @"order": [@(index + 1) stringValue],
                                                        @"source": @"list_follow_card_horizon",
                                                        @"server_source": [@91 stringValue],
                                                        @"position": @"list",
                                                        @"log_pb": self.logPbJSONString ?: @"",
                                                        }];
        [AWEVideoUserInfoManager followUser:userID completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && !error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userID,
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @11
                                                                             }
                 ];
            }
        }];
    }
    viewModel.isFollowing = !viewModel.isFollowing;
    [self.cardModel save];
}

- (void)handleCardCollectionViewCellDislike
{
    [self trackWithEvent:@"follow_card" extraParams:@{
                                                      @"action_type": @"delete",
                                                      }];
}

- (void)trackWithEvent:(NSString *)event extraParams:(NSDictionary *)extraParams
{
    [TTTracker eventV3:event params:[self trackParamsWithExtraParams:extraParams]];
}

- (NSDictionary *)trackParamsWithExtraParams:(NSDictionary *)extraParams
{
#if !DEBUG
    @try {
#endif
        NSMutableDictionary *parameterDictionary = [@{
                                                      @"card_id": self.cardID,
                                                      @"category_name": self.categoryName,
                                                      @"enter_from": self.enterFrom,
                                                      @"demand_id": @100353,
                                                      } mutableCopy];
        if (self.listEntrance) {
            //可能为nil
            parameterDictionary[@"list_entrance"] = self.listEntrance;
        }
        [parameterDictionary addEntriesFromDictionary:extraParams];
        return [parameterDictionary copy];
#if !DEBUG
    } @catch (NSException *exception) {
        ;
    } @finally {
        ;
    }
#endif
}

@end

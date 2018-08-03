//
//  TSVRecommendCardViewModel.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import "TSVRecommendCardViewModel.h"
#import "ReactiveObjC.h"
#import "TSVUserRecommendationModel.h"
#import "TTNetworkManager.h"
#import "CommonURLSetting.h"
#import "TSVRecommendCardCollectionViewCell.h"
#import "TSVRecommendCardModel.h"
#import "TTDeviceUIUtils.h"
#import "TSVUserRecommendationViewModel.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "UIViewAdditions.h"
#import "TTTrackerWrapper.h"
#import "TTSettingsManager.h"
#import "TTBaseMacro.h"

@interface TSVRecommendCardViewModel()

@property (nonatomic, strong) TSVRecommendCardModel *model;
@property (nonatomic, copy) NSArray *userCards;
@property (nonatomic, assign) BOOL isRecommendCardFinishFetching;
@property (nonatomic, assign) BOOL isRecommendCardShowing;
@property (nonatomic, assign) BOOL scrollAfterFollowed;
@property (nonatomic, assign) BOOL resetContentOffset;

@end

@implementation TSVRecommendCardViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self bindModel];
    }
    return self;
}

- (void)bindModel
{
    @weakify(self);
    [RACObserve(self, model) subscribeNext:^(TSVRecommendCardModel *model) {
        @strongify(self);
        
        NSMutableArray *userArray = [NSMutableArray arrayWithCapacity:model.userCards.count];
        for (TSVUserRecommendationModel *user in model.userCards) {
            TSVUserRecommendationViewModel *viewModel = [[TSVUserRecommendationViewModel alloc] initWithModel:user];
            viewModel.commonParameter = self.commonParameter;
            viewModel.detailPageUserID = self.detailPageUserID;
            viewModel.listEntrance = self.listEntrance;
            viewModel.logPb = self.logPb;
            [userArray addObject:viewModel];
        }
        self.userCards = [userArray copy];
    }];
}

- (void)didSelectItemAtIndex:(NSUInteger)index;
{
    if (index < self.model.userCards.count) {
        TSVUserRecommendationModel *cellModel = [self.model.userCards objectAtIndex:index];
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"detail_follow_card_horizon_shortvideo" forKey:@"from_page"];
        [params setValue:cellModel.user.userID forKey:@"to_user_id"];
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithDictionary:self.commonParameter];
        [extra setValue:@(index + 1) forKey:@"order"];
        [extra setValue:self.listEntrance forKey:@"list_entrance"];
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        [userInfo setValue:extra forKey:@"enter_homepage_v3_extra_params"];
        
        [AWEVideoPlayTransitionBridge openProfileViewWithUserId:cellModel.user.userID params:params userInfo:userInfo];
    }
}

- (TSVUserRecommendationViewModel *)viewModelAtIndex:(NSUInteger)index
{
    if (index < self.userCards.count) {
        TSVUserRecommendationViewModel *viewModel = [self.userCards objectAtIndex:index];
        viewModel.index = index;
        viewModel.followButtonClick = ^(NSError *error) {
            self.scrollAfterFollowed = YES;
        };
        return viewModel;
    }
    return nil;
}

- (void)resetContentOffsetIfNeed
{
    self.resetContentOffset = YES;
}

#pragma mark - Recommend Card

- (void)fetchRecommendArrayWithUserID:(NSString *)userID
{
    BOOL showRecommendCard = [[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_recommend_card"
                                                                  defaultValue:@YES
                                                                        freeze:YES] boolValue];
    if (showRecommendCard) {
        NSString *urlString = [self getAPIPrefix];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:userID forKey:@"follow_user_id"];
        [params setValue:@"follow" forKey:@"scene"];
        [params setValue:@"ugc_video" forKey:@"source"];
        @weakify(self);
        [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString
                                                         params:params
                                                         method:@"GET"
                                               needCommonParams:YES
                                                       callback:^(NSError *error, id jsonObj) {
                                                           @strongify(self);
                                                           if (!error) {
                                                               NSError *error = nil;
                                                               self.model = [[TSVRecommendCardModel alloc] initWithDictionary:jsonObj error:&error];
                                                               self.isRecommendCardFinishFetching = YES;
                                                           }
                                                       }];
    }
}

- (NSString *)getAPIPrefix
{
    return [NSString stringWithFormat:@"%@/user/relation/user_recommend/v1/supplement_recommends/", [CommonURLSetting baseURL]];
}

#pragma mark - SSImpression

- (void)viewWillAppear
{
    self.isRecommendCardShowing = YES;
    [[SSImpressionManager shareInstance] enterRecommendUserListWithCategoryName:self.commonParameter[@"category_name"] cellId:self.detailPageUserID];
}

- (void)viewWillDisappear
{
    self.isRecommendCardShowing = NO;
    [[SSImpressionManager shareInstance] leaveRecommendUserListWithCategoryName:self.commonParameter[@"category_name"]  cellId:self.detailPageUserID];
}

- (void)processImpressionAtIndex:(NSIndexPath *)indexPath status:(SSImpressionStatus)status
{
    if (indexPath.item < self.userCards.count) {
        TSVUserRecommendationViewModel *cellViewModel = [self.userCards objectAtIndex:indexPath.item];
        NSString *statsPlaceHolder = cellViewModel.model.statsPlaceHolder;
        NSMutableDictionary *params = @{}.mutableCopy;
        
        if (!isEmptyString(statsPlaceHolder)) {
            [params setValue:[NSString stringWithFormat:@"user_recommend_impression_event:%@", statsPlaceHolder]
                      forKey:@"user_recommend_impression_event"];
        }
        [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:cellViewModel.model.user.userID
                                                                        categoryName:self.commonParameter[@"category_name"]
                                                                              cellId:self.detailPageUserID
                                                                              status:status
                                                                               extra:params.copy];
    }
}

@end

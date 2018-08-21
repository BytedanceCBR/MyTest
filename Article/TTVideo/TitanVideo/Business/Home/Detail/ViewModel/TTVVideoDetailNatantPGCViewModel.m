//
//  TTVVideoDetailNatantPGCViewModel.m
//  Article
//
//  Created by lishuangyang on 2017/5/24.
//
//
#import "TTVVideoDetailNatantPGCViewModel.h"
#import "TTNetworkManager.h"
#import "TTRecommendModel.h"
#import "TTVDetailRelatedRecommendCellViewModel.h"
@implementation TTVVideoDetailNatantPGCViewModel

- (instancetype)initWithPGCModel:(id<TTVVideoDetailNatantPGCModelProtocol>) GPCInfo
{
    self = [super init];
    if (self) {
        self.pgcModel = GPCInfo;
    }
    return self;
}

- (void)didSelectSubscribeButton: (FriendActionType) actionType andFinishBlock:(void (^ __nullable)(FriendActionType type, NSError *__nullable error, NSDictionary * __nullable result))comleteBLC
{
    [[TTFollowManager sharedManager] startFollowAction:actionType userID:self.pgcModel.mediaUserID  platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(TTFollowNewSourceVideoDetail) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        comleteBLC(type,error,result);
    }];
}

- (void)fetchRecommendArray:(void (^ __nullable)(NSError * error))comleteBLC
{
    NSString *urlString = [self p_getAPIPrefix];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[self.pgcModel.contentInfo ttgc_contentID] forKey:@"follow_user_id"];
    [params setValue:@"follow" forKey:@"scene"];
    [params setValue:@"video_page" forKey:@"source"];
    [params setValue:self.pgcModel.groupIDStr forKey:@"group_id"];
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (!error) {
            NSError *error = nil;
            self.recommendResponse = [[TTVDetailPGCUserRecommendResponseModel alloc] initWithDictionary:jsonObj error:&error];
            NSMutableArray *userCards = [TTVDetailFollowUserRecommendInfoModel arrayOfModelsFromDictionaries:[jsonObj tt_arrayValueForKey:@"user_cards"]];
            for (int i = 0; i < userCards.count; i++) {
                TTVDetailFollowUserRecommendInfoModel *model = [userCards objectAtIndex:i];
                if (!isEmptyString(model.user.info.avatar_url) && !isEmptyString(model.user.info.name) &&
                    !isEmptyString(model.recommend_reason) && !isEmptyString(model.user.info.user_id)) {
                    TTVDetailRelatedRecommendCellViewModel *cellViewModel = [[TTVDetailRelatedRecommendCellViewModel alloc] init];
                    cellViewModel.infoModel = model;
                    if (!_recommendArray) {
                        _recommendArray = [NSMutableArray array];
                    }
                    [self.recommendArray addObject:cellViewModel];
                }
            }
        }
        comleteBLC(error);
    }];
}

- (BOOL)isVideoSourceUGCVideo
{
    if (!isEmptyString(self.pgcModel.videoSource)) {
        if ([self.pgcModel.videoSource isEqualToString:@"ugc_video"]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)p_getAPIPrefix
{
    return [NSString stringWithFormat:@"%@/user/relation/user_recommend/v1/supplement_recommends/", [CommonURLSetting baseURL]];
}

@end

@implementation TTVDetailPGCUserRecommendResponseModel

@end


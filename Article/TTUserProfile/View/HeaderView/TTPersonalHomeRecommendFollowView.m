//
//  TTPersonalHomeRecommendFollowView.m
//  Article
//
//  Created by wangdi on 2017/3/18.
//
//

#import "TTPersonalHomeRecommendFollowView.h"
#import "NSStringAdditions.h"
#import "TTPersonalHomeManager.h"
#import "TTIndicatorView.h"
#import "FRRouteHelper.h"
#import "TTRoute.h"

#define kRecommendCell @"recommendCell"

@interface TTPersonalHomeRecommendFollowView()<TTRecommendUserCollectionViewDelegate>
@property (nonatomic, weak) SSThemedLabel *recommendLabel;
@end

@implementation TTPersonalHomeRecommendFollowView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground3;
        self.clipsToBounds = YES;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    SSThemedLabel *recommendLabel = [[SSThemedLabel alloc] init];
    recommendLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
    recommendLabel.textColorThemeKey = kColorText1;
    recommendLabel.text = @"相关推荐";
    recommendLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    recommendLabel.top = [TTDeviceUIUtils tt_newPadding:8];
    recommendLabel.width = self.width - [TTDeviceUIUtils tt_newPadding:30];
    recommendLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    recommendLabel.height = [recommendLabel.text sizeWithFontCompatible:recommendLabel.font].height;
    [self addSubview:recommendLabel];
    self.recommendLabel = recommendLabel;
    
    self.collectionView = [TTRecommendUserCollectionView collectionView];
    self.collectionView.disableDislike = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.recommendUserDelegate = self;
    self.collectionView.followSource = TTFollowNewSourceProfileFeed;
    self.collectionView.frame = CGRectMake(0, recommendLabel.bottom + [TTDeviceUIUtils tt_newPadding:8], self.width, [TTDeviceUIUtils tt_newPadding:182]);
    [self addSubview:self.collectionView];
}

- (void)prepare {
    self.height = self.collectionView.bottom + [TTDeviceUIUtils tt_newPadding:10] + 5;
    [self.collectionView reloadData];
}

#pragma mark - TTRecommendUserCollectionViewDelegate

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(event)) {
        return;
    }
    
    if (self.rtFollowExtraDict) {
        if ([event isEqualToString:@"follow"] || [event isEqualToString:@"unfollow"]) { // "rt_follow" 关注动作统一化 埋点
            NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithDictionary:self.rtFollowExtraDict];
            [rtFollowDict setValue:[extraDic objectForKey:@"order"] forKey:@"order"];
            [rtFollowDict setValue:[extraDic objectForKey:@"user_id"] forKey:@"to_user_id"];
            [rtFollowDict setValue:[extraDic objectForKey:@"server_source"] forKey:@"server_source"];
            [rtFollowDict setValue:[extraDic objectForKey:@"server_extra"] forKey:@"server_extra"];
            if ([event isEqualToString:@"follow"]) {
                [rtFollowDict setValue:[extraDic objectForKey:@"user_recommend_follow_event"] forKey:@"user_recommend_follow_event"];
                [TTTrackerWrapper eventV3:@"rt_follow" params:rtFollowDict];
                return;
            } else {
                [rtFollowDict setValue:[extraDic objectForKey:@"user_recommend_unfollow_event"] forKey:@"user_recommend_unfollow_event"];
                [TTTrackerWrapper eventV3:@"rt_unfollow" params:rtFollowDict];
                return;
            }
        }
    }
    
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObject:@"profile" forKey:@"category_name"];
    [dic setValue:self.userID forKey:@"profile_user_id"];
    if (extraDic) {
        [dic addEntriesFromDictionary:extraDic];
    }
    [dic setValue:@"detail_follow_card" forKey:@"source"];
    [TTTrackerWrapper eventV3:event params:dic];
}

- (NSDictionary *)impressionParams {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:@"profile" forKey:@"category_name"];
    [dict setValue:self.userID forKey:@"profile_user_id"];
    return dict;
}
@end

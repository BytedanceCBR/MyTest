//
//  TTVDetailFollowRecommendView.m
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import "TTVDetailFollowRecommendView.h"
#import "NSStringAdditions.h"

@interface TTVDetailFollowRecommendView() <TTVDetailFollowRecommendCollectionViewDelegate>
@property (nonatomic, weak) SSThemedLabel *recommendLabel;
@end

@implementation TTVDetailFollowRecommendView

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
    recommendLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [recommendLabel sizeToFit];
    recommendLabel.height = [recommendLabel.text sizeWithFontCompatible:recommendLabel.font].height;
    [self addSubview:recommendLabel];
    self.recommendLabel = recommendLabel;
    
    self.collectionView = [TTVDetailFollowRecommendCollectionView collectionView];
    self.collectionView.disableDislike = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.recommendUserDelegate = self;
    self.collectionView.followSource = TTFollowNewSourceVideoDetailRecommend;
    self.collectionView.frame = CGRectMake(0, recommendLabel.bottom + [TTDeviceUIUtils tt_newPadding:8], self.width,[TTDeviceUIUtils tt_newPadding:182]);
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.collectionView];
}

- (void)setIsSpread:(BOOL)isSpread{
    
    if (_isSpread!= isSpread){
        _isSpread = isSpread;
        if (_ifNeedToSendShowAction) {
            [self logRecommendViewAction];
        }
    }
}

- (void)setRtFollowExtraDict:(NSDictionary *)rtFollowExtraDict{
    _rtFollowExtraDict = rtFollowExtraDict;
    self.collectionView.followSource = [rtFollowExtraDict tt_unsignedIntegerValueForKey:@"server_source"];
}


#pragma mark - TTRecommendUserCollectionViewDelegate

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(event)) {
        return;
    }
    
    if (self.rtFollowExtraDict) {
        if ([event isEqualToString:@"rt_follow"] || [event isEqualToString:@"rt_unfollow"]) { // "rt_follow" 关注动作统一化 埋点
            NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithDictionary:self.rtFollowExtraDict];
            [rtFollowDict setValue:[extraDic objectForKey:@"order"] forKey:@"order"];
            [rtFollowDict setValue:[extraDic objectForKey:@"user_id"] forKey:@"to_user_id"];
            [rtFollowDict setValue:[extraDic objectForKey:@"server_source"] forKey:@"server_source"];
            [rtFollowDict setValue:self.userID forKey:@"profile_user_id"];
            [TTTrackerWrapper eventV3:event params:rtFollowDict];
            return ;
        }
    }
    
}

- (NSDictionary *)impressionParams {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:self.rtFollowExtraDict[@"category_name"] forKey:@"category_name"];
    [dict setValue:self.userID forKey:@"profile_user_id"];
    return dict;
}

- (NSString *)recommendViewPositon{
    return self.position ? self.position : nil;
}

- (void)recordCollectionViewContentOffset:(CGPoint )point{
    if (self.recordContentOffsetblc) {
        self.recordContentOffsetblc(point);
    }
}

- (void)logRecommendViewAction{
    NSMutableDictionary *followCardDIc = [NSMutableDictionary dictionary];
    if (!self.actionType) {
        self.actionType = @"show";
    }
    [followCardDIc setValue: _isSpread ? self.actionType : @"close" forKey:@"action_type"];
    [followCardDIc setValue:self.rtFollowExtraDict[@"category_name"] forKey:@"category_name"];
    [followCardDIc setValue:@(0) forKey:@"is_direct"];
    [followCardDIc setValue:self.position forKey:@"source"];
    long long allmodelNum = [self.collectionView allUserModels].count;
    [followCardDIc setValue:@(allmodelNum) forKey:@"show_num"];
    [TTTrackerWrapper eventV3:@"follow_card" params:followCardDIc];
}

@end

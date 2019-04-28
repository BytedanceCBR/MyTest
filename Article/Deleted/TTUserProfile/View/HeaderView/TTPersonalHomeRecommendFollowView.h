//
//  TTPersonalHomeRecommendFollowView.h
//  Article
//
//  Created by wangdi on 2017/3/18.
//
//
#import "SSThemed.h"
#import "TTRecommendUserCollectionView.h"

@interface TTPersonalHomeRecommendFollowView : SSThemedView

@property (nonatomic, weak) TTRecommendUserCollectionView *collectionView;
@property (nonatomic, assign) BOOL isSpread;
@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSDictionary *rtFollowExtraDict; //统一关注动作埋点传入

- (void) prepare;
@end

//
//  TTRecommendRedpacketCellView.h
//  Article
//
//  Created by lipeilun on 2017/11/2.
//

#import "ExploreCellViewBase.h"


@class RecommendRedpacketData;
@class TTRecommendRedpacketAction;
@class TTColorAsFollowButton;
@class TTAlphaThemedButton;


@interface TTRecommendRedpacketCellView : ExploreCellViewBase

@property (nonatomic, strong) SSThemedView *avatarContainerView;
@property (nonatomic, strong) SSThemedImageView *redpacketImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedButton *moreButton;
@property (nonatomic, strong) SSThemedButton *followButton;
@property (nonatomic, strong) TTAlphaThemedButton *dislikeButton;
@property (nonatomic, strong) SSThemedView *bottomLineView;

@property (nonatomic, strong) SSThemedLabel *showMoreLabel; // 操作完成之后展现的 UI
@property (nonatomic, strong) TTColorAsFollowButton *showMoreButton;

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) RecommendRedpacketData *recommendRedpacketData;
@property (nonatomic, strong) TTRecommendRedpacketAction *action;

@end

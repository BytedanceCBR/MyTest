//
//  ExploreVideoDetailMixedGroupPicADView.h
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreDetailBaseADView.h"
#import "ExploreDetailMixedGroupPicADView.h"

#define kGroupPicViewImagesCount    3
#define kVideoTopMargin      12.f
#define kBottomMargin   7.f
#define kActionBottomMargin 14.f    //创意通投bottomMargin
#define kVideoHoriMargin     0.f
#define kPicSpace       2.f
#define kPicTopSpace    6.f
#define kPicAspect      0.653
#define kADLabelMargin  6.f

#define kVideoAdLabelRitghtPadding 4

#define kVideoDislikeImageWidth 20

@interface ExploreVideoDetailMixedGroupPicADView : ExploreDetailBaseADView

@property(nonatomic, strong) SSThemedLabel *titleLabel;
@property(nonatomic, strong) ExploreDetailADGroupPicView *groupPicView;
@property(nonatomic, strong) SSThemedLabel *adLabel;
@property(nonatomic, strong) SSThemedLabel *sourceLabel;
@property(nonatomic, strong) SSThemedLabel *bottomContainerView;

- (void)layoutVideo:(ArticleDetailADModel *)adModel;

@end

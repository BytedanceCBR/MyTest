//
//  ExploreVideoDetailMixedLeftPicADView.h
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreDetailBaseADView.h"
#import "TTLabel.h"

#define kVideoLeftPadding 0
#define kVideoRightPadding 0

#define kVideoTopPadding  12
#define kVideoBottomPadding 12

#define kVideoRightImgLeftPadding 10

#define kVideoAdLabelRitghtPadding 4

#define kVideoDislikeImageWidth 20

@interface ExploreVideoDetailMixedLeftPicADView : ExploreDetailBaseADView

@property(nonatomic, strong) TTImageView   *imageView;
@property(nonatomic, strong) TTLabel *titleLabel;
@property(nonatomic, strong) SSThemedLabel *adLabel;
@property(nonatomic, strong) SSThemedLabel *sourceLabel;

- (void)layoutVideo:(ArticleDetailADModel *)adModel;

@end

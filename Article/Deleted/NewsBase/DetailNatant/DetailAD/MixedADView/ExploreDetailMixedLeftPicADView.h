//
//  ExploreDetailMixedLeftPicADView.h
//  Article
//
//  Created by huic on 16/4/29.
//
//

#import "ExploreDetailBaseADView.h"
#import "TTLabel.h"

#define kVideoLeftPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kVideoRightPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)

#define kVideoTopPadding  12
#define kVideoBottomPadding 12
#define kVideoRightImgLeftPadding 6
#define kVideoTitleBottomPadding 8

#define kVideoAdLabelRitghtPadding 4

#define kDislikeImageWidth 10
#define kDislikeImageTopPadding 21
#define kDilikeToTitleRightPadding 10
#define kDislikeToTitleTopPadding 4.5
#define kDislikeImageRightPadding 12

@interface ExploreDetailMixedLeftPicADView : ExploreDetailBaseADView

@property(nonatomic, strong) TTImageView   *imageView;
@property(nonatomic, strong) TTLabel *titleLabel;
@property(nonatomic, strong) SSThemedLabel *adLabel;
@property(nonatomic, strong) SSThemedLabel *sourceLabel;

- (void)layout;

@end

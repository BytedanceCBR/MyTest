//
//  ExploreVideoDetailUnUnifyLargePicADView.h
//  Article
//
//  Created by yin on 2017/2/22.
//
//

#import "ExploreDetailBaseADView.h"

#define kBottomHeight 28 //底部空白高度
#define kTitleHorizonPadding 9 //标题左右间距

#define kAppHorizonPadding 12
#define kAppHeight 44
#define kPaddingSourceToTitle 1 //app名称与标题间距(纵向)

#define kVideoLargeSouceTopPadding 8
#define kVideoLargeSouceBottomPadding 12

#define kDislikeImageWidth 18
#define kDislikeImageTopPadding 4
#define kDislikeImageRightPadding 4

@interface ExploreVideoDetailUnUnifyLargePicADView : ExploreDetailBaseADView

@property(nonatomic, strong) TTImageView   *imageView;
@property(nonatomic, strong) SSThemedLabel *titleLabel;
@property(nonatomic, strong) SSThemedLabel *adLabel;
@property(nonatomic, strong) SSThemedLabel *sourceLabel;
@property(nonatomic, strong) SSThemedView *bottomLine;


- (void)layout;

@end

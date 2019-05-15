//
//  TTArticlePicView.h
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import "SSThemed.h"
#import "TTImageView.h"

@class ExploreOrderedData;

typedef NS_ENUM(NSInteger, TTArticlePicViewStyle) {
    /// 无样式
    TTArticlePicViewStyleNone = 0,
    /// 右小图样式
    TTArticlePicViewStyleRight = 1,
    /// 大图样式
    TTArticlePicViewStyleLarge = 2,
    /// 三图样式
    TTArticlePicViewStyleTriple = 3,
    /// 左大图，右两小图样式，顺序(大图-右上-右下)
    TTArticlePicViewStyleLeftLarge = 4,
    /// 右大图，左两小图样式，顺序(左上-大图-左下)
    TTArticlePicViewStyleRightLarge = 5,
    /// 左小图，动态
    TTArticlePicViewStyleLeftSmall = 6,
};

@interface TTArticlePicView : SSThemedView

@property (nonatomic, strong) TTImageView * _Nonnull picView1;
@property (nonatomic, strong) TTImageView * _Nonnull picView2;
@property (nonatomic, strong) TTImageView * _Nonnull picView3;
@property (nonatomic, strong) SSThemedImageView * _Nonnull messageBackgroundView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull messageView;
@property (nonatomic, strong) SSThemedImageView * _Nonnull messageImageView;
@property (nonatomic, strong) SSThemedView * _Nonnull playStyleBackgroundView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull playStyleLabel;
@property (nonatomic, strong) SSThemedButton * _Nullable playButton;
@property (nonatomic) TTArticlePicViewStyle style;
@property (nonatomic) BOOL hiddenMessage;
@property (nonatomic) BOOL isVideo;

- (nonnull instancetype)initWithStyle:(TTArticlePicViewStyle)style;
- (void)layoutPics;
- (void)updatePics:(ExploreOrderedData * _Nonnull)orderedData;
- (void)updateADPics:(ExploreOrderedData * _Nonnull)orderedData;
- (TTImageView *_Nonnull)animationFromView;
@end

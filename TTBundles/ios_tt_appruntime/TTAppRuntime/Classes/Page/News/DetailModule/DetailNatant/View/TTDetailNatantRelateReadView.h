//
//  TTDetailNatantRelateReadView.h
//  Article
//
//  Created by Ray on 16/4/7.
//
//

#import "TTDetailNatantViewBase.h"
#import "TTDetailNatantRelateReadViewModel.h"
#import "TTImageView.h"
#import "TTDeviceHelper.h"
#import "TTArticleCellHelper.h"


#define kTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kAlbumTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kAlbumBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kLeftPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kRightPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleFontSize [SSUserSettingManager detailRelateReadFontSize]
#define kRightImgLeftPadding (([TTDeviceHelper is736Screen]) ? 6 : 10)
#define kFromeLabelTopPadding 6
#define kGroupImgBottomPadding 10
#define KLabelInfoHeight 20
#define kVideoIconLeftGap 6
#define kTitleTopPaddingForTopType 6

#define kTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kAlbumTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kAlbumBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)

#define kDownloadIconSize CGSizeMake([TTDeviceUIUtils tt_fontSize:12], [TTDeviceUIUtils tt_fontSize:12])

typedef void (^TTRelateVideoImageViewBlock)(BOOL success);

@interface TTDetailNatantRelateReadView : TTDetailNatantViewBase
@property (nonnull, strong, nonatomic) TTDetailNatantRelateReadViewModel * viewModel;
- (nonnull Class)viewModelClass;

- (void)refreshArticle:(nullable Article *)article;
- (void)refreshTitleUI;
- (void)refreshUI;
- (void)refreshTitleWithTags:(nullable NSArray *)tags;
- (void)hideBottomLine:(BOOL)hide;
- (void)hideFromLabel:(BOOL)hide;
- (CGFloat)imgWidth;
- (CGFloat)imgHeight;

+ (nullable TTDetailNatantRelateReadView *)genViewForArticle:(nullable Article *)article
                                                       width:(float)width
                                                    infoFlag:(nullable NSNumber *)flag;
+ (nullable TTDetailNatantRelateReadView *)genViewForArticle:(nullable Article *)article
                                                       width:(float)width
                                                    infoFlag:(nullable NSNumber *)flag
                                              forVideoDetail:(BOOL)forVideoDetail;

@end

@interface TTDetailNatantRelateReadPureTitleView : TTDetailNatantRelateReadView

@property(nonatomic, strong, nullable)SSThemedLabel * titleLabel;
@property(nonatomic, strong, nullable)SSThemedView * bottomLineView;
@property(nonatomic, strong, nullable)SSThemedButton * bgButton;
@property(nonatomic, strong, nullable)SSThemedView * titleLeftCircleView;

@end

@interface TTDetailNatantRelateReadRightImgView : TTDetailNatantRelateReadPureTitleView

@property(nonatomic, strong, nullable)TTImageView * imageView;
@property(nonatomic, strong, nullable)UILabel *fromLabel;
@property(nonatomic, strong, nullable)UILabel *commentCountLabel;
@property(nonatomic, strong, nullable)UIView * timeInfoBgView;
@property(nonatomic, strong, nullable)SSThemedImageView * videoIconView;
@property(nonatomic, strong, nullable)SSThemedLabel * videoDurationLabel;
@property(nonatomic, strong, nullable)SSThemedLabel *albumLogo;
@property(nonatomic, strong, nullable)SSThemedView *albumCover;
@property(nonatomic, strong, nullable)SSThemedLabel *albumCount;

@property (nonatomic, strong, nullable)SSThemedButton* actionButton;
@property (nonatomic, strong, nullable)SSThemedButton* downloadIcon;

- (CGFloat)titleLabelFontSize;
- (void)refreshBottomLineView;
- (float)titleHeightForArticle:(nullable Article *)article cellWidth:(float)width;
- (float)titleWidthForCellWidth:(float)width;
+ (CGSize)videoDetailRelateVideoImageSizeWithWidth:(CGFloat)width;

- (void)layoutActionButton;

@end

@interface TTDetailNatantRelateReadLeftImgView : TTDetailNatantRelateReadPureTitleView

@property(nonatomic, strong, nullable)TTImageView * imageView;
@property(nonatomic, strong, nullable)UILabel *fromLabel;
@property(nonatomic, strong, nullable)UILabel *commentCountLabel;
@property(nonatomic, strong, nullable)UIView * timeInfoBgView;
@property(nonatomic, strong, nullable)SSThemedImageView * videoIconView;
@property(nonatomic, strong, nullable)SSThemedLabel * videoDurationLabel;
@property(nonatomic, strong, nullable)SSThemedLabel *albumLogo;
@property(nonatomic, strong, nullable)SSThemedView *albumCover;
@property(nonatomic, strong, nullable)SSThemedLabel *albumCount;

@property (nonatomic, strong, nullable)SSThemedButton* actionButton;
@property (nonatomic, strong, nullable)SSThemedButton* downloadIcon;

- (CGFloat)titleLabelFontSize;
- (void)refreshBottomLineView;
- (float)titleHeightForArticle:(nullable Article *)article cellWidth:(float)width;
- (float)titleWidthForCellWidth:(float)width;
+ (CGSize)videoDetailRelateVideoImageSizeWithWidth:(CGFloat)width;

- (void)layoutActionButton;

@end

@interface TTDetailNatantRelateReadTopImgView : TTDetailNatantRelateReadPureTitleView

@property(nonatomic, strong, nullable)TTImageView * imageView;
@property(nonatomic, strong, nullable)UILabel *fromLabel;
@property(nonatomic, strong, nullable)UILabel *commentCountLabel;
@property(nonatomic, strong, nullable)UIView * timeInfoBgView;
@property(nonatomic, strong, nullable)SSThemedImageView * videoIconView;
@property(nonatomic, strong, nullable)SSThemedLabel * videoDurationLabel;
@property(nonatomic, strong, nullable)SSThemedLabel *albumLogo;
@property(nonatomic, strong, nullable)SSThemedView *albumCover;
@property(nonatomic, strong, nullable)SSThemedLabel *albumCount;

@property (nonatomic, strong, nullable)SSThemedButton* actionButton;
@property (nonatomic, strong, nullable)SSThemedButton* downloadIcon;

@property(nonatomic, assign) BOOL isRight; // 双列显示 UI 不同（醉了）

- (CGFloat)titleLabelFontSize;
- (void)refreshBottomLineView;
- (float)titleHeightForArticle:(nullable Article *)article cellWidth:(float)width;
- (float)titleWidthForCellWidth:(float)width;
+ (CGSize)videoDetailRelateVideoImageSizeWithWidth:(CGFloat)width;

- (void)layoutActionButton;

@end

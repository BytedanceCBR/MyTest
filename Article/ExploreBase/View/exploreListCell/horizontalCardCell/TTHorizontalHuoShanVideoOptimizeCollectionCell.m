//
//  TTHorizontalHuoShanVideoOptimizeCollectionCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/7/17.
//

#import "TTHorizontalHuoShanVideoOptimizeCollectionCell.h"

#import <HTSVideoPlay/TSVAnimatedImageView.h>
#import "TTArticleCellHelper.h"
#import "TSVShortVideoOriginalData.h"
#import <KVOController.h>
#import "TTDeviceUIUtils.h"
#import <ReactiveObjC/ReactiveObjC.h>

#import <TSVDebugInfoView.h>
#import <TSVDebugInfoConfig.h>

#pragma mark - 常量
#define kMaskAspectRatio           (68.f / 168.f)
#define kCoverAspectRatio          (246.f / 168.f)
#define kHalfMaskAspectRatio       (68.f / 247.f)
#define kHalfCoverAspectRatio      (335.f / 247.f)
#define kTripleMaskAspectRatio     (36.f / 113.f)
#define kTripleCoverAspectRatio    (166.f / 113.f)
#define kQuadraMaskAspectRatio     (68.f / 171.f)

#define kTitleLabelFontSize        [TTDeviceUIUtils tt_newFontSize:17.f]
#define kInfoLabelFontSize         12.f
#define kExtraLabelFontSize        12.f
#define kPlayIconSize              12.f
#define kPlayIconTopPadding        13.f
#define kPlayIconBottomPadding     14.f

#define kPlayIconTBottomPadding    7.f
#define kPlayIconTitleGap          3.f
#define kPlayIconRightGap          2.f

#define kLeftGapOnTop              8.f
#define kLeftGapOnBottom           10.f

#define kBottomMaskEdgeInsetLeft   8.f
#define kBottomMaskEdgeInsetRight  8.f
#define kBottomMaskEdgeInsetBottom 6.f

#define kInfoLabelLeftPadding      6.f  //左边放的是播放按钮
#define kInfoLabeRightGap          4.f
#define kExtraLabelLeftPadding     8.f  //左边放的是infoLabel
#define kExtraLabelRightPadding    10.f //右边放的是播放按钮
#define kTitleLabelBottomPadding   27.f
#define kTitleLabelTopPadding      8.f

//保护用，避免一个字都显示不全的情况
NS_INLINE CGFloat TTHuoShanCollectionCellInfobarLabelMinWidth() {
    static CGFloat minWidth = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *minStr = @"一";
        CGSize minSize = [minStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kExtraLabelFontSize]}];
        minWidth = ceil(minSize.width);
    });
    return minWidth;
}

@interface TTHorizontalHuoShanVideoOptimizeCollectionCell()

@property(nonatomic, strong) TTImageView *coverImageView;         //封面图
@property(nonatomic, strong) UIImageView *bottomMaskImage;       //底部阴影
@property(nonatomic, strong) SSThemedImageView *playIcon;         //播放icon
@property(nonatomic, strong) SSThemedLabel *titleLabel;           //标题
@property(nonatomic, strong) SSThemedLabel *infoLabel;            //播放次数或者用户名
@property(nonatomic, strong) SSThemedLabel *extraLabel;           //评论/点赞数

@property (nonatomic, strong) TSVDebugInfoView *debugInfoView;

@property(nonatomic, strong) ExploreOrderedData *orderedData;
@property(nonatomic, strong) TSVShortVideoOriginalData *shortVideoOriginalData;

@property(nonatomic, assign) BOOL inScrollCard;
@end

@implementation TTHorizontalHuoShanVideoOptimizeCollectionCell

#pragma mark - TTHorizontalHuoShanCollectionCellProtocol
+ (CGFloat)heightForHuoShanVideoWithCellWidth:(CGFloat)width inScrollCard:(BOOL)inScrollCard originalCardItemsHasTitle:(BOOL)hasTitle cellStyle:(TTHorizontalCardStyle)style
{
    
    CGFloat cellWidth = width;
    if (style == TTHorizontalCardStyleOne) {
        return ceilf(cellWidth * kHalfCoverAspectRatio);
    } else if (style == TTHorizontalCardStyleThree) {
        return ceilf(cellWidth * kTripleCoverAspectRatio);
    } else if (style == TTHorizontalCardStyleFour) {
        return cellWidth;
    } else {
        return ceilf(cellWidth * kCoverAspectRatio);
    }
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        [[[[[RACSignal combineLatest:@[RACObserve(self, shortVideoOriginalData.shortVideo.commentCount),
                                       RACObserve(self, shortVideoOriginalData.shortVideo.diggCount),
                                       RACObserve(self, shortVideoOriginalData.shortVideo.playCount)]]
            distinctUntilChanged]
           takeUntil:[self rac_willDeallocSignal]]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self refreshUIData];
         }];
    }
    return self;
}

- (CGRect)coverImageViewFrame
{
    return self.coverImageView.frame;
}

- (void)setupDataSourceWithData:(ExploreOrderedData *)orderedData inScrollCard:(BOOL)inScrollCard
{
    self.orderedData = orderedData;
    TSVShortVideoOriginalData *shortVideoOriginalData = orderedData.shortVideoOriginalData;
    if (shortVideoOriginalData) {
        
        self.shortVideoOriginalData = shortVideoOriginalData;
        
        self.inScrollCard = inScrollCard;
        
        [self refreshUIData];
        
    }
}

#pragma mark -
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.coverImageView.imageView.image = nil;
    self.bottomMaskImage.image = nil;
    self.titleLabel.hidden = YES;
    self.infoLabel.hidden = NO;
    self.extraLabel.hidden = NO;
    self.titleLabel.text = nil;
    self.infoLabel.text = nil;
    self.extraLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    TTHorizontalCardContentCellStyle cellStyle = [TTShortVideoHelper contentCellStyleWithItemData:self.orderedData];
    
    if (cellStyle == TTHorizontalCardContentCellStyle3) {
        [self p_refreshUIForCellType3];
    } else if (cellStyle == TTHorizontalCardContentCellStyle4 || cellStyle == TTHorizontalCardContentCellStyle5) {
        [self p_refreshUIForCellType4And5];
    } else if (cellStyle == TTHorizontalCardContentCellStyle6){
        [self p_refreshUIForCellType6];
    } else if (cellStyle == TTHorizontalCardContentCellStyle7){
        [self p_refreshUIForCellType7];
    } else if (cellStyle == TTHorizontalCardContentCellStyle8){
        [self p_refreshUIForCellType8];
    } else {
        [self p_refreshUIForCellType6];
    }

    [self refreshDebugInfo];
}

#pragma mark - 刷新UI数据
- (void)refreshUIData
{
    TTImageInfosModel *imageModel = self.shortVideoOriginalData.shortVideo.detailCoverImageModel;
    [self.coverImageView tsv_setImageWithModel:imageModel placeholderImage:nil];
    
    self.titleLabel.text = self.shortVideoOriginalData.shortVideo.title;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:kTitleLabelFontSize];

    self.infoLabel.text = [self p_infoLabelText];
    
    self.extraLabel.text = [self p_extraLabelText];
    
    self.debugInfoView.debugInfo = self.shortVideoOriginalData.shortVideo.debugInfo;
    [self setNeedsLayout];
}

#pragma mark - UI控件
- (TTImageView *)coverImageView
{
    if(!_coverImageView){
        _coverImageView = [[TTImageView alloc] init];
        _coverImageView.imageContentMode = TTImageViewContentModeScaleAspectFillRemainTop;
        _coverImageView.backgroundColorThemeKey = kColorBackground3;
        _coverImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _coverImageView.borderColorThemeKey = kColorLine1;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UIImageView *)bottomMaskImage
{
    if(!_bottomMaskImage) {
        _bottomMaskImage = [[UIImageView alloc] init];
        _bottomMaskImage.backgroundColor = [UIColor clearColor];
        _bottomMaskImage.contentMode = UIViewContentModeScaleToFill;
        [self.coverImageView addSubview:_bottomMaskImage];
    }
    return _bottomMaskImage;
}

- (SSThemedImageView *)playIcon
{
    if(!_playIcon){
        _playIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kPlayIconSize, kPlayIconSize)];
        _playIcon.contentMode = UIViewContentModeScaleAspectFill;
        _playIcon.imageName = @"horizontal_play_icon";
        [self.bottomMaskImage addSubview:_playIcon];
    }
    return _playIcon;
}

- (SSThemedLabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColorThemeKey = kColorText10;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleLabelFontSize];
        [self.bottomMaskImage addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)infoLabel
{
    if(!_infoLabel){
        _infoLabel = [[SSThemedLabel alloc] init];
        _infoLabel.textColorThemeKey = kColorText10;
        _infoLabel.numberOfLines = 1;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _infoLabel.font = [UIFont systemFontOfSize:kInfoLabelFontSize];
        [self.bottomMaskImage addSubview:_infoLabel];
    }
    return _infoLabel;
}

- (SSThemedLabel *)extraLabel
{
    if(!_extraLabel){
        _extraLabel = [[SSThemedLabel alloc] init];
        _extraLabel.textColorThemeKey = kColorText10;
        _extraLabel.numberOfLines = 1;
        _extraLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _extraLabel.font = [UIFont systemFontOfSize:kExtraLabelFontSize];
        [self.bottomMaskImage addSubview:_extraLabel];
    }
    return _extraLabel;
}

- (TSVDebugInfoView *)debugInfoView
{
    if (!_debugInfoView) {
        _debugInfoView = [[TSVDebugInfoView alloc] init];
        _debugInfoView.hidden = YES;
        [self.contentView addSubview:_debugInfoView];
    }
    
    return _debugInfoView;
}

#pragma mark - Private Method

- (void)p_refreshUIForCellType3
{
    [self p_layoutBackgroundViewBottomTitle];
    
    [self p_layoutInfoBarViewForCellType3];
}

- (void)p_refreshUIForCellType4And5
{
    [self p_layoutBackgroundViewForTopTitle];
    
    [self p_layoutInfoBarViewForCellType4And5];
}

- (void)p_refreshUIForCellType6
{
    [self p_layoutBackgroundViewBottomTitle];
    self.bottomMaskImage.height = ceilf(self.bottomMaskImage.width * kHalfMaskAspectRatio);
    self.bottomMaskImage.bottom = self.coverImageView.bottom;
    
    [self p_layoutViewForCellType6And8];
}

- (void)p_refreshUIForCellType7
{
    [self p_layoutBackgroundViewBottomTitle];
    
    self.bottomMaskImage.height = ceilf(self.bottomMaskImage.width * kTripleMaskAspectRatio);
    self.bottomMaskImage.bottom = self.coverImageView.bottom;
    
    [self p_layoutInfoBarViewForCellType7];
}

- (void)p_refreshUIForCellType8
{
    [self p_layoutBackgroundViewBottomTitle];
    self.bottomMaskImage.height = ceilf(self.bottomMaskImage.width * kQuadraMaskAspectRatio);
    self.bottomMaskImage.bottom = self.coverImageView.bottom;
    
    [self p_layoutViewForCellType6And8];
}

// 布局封面图，以及底部的渐变图
- (void)p_layoutBackgroundViewBottomTitle
{
    self.coverImageView.frame = self.bounds;
    
    UIImage *tmpImage = [UIImage imageNamed:@"cover_huoshan"];
    self.bottomMaskImage.image = [UIImage imageWithCGImage:tmpImage.CGImage
                                                     scale:tmpImage.scale
                                               orientation:UIImageOrientationDown];
    self.bottomMaskImage.width = self.coverImageView.width;
    self.bottomMaskImage.height = ceilf(self.bottomMaskImage.width * kMaskAspectRatio);
    self.bottomMaskImage.bottom = self.coverImageView.height;
    self.bottomMaskImage.left = 0;
}

- (void)p_layoutBackgroundViewForTopTitle
{
    self.coverImageView.frame = self.bounds;
    
    self.bottomMaskImage.image = [UIImage imageNamed:@"cover_huoshan"];
    self.bottomMaskImage.width = self.coverImageView.width;
    self.bottomMaskImage.height = ceilf(self.bottomMaskImage.width * kMaskAspectRatio);
    self.bottomMaskImage.top = self.coverImageView.top;
    self.bottomMaskImage.left = 0;
}

- (void)p_layoutInfoBarViewForCellType3
{
    self.playIcon.bottom = self.bottomMaskImage.height - kPlayIconBottomPadding;
    self.playIcon.left = kLeftGapOnBottom;
    
    [self p_layoutInfoAndExtraLabel];
    
    CGFloat titleMaxWidth = self.bottomMaskImage.width - 2 * kLeftGapOnTop;
    self.titleLabel.hidden = NO;
    [self.titleLabel sizeToFit];
    self.titleLabel.width = titleMaxWidth;
    self.titleLabel.bottom = self.playIcon.top - kPlayIconTitleGap;

    self.titleLabel.left = kLeftGapOnBottom;
}

- (void)p_layoutInfoBarViewForCellType4And5
{
    if (isEmptyString(self.titleLabel.text)) {
        self.playIcon.top = self.bottomMaskImage.top + kPlayIconTopPadding;
    } else {
        CGFloat titleMaxWidth = self.bottomMaskImage.width - 2 * kLeftGapOnTop;
        self.titleLabel.hidden = NO;
        [self.titleLabel sizeToFit];
        self.titleLabel.width = titleMaxWidth;
        self.titleLabel.left = kLeftGapOnTop;
        self.titleLabel.top = self.bottomMaskImage.top + kTitleLabelTopPadding;
        
        self.playIcon.top = self.titleLabel.bottom + kPlayIconTitleGap;
    }
    self.playIcon.left = kLeftGapOnTop;
    [self p_layoutInfoAndExtraLabel];
}

- (void)p_layoutInfoBarViewForCellType7
{
    self.playIcon.bottom = self.bottomMaskImage.height - kPlayIconTBottomPadding;
    self.playIcon.left = kBottomMaskEdgeInsetBottom;
    CGFloat labelMaxWidth = self.bottomMaskImage.width - 2 * kBottomMaskEdgeInsetBottom  - kPlayIconRightGap - kPlayIconSize;
    [self.infoLabel sizeToFit];
    self.infoLabel.width = MIN(labelMaxWidth, self.infoLabel.width);
    if (self.infoLabel.width < TTHuoShanCollectionCellInfobarLabelMinWidth()) {
        self.infoLabel.width = 0.f;
        self.infoLabel.hidden = YES;
    } else {
        self.infoLabel.hidden = NO;
    }
    self.infoLabel.left = self.playIcon.right + kPlayIconRightGap;
    self.infoLabel.centerY = self.playIcon.centerY;
    self.extraLabel.hidden = YES;
    self.titleLabel.hidden = YES;
}

- (void)p_layoutViewForCellType6And8
{
    self.playIcon.bottom = self.bottomMaskImage.height - 11.f;
    self.playIcon.left = kLeftGapOnBottom;
    
    CGFloat titleMaxWidth = self.bottomMaskImage.width - 2 * kLeftGapOnTop;
    self.titleLabel.hidden = NO;
    [self.titleLabel sizeToFit];
    self.titleLabel.width = titleMaxWidth;
    self.titleLabel.bottom = self.playIcon.top - kPlayIconTitleGap;
    
    self.titleLabel.left = kLeftGapOnBottom;
    
    [self p_layoutInfoAndExtraLabel];

}

- (void)p_layoutInfoAndExtraLabel
{
    CGFloat labelMaxWidth = self.bottomMaskImage.width - 2 * kLeftGapOnTop  - kPlayIconRightGap - kPlayIconSize;
    [self.infoLabel sizeToFit];
    self.infoLabel.width = MIN(labelMaxWidth, self.infoLabel.width);
    if (self.infoLabel.width < TTHuoShanCollectionCellInfobarLabelMinWidth()) {
        self.infoLabel.width = 0.f;
        self.infoLabel.hidden = YES;
    } else {
        self.infoLabel.hidden = NO;
    }
    self.infoLabel.left = self.playIcon.right + kPlayIconRightGap;
    self.infoLabel.centerY = self.playIcon.centerY;
    
    labelMaxWidth = labelMaxWidth - self.infoLabel.width - kInfoLabeRightGap;
    [self.extraLabel sizeToFit];
    self.extraLabel.width = MIN(labelMaxWidth, self.extraLabel.width);
    self.extraLabel.left = self.infoLabel.right + kInfoLabeRightGap;
    self.extraLabel.centerY = self.playIcon.centerY;
}

- (void)p_layoutTitleLabel
{
    self.titleLabel.hidden = NO;
    
    CGFloat labelMaxWidth = self.bottomMaskImage.width - kBottomMaskEdgeInsetLeft - kBottomMaskEdgeInsetRight;

    [self.titleLabel sizeToFit];
    self.titleLabel.width = labelMaxWidth;
    self.titleLabel.left = kBottomMaskEdgeInsetLeft;
    self.titleLabel.bottom = self.bottomMaskImage.height - kTitleLabelBottomPadding;
}

- (NSString *)p_infoLabelText
{
    NSInteger count = self.shortVideoOriginalData.shortVideo.playCount;
    NSString *playCountStr = [NSString stringWithFormat:@"%@次播放", [TTBusinessManager formatPlayCount:count]];
    return playCountStr;
}

- (NSString *)p_extraLabelText{
    TTShortVideoModel *shortVideo = self.orderedData.shortVideoOriginalData.shortVideo;
    if (self.orderedData.cellCtrls && [self.orderedData.cellCtrls isKindOfClass: [NSDictionary class]]) {
        ExploreOrderedDataCellFlag cellFlag = [self.orderedData.cellCtrls tt_integerValueForKey:@"cell_flag"];
        if ((cellFlag & ExploreOrderedDataCellFlagShowCommentCount) != 0) {
            return [NSString stringWithFormat:@"%@评论", [TTBusinessManager formatCommentCount:shortVideo.commentCount]];
        } else if ((cellFlag & ExploreOrderedDataCellFlagShowDig) != 0) {
            return [NSString stringWithFormat:@"%@赞", [TTBusinessManager formatCommentCount:shortVideo.diggCount]];
        }
    }
    return [NSString stringWithFormat:@"%@评论", [TTBusinessManager formatCommentCount:shortVideo.commentCount]];
}

- (void)refreshDebugInfo
{
    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        [self.contentView bringSubviewToFront:self.debugInfoView];
        self.debugInfoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 50);
        self.debugInfoView.hidden = NO;
    } else {
        self.debugInfoView.hidden = YES;
    }
}

@end

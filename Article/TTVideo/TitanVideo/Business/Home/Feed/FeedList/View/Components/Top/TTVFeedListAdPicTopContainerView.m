//
//  TTVFeedListAdPicTopContainerView.m
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedListAdPicTopContainerView.h"
#import "TTArticlePicView.h"
#import "TTLabel.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTLabelTextHelper.h"

#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import <TTVideoService/Enum.pbobjc.h>
#import "TTImageInfosModel+Extention.h"
#import "TTUserSettingsManager+FontSettings.h"

#define kCellLeftPadding            cellLeftPadding()           //view左边距
#define kTopMaskH 80
#define kVideoTitleY ([TTDeviceHelper isScreenWidthLarge320]?15.0:8.0)

extern ttvs_isEnhancePlayerTitleFont(void);
extern CGFloat ttvs_listVideoMaxHeight(void);

@interface TTVFeedListAdPicTopContainerView()

@property (nonatomic, strong) SSThemedLabel * _Nonnull videoTitleLabel;
@property (nonatomic, strong) TTArticlePicView * _Nonnull picView;
@property (nonatomic, strong) UIImageView * _Nonnull topMaskView;

@end

@implementation TTVFeedListAdPicTopContainerView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];
    }
    return self;
}

#pragma mark - public

+ (CGFloat)obtainHeightForFeed:(TTVFeedListItem *)cellEntity cellWidth:(CGFloat)width {
    
    if (cellEntity && !cellEntity.imageHeight) {
        TTVVideoArticle *article = [cellEntity article];
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithImageUrlList:article.largeImageList];
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isPad = [TTDeviceHelper isPadDevice];
        float picWidth = isPad ? (width - 2 * kCellLeftPadding) : width;
        float imageHeight = [self heightForImageWidth:model.width height:model.height constraintWidth:picWidth proportion:article.videoProportion];
        cellEntity.imageHeight = imageHeight;
    }
    return cellEntity ? cellEntity.imageHeight : 0;
}

+ (float)heightForImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth proportion:(float)proportion
{
    if (proportion > 0.01) {//大于0.01做保护
        CGFloat height = cWidth / proportion;
        CGFloat maxHeight = ttvs_listVideoMaxHeight();
        if (maxHeight > 0 && height > maxHeight) {
            height = maxHeight;
        }
        height = ceilf(height);
        return height;
    }
    return [ExploreCellHelper heightForVideoImageWidth:width height:height constraintWidth:cWidth];
}

#pragma mark - Private

- (void)p_updateADPics {
    
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithImageUrlList:[self article].largeImageList];
    [self.picView.picView1 setImageWithModel:model placeholderImage:nil];
}

#pragma mark - UI

- (void)configureUI {
    
    [self updatePicView];
    [self updateTopMaskView];
    [self updateVideoTitleLabel];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self refreshUI];
}

/**
 更新UI界面
 */
- (void)refreshUI {
    
    TTVVideoArticle *article = [self article];

    if (article) {
        
        BOOL isPad = [TTDeviceHelper isPadDevice];
        CGFloat x = isPad ? kPaddingLeft() : 0;
        CGFloat y = 0;
        
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithImageUrlList:article.largeImageList];
        float picWidth = [self getPicWidth];
        if (!self.cellEntity.imageHeight) {
            float picHeight = [[self class] heightForImageWidth:model.width height:model.height constraintWidth:picWidth proportion:self.article.videoProportion];
            self.cellEntity.imageHeight = picHeight;
        }
        self.picView.frame = CGRectMake(x, y, picWidth, self.cellEntity.imageHeight);
        
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isApp = (self.cellEntity.originData.videoBusinessType == TTVVideoBusinessType_PicAdapp);
    
        // 布局标题控件
        NSString *title = (isApp ? article.abstract: article.title);

        if (isEmptyString(title)){//普通大图时
            title = article.title;
        }
        
        self.topMaskView.frame = CGRectMake(0, 0, picWidth, kTopMaskH);
        
        if (!isEmptyString(title)) {
            if (self.cellEntity.titleHeight < 1) {
                CGFloat titleHeight = [TTLabelTextHelper heightOfText:title fontSize:[self.class settedTitleFontSize] forWidth:[self getPicWidth] - kPaddingLeft() - kPaddingRight() forLineHeight:[UIFont boldSystemFontOfSize:[self.class settedTitleFontSize]].lineHeight constraintToMaxNumberOfLines:2];
                self.cellEntity.titleHeight = titleHeight;
            }
            self.videoTitleLabel.frame = CGRectMake(kPaddingLeft(), kVideoTitleY, picWidth - kPaddingLeft() - kPaddingRight(), self.cellEntity.titleHeight);
        }
        
    }
}

/** 更新图片(视频) */
- (void)updatePicView {
    
    if (self.cellEntity) {
        
        [self p_updateADPics];
    }
}

- (TTVVideoArticle *)article
{
    return [self.cellEntity article];
}

/** 更新视频cell标题 */
- (void)updateVideoTitleLabel {
    
    if (self.cellEntity) {
        
        TTVVideoArticle *article = [self article];
        
        if (article) {
            
            NSString *title = article.title;//(call2Action ? adModel.title : adModel.descInfo);
            if (!isEmptyString(title)) {
                
                self.videoTitleLabel.text =title;
            } else {
                self.videoTitleLabel.text = nil;
            }
        }
    }
}

- (float)getPicWidth
{
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float picWidth = isPad ? (self.width - 2 * kCellLeftPadding) : self.width;
    return picWidth;
}

/** 更新视频频道大图遮罩 */
- (void)updateTopMaskView {
    
    [self topMaskView];
}

#pragma mark - Getters & Setters

- (void)setCellEntity:(TTVFeedListItem *)cellEntity {
    
    _cellEntity = cellEntity;
    
    [self configureUI];
    
    [self setNeedsLayout];
}

/// 图片(视频)控件
- (TTArticlePicView *)picView {
    if (_picView == nil) {
        _picView = [[TTArticlePicView alloc] initWithStyle:TTArticlePicViewStyleLarge];
        _picView.messageImageView.hidden = YES;
        [self addSubview:_picView];
    }
    return _picView;
}

/** 视频频道大图广告标题 */
- (SSThemedLabel *)videoTitleLabel
{
    if (!_videoTitleLabel) {
        _videoTitleLabel = [[SSThemedLabel alloc] init];
        _videoTitleLabel.textColorThemeKey = kColorText10;
        _videoTitleLabel.backgroundColor = [UIColor clearColor];
        _videoTitleLabel.numberOfLines = 2;
        _videoTitleLabel.font = [UIFont boldSystemFontOfSize:[self.class settedTitleFontSize]];
        _videoTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.picView addSubview:_videoTitleLabel];
    }
    return _videoTitleLabel;
}

- (UIImageView *)topMaskView
{
    if (!_topMaskView) {
        UIImage *topMaskImage = [[UIImage imageNamed:@"thr_shadow_video"] resizableImageWithCapInsets:UIEdgeInsetsZero];
        _topMaskView = [[UIImageView alloc] initWithImage:topMaskImage];
        [self.picView addSubview:_topMaskView];
    }
    return _topMaskView;
}

- (void)fontSizeChanged{
    TTVVideoArticle *article = [self article];
    // 根据图片实际宽高设置其在cell中的高度
    BOOL isApp = (self.cellEntity.originData.videoBusinessType == TTVVideoBusinessType_PicAdapp);
    
    // 布局标题控件
    NSString *title = (isApp ? article.abstract: article.title);
    
    if (isEmptyString(title)){//普通大图时
        title = article.title;
    }
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:title fontSize:[self.class settedTitleFontSize] forWidth:[self getPicWidth] - kPaddingLeft() - kPaddingRight() forLineHeight:[UIFont boldSystemFontOfSize:[self.class settedTitleFontSize]].lineHeight constraintToMaxNumberOfLines:2];
    self.cellEntity.titleHeight = titleHeight;
    self.videoTitleLabel.font = [UIFont boldSystemFontOfSize:[self.class settedTitleFontSize]];
    [self setNeedsLayout];
}


+ (float)settedTitleFontSize {
    NSDictionary *fontSizes = [NSDictionary dictionary];
    if (ttvs_isEnhancePlayerTitleFont()){
        fontSizes = @{@"iPad" : @[@20, @22, @24, @28],
                      @"iPhone667": @[@18,@19,@20,@22],
                      @"iPhone736" : @[@19, @20, @21, @23],
                      @"iPhone" : @[@16, @17, @18, @20]};
        
    }else{
        fontSizes = @{@"iPad" : @[@19, @22, @24, @29],
                      @"iPhone667": @[@16,@18,@20,@23],
                      @"iPhone736" : @[@16, @18, @20, @23],
                      @"iPhone" : @[@14, @16, @18, @21]};
    }
    
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    NSInteger selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}


@end

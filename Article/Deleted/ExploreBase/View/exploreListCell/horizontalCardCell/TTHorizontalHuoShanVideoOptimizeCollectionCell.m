//
//  TTHorizontalHuoShanVideoOptimizeCollectionCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/7/17.
//

#import "TTHorizontalHuoShanVideoOptimizeCollectionCell.h"

#import <HTSVideoPlay/TSVAnimatedImageView.h>
#import "TSVShortVideoOriginalData.h"
#import <KVOController.h>
#import "TTDeviceUIUtils.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTUserSettingsManager+FontSettings.h"
#import "NewsUserSettingManager.h"
#import "TSVAvatarImageView.h"
#import "TSVTagInfoView.h"

#import <TSVDebugInfoView.h>
#import <TSVDebugInfoConfig.h>
#import "UIViewAdditions.h"
#import "ExploreOrderedData+TTBusiness.h"

#pragma mark - 常量

#define kMaskAspectRatio       (68.f / 247.f)
#define kCoverAspectRatio      (335.f / 247.f)

#define kTitleLabelFontSize        [TTDeviceUIUtils tt_newFontSize:17.f]
#define kNameLabelFontSize         [TTDeviceUIUtils tt_newFontSize:14.f]
#define kInfoLabelFontSize         [TTDeviceUIUtils tt_newFontSize:12.f]

#define kLeftGapOnBottom           10.f

#define kBottomMaskEdgeInsetLeft   8.f
#define kBottomMaskEdgeInsetRight  8.f

#define kInfoLabeRightGap          4.f
#define kTitleLabelBottomPadding   27.f

@interface TTHorizontalHuoShanVideoOptimizeCollectionCell()

@property(nonatomic, strong) TTImageView                *coverImageView;
@property(nonatomic, strong) UIImageView                *bottomMaskImage;
@property(nonatomic, strong) SSThemedLabel              *titleLabel;
@property(nonatomic, strong) SSThemedLabel              *infoLabel;
@property(nonatomic, strong) SSThemedLabel              *nameInfoView;
@property(nonatomic, strong) TSVAvatarImageView         *avatarImageView;
@property(nonatomic, strong) TSVTagInfoView             *tagInfoView;
@property(nonatomic, strong) TSVDebugInfoView           *debugInfoView;

@property(nonatomic, strong) ExploreOrderedData         *orderedData;
@property(nonatomic, strong) TSVShortVideoOriginalData  *shortVideoOriginalData;

@end

@implementation TTHorizontalHuoShanVideoOptimizeCollectionCell

#pragma mark - TTHorizontalHuoShanCollectionCellProtocol
+ (CGFloat)heightForHuoShanVideoWithCellWidth:(CGFloat)width
{
    return ceilf(width * kCoverAspectRatio);
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
                
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kSettingFontSizeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification * _Nullable x) {
             @strongify(self);
             [self setNeedsLayout];
         }];
    }
    return self;
}

- (CGRect)coverImageViewFrame
{
    return self.coverImageView.frame;
}

- (void)setupDataSourceWithData:(ExploreOrderedData *)orderedData
{
    self.orderedData = orderedData;
    TSVShortVideoOriginalData *shortVideoOriginalData = orderedData.shortVideoOriginalData;
    if (shortVideoOriginalData) {
        self.shortVideoOriginalData = shortVideoOriginalData;
        [self refreshUIData];
    }
}

- (void)configFollowRecommendEnableStatus:(BOOL)followRecommendEnableStatus {
    
}

#pragma mark -
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.coverImageView.imageView.image = nil;
    self.bottomMaskImage.image = nil;
    self.titleLabel.hidden = YES;
    self.titleLabel.text = nil;
    self.tagInfoView.hidden = YES;
    self.avatarImageView.hidden = YES;
    self.nameInfoView.hidden = YES;
    self.infoLabel.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self p_layoutBackgroundViewBottomTitle];
    
    BOOL isFollowing = self.shortVideoOriginalData.shortVideo.author.isFollowing && [self.shortVideoOriginalData.shortVideo.labelForList containsString:@"关注"];
    if (isFollowing) {
        self.titleLabel.hidden = YES;
        self.tagInfoView.hidden = YES;
        self.avatarImageView.hidden = NO;
        self.avatarImageView.left = kLeftGapOnBottom;
        self.avatarImageView.bottom = self.bottomMaskImage.height - 10.f;

        self.nameInfoView.hidden = NO;
        self.nameInfoView.width = self.bottomMaskImage.width - self.avatarImageView.width - 2 * kLeftGapOnBottom - 8.f;
        self.nameInfoView.height = 20.f;
        self.nameInfoView.left = self.avatarImageView.right + 8.f;
        self.nameInfoView.top = self.avatarImageView.top;
        
        self.infoLabel.hidden = NO;
        self.infoLabel.font = [UIFont systemFontOfSize:kInfoLabelFontSize];
        [self.infoLabel sizeToFit];
        self.infoLabel.width = self.nameInfoView.width;
        self.infoLabel.left = self.nameInfoView.left;
        self.infoLabel.bottom = self.avatarImageView.bottom;
        
    } else {
        self.nameInfoView.hidden = YES;
        self.avatarImageView.hidden = YES;
        self.infoLabel.hidden = YES;
        
        float fontSize = [NewsUserSettingManager fontSizeFromNormalSize:kTitleLabelFontSize isWidescreen:[TTDeviceHelper isScreenWidthLarge320]];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        CGFloat titleMaxWidth = self.bottomMaskImage.width - 2 * kLeftGapOnBottom;
        self.titleLabel.hidden = NO;
        [self.titleLabel sizeToFit];
        self.titleLabel.width = titleMaxWidth;
        self.titleLabel.left = kLeftGapOnBottom;
        self.titleLabel.bottom = self.bottomMaskImage.height - 11.f;
        
        if (!isEmptyString(self.shortVideoOriginalData.shortVideo.labelForList) && ![self.shortVideoOriginalData.shortVideo.labelForList containsString:@"关注"]) {
            //  已关注样式取关后不应该显示laber_for_list，客户端trick实现
            self.tagInfoView.hidden = NO;
            self.tagInfoView.frame = CGRectMake(kLeftGapOnBottom, self.titleLabel.top - 25.f, [self.tagInfoView originalContainerWidth], 20.f);
        }
    }
    
    [self refreshDebugInfo];
}

#pragma mark - 刷新UI数据
- (void)refreshUIData
{
    TTImageInfosModel *imageModel = self.shortVideoOriginalData.shortVideo.detailCoverImageModel;
    [self.coverImageView tsv_setImageWithModel:imageModel placeholderImage:nil];
    self.titleLabel.text = self.shortVideoOriginalData.shortVideo.title;
    [self.avatarImageView refreshWithModel:self.shortVideoOriginalData.shortVideo.author];
    [self.tagInfoView refreshTagWithText:self.shortVideoOriginalData.shortVideo.labelForList];
    self.infoLabel.text = self.shortVideoOriginalData.shortVideo.labelForList;
    self.debugInfoView.debugInfo = self.shortVideoOriginalData.shortVideo.debugInfo;
    self.nameInfoView.text = self.shortVideoOriginalData.shortVideo.author.name;
    [self setNeedsLayout];
}

#pragma mark - UI控件
- (TTImageView *)coverImageView
{
    if (!_coverImageView) {
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
    if (!_bottomMaskImage) {
        _bottomMaskImage = [[UIImageView alloc] init];
        _bottomMaskImage.backgroundColor = [UIColor clearColor];
        _bottomMaskImage.contentMode = UIViewContentModeScaleToFill;
        [self.coverImageView addSubview:_bottomMaskImage];
    }
    return _bottomMaskImage;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColorThemeKey = kColorText10;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bottomMaskImage addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)nameInfoView
{
    if (!_nameInfoView) {
        _nameInfoView = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _nameInfoView.text = self.shortVideoOriginalData.shortVideo.author.name;
        _nameInfoView.font = [UIFont boldSystemFontOfSize:kNameLabelFontSize];
        _nameInfoView.numberOfLines = 1;
        _nameInfoView.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameInfoView.textColors = @[@"ffffff",@"707070"];
        _nameInfoView.hidden = YES;
        [self.bottomMaskImage addSubview:_nameInfoView];
    }
    return _nameInfoView;
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

- (TSVAvatarImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[TSVAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)
                                                               model:self.orderedData.shortVideoOriginalData.shortVideo.author
                                                    disableNightMode:NO];
        _avatarImageView.hidden = YES;
        [self.bottomMaskImage addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (TSVTagInfoView *)tagInfoView
{
    if (!_tagInfoView) {
        _tagInfoView = [[TSVTagInfoView alloc] initWithNightThemeEnabled:YES];
        _tagInfoView.style = TSVTagInfoViewStyleDefault;
        [self.bottomMaskImage addSubview:_tagInfoView];
    }
    return _tagInfoView;
}

-(SSThemedLabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[SSThemedLabel alloc] init];
        _infoLabel.hidden = YES;
        _infoLabel.textColorThemeKey = kColorText10;
        _infoLabel.numberOfLines = 1;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bottomMaskImage addSubview:_infoLabel];
    }
    return _infoLabel;
}

#pragma mark - Private Method

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

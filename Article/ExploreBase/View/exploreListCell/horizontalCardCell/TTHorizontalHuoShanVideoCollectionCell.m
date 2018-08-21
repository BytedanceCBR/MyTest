//
//  TTHorizontalHuoShanVideoCollectionCell.m
//  Article
//
//  Created by 王双华 on 2017/5/17.
//
//

#import "TTHorizontalHuoShanVideoCollectionCell.h"
#import "SSThemed.h"
#import <HTSVideoPlay/TSVAnimatedImageView.h>
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVShortVideoOriginalData.h"
#import "UIViewAdditions.h"
#import "TTArticleCellHelper.h"
#import <KVOController.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TSVDebugInfoView.h>
#import <TSVDebugInfoConfig.h>

#define kCoverAspectRatio (1.f / 0.863f)
#define kMaskAspectRatio (8.f / 21.f)
#define kIPIconLeft 8
#define kIPIconBottom 10
#define kIPIconH    12
#define KIPIconW    10

#define kLocationLabelLeft 4
#define KLocationLabelFontSize 12
#define kLocationLabelLineHeight  22


#define kPlayBackRight      8
#define kPlayBackBottom     6
#define kPlayBackSide       20

#define kPlayIconW  6
#define kPlayIconH  8

#define kTitleLabelTop  7
#define kInfoLabelTop   3

#define kTitleLabelLineHeight   22
#define kInfoLabelLineHeight    20

#define kTitleLabelFontSize 17
#define kInfoLabelFontSize  12

#pragma mark - TTHorizontalHuoShanVideoCollectionCell

@interface TTHorizontalHuoShanVideoCollectionCell()

@property (nonatomic, strong) TTImageView   *coverImageView;//封面
@property (nonatomic, strong) SSThemedImageView *bottomMaskImage;//底部阴影
@property (nonatomic, strong) SSThemedImageView *ipIcon;//定位icon
@property (nonatomic, strong) SSThemedLabel *locationLabel; //定位文案
@property (nonatomic, strong) SSThemedImageView *playIcon;//播放icon
@property (nonatomic, strong) SSThemedImageView *playBackgroundView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;//标题
@property (nonatomic, strong) SSThemedLabel *nameLabel;//用户名
@property (nonatomic, strong) SSThemedLabel *infoLabel;//信息
@property (nonatomic, strong) TSVDebugInfoView *debugInfoView;

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) TSVShortVideoOriginalData *shortVideoOriginalData;

@property (nonatomic, assign) BOOL inScrollCard;
@end

@implementation TTHorizontalHuoShanVideoCollectionCell

#pragma mark - TTHorizontalHuoShanCollectionCellProtocol
+ (CGFloat)heightForHuoShanVideoWithCellWidth:(CGFloat)width inScrollCard:(BOOL)inScrollCard originalCardItemsHasTitle:(BOOL)hasTitle cellStyle:(TTHorizontalCardStyle)style
{
    CGFloat cellWidth = width;
    CGFloat cellHeight = 0;
    
    //封面
    cellHeight += ceilf(cellWidth * kCoverAspectRatio);
    
    //标题顶部间距
    cellHeight += kTitleLabelTop;
    //标题
    cellHeight += kTitleLabelLineHeight;

    if (inScrollCard || hasTitle) {
        //信息顶部间距
        cellHeight += kInfoLabelTop;
        //信息栏
        cellHeight += kInfoLabelLineHeight;
    }
    
    return cellHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        [[[[RACObserve(self, shortVideoOriginalData.shortVideo.commentCount) distinctUntilChanged]
           takeUntil:[self rac_willDeallocSignal]]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self refreshUIData];
         }];

        [self.contentView addSubview:self.debugInfoView];
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

- (void)refreshUIData
{
    TTShortVideoModel *shortVideo = self.orderedData.shortVideoOriginalData.shortVideo;
    TTImageInfosModel *imageModel = shortVideo.detailCoverImageModel;
    [self.coverImageView tsv_setImageWithModel:imageModel placeholderImage:nil];
    if (!isEmptyString(shortVideo.labelForList)) {
        self.locationLabel.text = shortVideo.labelForList;
        self.ipIcon.hidden = NO;
        self.locationLabel.hidden = NO;
    } else {
        self.locationLabel.text = @"";
        self.ipIcon.hidden = YES;
        self.locationLabel.hidden = YES;
    }
    self.titleLabel.text = shortVideo.title;
    
    self.nameLabel.text = shortVideo.author.name;
    
    NSInteger count = shortVideo.commentCount;
    NSString *commentCount = [NSString stringWithFormat:@"%@评论",[TTBusinessManager formatCommentCount:count]];
    self.infoLabel.text = commentCount;
    self.debugInfoView.debugInfo = shortVideo.debugInfo;
    
    [self setNeedsLayout];
}

- (TTImageView *)coverImageView
{
    if(!_coverImageView){
        _coverImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _coverImageView.imageContentMode = TTImageViewContentModeScaleAspectFillRemainTop;
        _coverImageView.backgroundColorThemeKey = kColorBackground3;
        _coverImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _coverImageView.borderColorThemeKey = kColorLine1;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (SSThemedImageView *)bottomMaskImage
{
    if (!_bottomMaskImage) {
        _bottomMaskImage = [[SSThemedImageView alloc] init];
        _bottomMaskImage.image = nil;
        [self.coverImageView addSubview:_bottomMaskImage];
    }
    return _bottomMaskImage;
}

- (SSThemedImageView *)ipIcon
{
    if (!_ipIcon) {
        _ipIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, KIPIconW, kIPIconH)];
        _ipIcon.imageName = @"feed_ip_icon";
        [self.bottomMaskImage addSubview:_ipIcon];
    }
    return _ipIcon;
}

- (TSVDebugInfoView *)debugInfoView
{
    if (!_debugInfoView) {
        _debugInfoView = [[TSVDebugInfoView alloc] init];
        _debugInfoView.hidden = YES;
    }

    return _debugInfoView;
}

- (SSThemedLabel *)locationLabel
{
    if (!_locationLabel) {
        _locationLabel = [[SSThemedLabel alloc] init];
        _locationLabel.textColorThemeKey = kColorText12;
        _locationLabel.backgroundColor = [UIColor clearColor];
        _locationLabel.font = [UIFont systemFontOfSize:12];
        [self.bottomMaskImage addSubview:_locationLabel];
    }
    return _locationLabel;
}

- (SSThemedImageView *)playBackgroundView
{
    if (!_playBackgroundView) {
        _playBackgroundView = [[SSThemedImageView alloc] init];
        UIImage * image = [UIImage themedImageNamed:@"message_background_view"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2 - 1, image.size.width / 2 - 1) resizingMode:UIImageResizingModeTile];
        _playBackgroundView.image = image;
        _playBackgroundView.frame = CGRectMake(0, 0, kPlayBackSide, kPlayBackSide);
        [self.bottomMaskImage addSubview:_playBackgroundView];
    }
    return _playBackgroundView;
}

- (SSThemedImageView *)playIcon
{
    if (!_playIcon) {
        _playIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kPlayIconW, kPlayIconH)];
        _playIcon.imageName = @"palyicon_video_textpage";
        [self.playBackgroundView addSubview:_playIcon];
    }
    return _playIcon;
}

- (SSThemedLabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        // 和字1一样，但是不提供disable色值，避免高亮
        _titleLabel.textColorThemeKey = kColorText15;
        _titleLabel.backgroundColorThemeKey = kColorBackground4;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColorThemeKey = kColorText3;
        _nameLabel.backgroundColorThemeKey = kColorBackground4;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont systemFontOfSize:kInfoLabelFontSize];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (SSThemedLabel *)infoLabel
{
    if(!_infoLabel){
        _infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _infoLabel.textColorThemeKey = kColorText3;
        _infoLabel.backgroundColorThemeKey = kColorBackground4;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _infoLabel.numberOfLines = 1;
        _infoLabel.font = [UIFont systemFontOfSize:kInfoLabelFontSize];
        [self.contentView addSubview:_infoLabel];
    }
    return _infoLabel;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.coverImageView.imageView.image = nil;
    self.ipIcon.hidden = YES;
    self.locationLabel.hidden = YES;
    self.locationLabel.text = @"";
    self.titleLabel.text = @"";
    self.infoLabel.text = @"";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshUI];
}

- (void)refreshUI
{
    self.coverImageView.width = self.width;
    self.coverImageView.height = ceilf(self.width * kCoverAspectRatio);
    self.coverImageView.left = 0;
    self.coverImageView.top = 0;
    
    self.bottomMaskImage.width = self.coverImageView.width;
    self.bottomMaskImage.height = ceilf(self.bottomMaskImage.width * kMaskAspectRatio);
    self.bottomMaskImage.bottom = self.coverImageView.height;
    self.bottomMaskImage.left = 0;
    
    self.ipIcon.left = kIPIconLeft;
    self.ipIcon.bottom = self.bottomMaskImage.height - kIPIconBottom;
    
    self.locationLabel.width = KLocationLabelFontSize * 7;
    self.locationLabel.height = kLocationLabelLineHeight;
    self.locationLabel.left = self.ipIcon.right + kLocationLabelLeft;
    self.locationLabel.centerY = self.ipIcon.centerY;
    
    self.playBackgroundView.right = self.coverImageView.width - kPlayBackRight;
    self.playBackgroundView.bottom = self.bottomMaskImage.height - kPlayBackBottom;
    
    self.playIcon.centerX = self.playBackgroundView.width / 2;
    self.playIcon.centerY = self.playBackgroundView.height / 2;
    
    CGFloat maxLabelWidth = 0.f;
    if (self.inScrollCard) {
        maxLabelWidth = [TTDeviceUIUtils tt_newPadding:137.f];
    } else {
        maxLabelWidth = self.width;
    }
    
    self.titleLabel.width = maxLabelWidth;
    self.titleLabel.height = kTitleLabelLineHeight;
    self.titleLabel.left = 0;
    self.titleLabel.top = self.coverImageView.bottom + kTitleLabelTop;
    
    if (isEmptyString(self.titleLabel.text)) {
        self.titleLabel.hidden = YES;
    } else {
        self.titleLabel.hidden = NO;
    }
    
    [self.nameLabel sizeToFit];
    [self.infoLabel sizeToFit];
    
    self.nameLabel.height = kInfoLabelLineHeight;
    self.infoLabel.height = kInfoLabelLineHeight;
    
    self.infoLabel.width = MIN(maxLabelWidth, self.infoLabel.width);
    if (isEmptyString(self.nameLabel.text)) {
        self.nameLabel.hidden = YES;
    } else {
        self.nameLabel.width = MIN(maxLabelWidth - self.infoLabel.width - 8, self.nameLabel.width);
        
        if (self.nameLabel.width < kInfoLabelFontSize) {
            self.nameLabel.hidden = YES;
        } else {
            self.nameLabel.hidden = NO;
        }
    }
    
    CGFloat infoTop = 0.f;
    if (self.titleLabel.hidden) {
        infoTop = self.coverImageView.bottom + kTitleLabelTop + (kTitleLabelLineHeight - kInfoLabelLineHeight) / 2.f;
    } else {
        infoTop = self.titleLabel.bottom + kInfoLabelTop;
    }
    
    if (self.nameLabel.hidden) {
        self.infoLabel.left = 0;
        self.infoLabel.top = infoTop;
    } else {
        self.nameLabel.left = 0;
        self.nameLabel.top = infoTop;
        
        self.infoLabel.left = self.nameLabel.right + 8.f;
        self.infoLabel.top = infoTop;
    }

    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        [self.contentView bringSubviewToFront:self.debugInfoView];
        self.debugInfoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 50);
        self.debugInfoView.hidden = NO;
    } else {
        self.debugInfoView.hidden = YES;
    }
}

@end



//
//  ExploreMomentListCellOriginArticleItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-19.
//
//  

#import "ExploreMomentListCellOriginArticleItemView.h"
#import "TTImageView.h"
#import "ArticleMomentGroupModel.h"
#import "ArticleMomentHelper.h"
#import "TTDeviceUIUtils.h"
#import "UIImage+TTThemeExtension.h"
#import "TTRoute.h"
#import "TTTabBarProvider.h"

#define kTopPadding         [TTDeviceUIUtils tt_paddingForMoment:10]
#define kBottomPadding 0

#define kIconWidth          [TTDeviceUIUtils tt_paddingForMoment:60]
#define kIconHeight         [TTDeviceUIUtils tt_paddingForMoment:60]
#define kIconTopPadding     0
#define kIconBottomPadding  0
#define kIconLeftPadding    0
#define kIconRightPadding   [TTDeviceUIUtils tt_paddingForMoment:10]

#define kTitleLableLeftPadding      0
#define kTitleLabelRightPadding     [TTDeviceUIUtils tt_paddingForMoment:10]

#define kTitlelLabelFontSize        [TTDeviceUIUtils tt_paddingForMoment:16.f]


@interface ExploreMomentListCellOriginArticleItemView()
@property(nonatomic, retain)UIView * bgView;
@property(nonatomic, retain)UILabel * titleLabel;
@property(nonatomic, retain)TTImageView * articleImageView;
@property(nonatomic, retain)UIImageView * videoIcon;
@property(nonatomic, assign)ExploreMomentListCellOriginArticleItemViewType itemViewType;
@property(nonatomic, retain)UITapGestureRecognizer * tapArticleViewGesture;
@property(nonatomic, retain)SSThemedView *leftLineView;
@property(nonatomic, retain)SSThemedView *rightLineView;
@property(nonatomic, retain)SSThemedView *topLineView;
@property(nonatomic, retain)SSThemedView *bottomLineView;
@end

@implementation ExploreMomentListCellOriginArticleItemView

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.titleLabel = nil;
    self.articleImageView = nil;
    self.videoIcon = nil;
    _tapArticleViewGesture.delegate = nil;
    [self.bgView removeGestureRecognizer:_tapArticleViewGesture];
    self.tapArticleViewGesture = nil;
    self.bgView = nil;
}

- (CGRect)_articleImageViewFrame
{
    return CGRectMake(kIconLeftPadding, kIconTopPadding, kIconWidth, kIconHeight);
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo itemViewType:(ExploreMomentListCellOriginArticleItemViewType)type
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.itemViewType = type;
        
        self.bgView = [[UIView alloc] initWithFrame:[self frameForBgView]];
        [self addSubview:_bgView];
        
        self.articleImageView = [[TTImageView alloc] initWithFrame:[self _articleImageViewFrame]];
        _articleImageView.userInteractionEnabled = NO;
        _articleImageView.clipsToBounds = YES;
        _articleImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        [self.bgView addSubview:_articleImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kTitlelLabelFontSize];
        _titleLabel.numberOfLines = 2;
        [self.bgView addSubview:_titleLabel];
        
        SSThemedView *leftLineView = [[SSThemedView alloc] init];
        leftLineView.backgroundColorThemeKey = kColorLine1;
        [self.bgView addSubview:leftLineView];
        self.leftLineView = leftLineView;
        
        SSThemedView *rightLineView = [[SSThemedView alloc] init];
        rightLineView.backgroundColorThemeKey = kColorLine1;
        [self.bgView addSubview:rightLineView];
        self.rightLineView = rightLineView;
        
        SSThemedView *topLineView = [[SSThemedView alloc] init];
        topLineView.backgroundColorThemeKey = kColorLine1;
        [self.bgView addSubview:topLineView];
        self.topLineView = topLineView;
        
        SSThemedView *bottomLineView = [[SSThemedView alloc] init];
        bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self.bgView addSubview:bottomLineView];
        self.bottomLineView = bottomLineView;
        
        [self.bgView bringSubviewToFront:_titleLabel];
        
        self.tapArticleViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnce:)];
        _tapArticleViewGesture.numberOfTapsRequired = 1;
        [self.bgView addGestureRecognizer:_tapArticleViewGesture];


        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText2];
    
    [self setBackgroundColorWhenPressed:NO];
    _articleImageView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"eeeeee" nightColorName:@"505050"]];
    if (!self.hasImage) {
        if ([self isEssay]) {
            [self.articleImageView setImage:[UIImage themedImageNamed:@"neihan_dynamic.png"]];
        }
        else{
            [self.articleImageView setImage:[UIImage themedImageNamed:@"urlicon_loadingpicture_dynamic.png"]];
        }
    }
    if (self.hasVideo) {
        [self.videoIcon setImage:[UIImage themedImageNamed:@"u11_play.png"]];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgView.frame = [self frameForBgView];
    [self _settingTitleLabelFrame];
    [self _settingSepLineFrame];
}

- (void)setBackgroundColorWhenPressed:(BOOL)pressed
{
    if (pressed)
    {
        if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeForward) {
            self.bgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground10Highlighted];
        }
        else {
            self.bgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3Highlighted];
        }

    }
    else
    {
        if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeForward) {
            self.bgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        }
        else {
            self.bgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        }
    }
}

- (void)_settingTitleLabelFrame
{
    _titleLabel.frame =  CGRectMake(CGRectGetMaxX(_articleImageView.frame) + kIconRightPadding + kTitleLableLeftPadding,
                      (_articleImageView.bottom),
                      (_bgView.width) - CGRectGetMaxX(_articleImageView.frame) - kIconRightPadding - kTitleLableLeftPadding - kTitleLabelRightPadding,
                      (_bgView.height) - kIconTopPadding - kIconBottomPadding);
    [_titleLabel sizeToFit];
    _titleLabel.top = ((_articleImageView.top) + (_articleImageView.height) - (_titleLabel.height)) / 2;
}

- (void)_settingSepLineFrame
{
    _leftLineView.frame = CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], (_bgView.height));
    _rightLineView.frame = CGRectMake((_bgView.width) - [TTDeviceHelper ssOnePixel], 0, [TTDeviceHelper ssOnePixel], (_bgView.height));
    _topLineView.frame = CGRectMake([TTDeviceHelper ssOnePixel], 0, (_bgView.width) - 2 * [TTDeviceHelper ssOnePixel], [TTDeviceHelper ssOnePixel]);
    _bottomLineView.frame = CGRectMake([TTDeviceHelper ssOnePixel], (_bgView.height) - [TTDeviceHelper ssOnePixel], (_bgView.width) - 2 * [TTDeviceHelper ssOnePixel], [TTDeviceHelper ssOnePixel]);
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    
    self.bgView.frame = [self frameForBgView];
    _articleImageView.frame = CGRectMake(kIconLeftPadding, kIconTopPadding, kIconWidth, kIconHeight);
    _titleLabel.font = [UIFont systemFontOfSize:kTitlelLabelFontSize];
    NSString * URLString = nil;
    if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeMoment) {
        URLString = model.group.thumbnailURLString;
    }
    else if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeForward) {
        URLString = model.originItem.group.thumbnailURLString;
    }
    _articleImageView.hidden = NO;
    if (isEmptyString(URLString)) {
        if (model.group.groupType == ArticleMomentGroupEssay) {
            [_articleImageView setImage:[UIImage themedImageNamed:@"neihan_dynamic.png"]];
        }
        else{
            [_articleImageView setImage:[UIImage themedImageNamed:@"urlicon_loadingpicture_dynamic.png"]];
        }
    }
    else {
        [_articleImageView setImageWithURLString:URLString];
    }
    if ([self hasVideo] && !isEmptyString(URLString)) {
        if (!_videoIcon) {
            _videoIcon = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"u11_play"]];
            [self.bgView addSubview:_videoIcon];
            _videoIcon.center = _articleImageView.center;
        }
        _videoIcon.hidden = NO;
    }
    else
    {
        if(_videoIcon) {
            _videoIcon.hidden = YES;
        }
    }
    
    if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeMoment) {
        [_titleLabel setText:model.group.title];
    }
    else if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeForward) {
        [_titleLabel setText:model.originItem.group.title];
    }
    [self _settingTitleLabelFrame];
    [self _settingSepLineFrame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setBackgroundColorWhenPressed:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setBackgroundColorWhenPressed:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setBackgroundColorWhenPressed:NO];
}


- (BOOL)hasImage
{
    if (!isEmptyString(self.momentModel.group.thumbnailURLString)) {
        return YES;
    }
    return NO;
}

- (BOOL)isEssay
{
    if (self.momentModel.group.groupType == ArticleMomentGroupEssay) {
        return YES;
    }
    return NO;
}

- (BOOL)hasVideo
{
    if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeMoment) {
        return self.momentModel.group.mediaType == ArticleWithVideo ? YES : NO;
    }
    else if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeForward) {
        return self.momentModel.originItem.group.mediaType == ArticleWithVideo ? YES : NO;
    }
    return NO;
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellOriginArticleItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo itemViewType:_itemViewType];
}

- (void)handleTapOnce:(UITapGestureRecognizer *)recognizer
{
    if (self.momentModel.group.openURL){
        NSURL *url = [[NSURL alloc] initWithString:self.momentModel.group.openURL];
        if ([[TTRoute sharedRoute] canOpenURL:url]){
            [[TTRoute sharedRoute] openURLByPushViewController:url];
            return;
        }
    }
    
    if(recognizer == _tapArticleViewGesture) {
        if (self.itemViewType == ExploreMomentListCellOriginArticleItemViewTypeMoment) {
            if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
                NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                [extra setValue:self.momentModel.ID forKey:@"item_id"];
                [extra setValue:self.momentModel.group.ID forKey:@"value"];
                [TTTrackerWrapper event:@"micronews_tab" label:@"quote" value:nil extValue:nil extValue2:nil dict:[extra copy]];
            }
            [ArticleMomentHelper openGroupDetailView:self.momentModel goDetailFromSource:_goDetailFromSource];
        }
        else {
            if (self.sourceType == ArticleMomentSourceTypeMoment && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
                NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                [extra setValue:self.momentModel.ID forKey:@"item_id"];
                [extra setValue:self.momentModel.group.ID forKey:@"value"];
                [TTTrackerWrapper event:@"micronews_tab" label:@"quote" value:nil extValue:nil extValue2:nil dict:[extra copy]];
            }
            [ArticleMomentHelper openGroupDetailView:self.momentModel.originItem goDetailFromSource:_goDetailFromSource];
        }
    }
}


+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model
                      cellWidth:(CGFloat)cellWidth
                       userInfo:(NSDictionary *)uInfo
                   itemViewType:(ExploreMomentListCellOriginArticleItemViewType)type
{
    if (![self needShowForModel:model userInfo:uInfo itemViewType:type]) {
        return 0;
    }
    if (type == ExploreMomentListCellOriginArticleItemViewTypeMoment) {
        return kTopPadding + kIconTopPadding + kIconHeight + kIconBottomPadding + kBottomPadding;
    }
    else if (type == ExploreMomentListCellOriginArticleItemViewTypeForward) {
        return kIconTopPadding + kIconHeight + kIconBottomPadding;
    }
    return 0;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model
                userInfo:(NSDictionary *)uInfo
            itemViewType:(ExploreMomentListCellOriginArticleItemViewType)type
{
    ArticleMomentSourceType sourceType = [[uInfo objectForKey:kMomentListCellItemBaseUserInfoSourceTypeKey] intValue];
    if (sourceType == ArticleMomentSourceTypeArticleDetail || sourceType == ArticleMomentSourceTypeThread) {
        return NO;
    }
    if (type == ExploreMomentListCellOriginArticleItemViewTypeMoment) {
        if (!isEmptyString(model.group.title) && [model.group.ID longLongValue] != 0) {
            return YES;
        }
    }
    else if (type == ExploreMomentListCellOriginArticleItemViewTypeForward) {
        if (model.originItem.isDeleted) {
            return NO;
        }
        if (!isEmptyString(model.originItem.group.title) && [model.originItem.group.ID longLongValue] != 0) {
            return YES;
        }
    }
    return NO;
}

- (CGRect)frameForBgView
{
    if (_itemViewType == ExploreMomentListCellOriginArticleItemViewTypeForward) {
        return CGRectMake(0,
                          0,
                          self.width,
                          kIconHeight + kIconTopPadding + kIconBottomPadding);
    }
    return CGRectMake(kMomentCellItemViewLeftPadding,
                      kTopPadding,
                        self.width - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding,
                      kIconHeight + kIconTopPadding + kIconBottomPadding);
}

@end

//
//  TTHTSWaterfallCollectionViewCell.m
//  Article
//
//  Created by 王双华 on 2017/4/13.
//
//

#import "TTHTSWaterfallCollectionViewCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVShortVideoOriginalData.h"
#import "UIImageView+TTCornerRadius.h"
#import "TTAsyncCornerImageView.h"
#import "TTBusinessManager.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TTArticleCellHelper.h"
#import <TTBaseLib/TTLabelTextHelper.h>
#import "TTFeedDislikeView.h"
#import "SSUserSettingManager.h"
#import "NewsUserSettingManager.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import "TTHTSTrackerHelper.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTFeedDislikeView.h"
#import "TTPlatformSwitcher.h"
#import "NSObject+FBKVOController.h"
#import <HTSVideoPlay/TSVAnimatedImageView.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "AWEVideoConstants.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "TTModuleBridge.h"
#import "TSVWaterfallCollectionViewCellHelper.h"
#import "TSVTagInfoView.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTAccountManager.h"
#import "TTRichSpanText.h"
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText+Link.h"
#import "TTRichSpanText+Emoji.h"
#import "TTUGCEmojiParser.h"
#import <TTRoute/TTRoute.h>
#import <TSVDebugInfoView.h>
#import <TSVDebugInfoConfig.h>
#import <HTSVideoSwitch.h>
#import "HuoShan.h"

#define kIconH 16
#define kDislikeH  12

static NSInteger const kTitleLabelNumberOfLines = 2;

@interface TTHTSWaterfallCollectionViewCell ()

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) UIView<TSVImageViewProtocol> *imageView;
@property (nonatomic, strong) SSThemedImageView *bottomMaskImage;
@property (nonatomic, strong) SSThemedButton *unInterestedButton;
@property (nonatomic, strong) TTUGCAttributedLabel *titleLabel;

@property (nonatomic, strong) SSThemedImageView *playIcon;
@property (nonatomic, strong) SSThemedLabel *leftInfoLabel;
@property (nonatomic, strong) SSThemedLabel *rightInfoLabel;
@property (nonatomic, strong) TSVDebugInfoView *debugInfoView;
@property (nonatomic, strong) TTAsyncCornerImageView *avatar;

@property (nonatomic, strong) TSVTagInfoView *tagInfoView;
@property (nonatomic, strong) TSVTagInfoView *activityTag;

@end

@implementation TTHTSWaterfallCollectionViewCell
@synthesize dislikeBlock;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
             [self updateAttributeTitleWithModel:self.orderedData.shortVideoOriginalData.shortVideo richTextTrimmingHashTags:!self.activityTag.hidden];
         }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kSettingFontSizeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             [self refreshUI];
         }];
        
        [[[[[RACSignal combineLatest:@[RACObserve(self, orderedData.shortVideoOriginalData.shortVideo.commentCount),
                                       RACObserve(self, orderedData.shortVideoOriginalData.shortVideo.diggCount),
                                       RACObserve(self, orderedData.shortVideoOriginalData.shortVideo.playCount),]]
            distinctUntilChanged]
           takeUntil:[self rac_willDeallocSignal]]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self refreshData];
         }];

        [self.contentView addSubview:self.debugInfoView];
    }
    return self;
}

- (UIView<TSVImageViewProtocol> *)imageView {
    if (!_imageView) {
        if ([self animatedCoverEnabled]) {
            _imageView = [[TSVAnimatedImageView alloc] initWithFrame:self.bounds];
        } else {
            _imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        }
        _imageView.backgroundColorThemeKey = kColorBackground3;
        _imageView.imageContentMode = TTImageViewContentModeScaleAspectFillRemainTop;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (SSThemedImageView *)bottomMaskImage {
    if (!_bottomMaskImage) {
        _bottomMaskImage = [[SSThemedImageView alloc] init];
        [self.contentView addSubview:_bottomMaskImage];
    }
    return _bottomMaskImage;
}

- (SSThemedLabel *)rightInfoLabel {
    if (!_rightInfoLabel) {
        _rightInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _rightInfoLabel.textColorThemeKey = kColorText10;
        _rightInfoLabel.backgroundColor = [UIColor clearColor];
        _rightInfoLabel.font = [UIFont tt_fontOfSize:12];
        _rightInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _rightInfoLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_rightInfoLabel];
    }
    return _rightInfoLabel;
}

- (TTUGCAttributedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = kTitleLabelNumberOfLines;
        _titleLabel.font = [UIFont boldSystemFontOfSize:[TSVWaterfallCollectionViewCellHelper titleFontSize]];
        _titleLabel.extendsLinkTouchArea = NO;
        _titleLabel.longPressGestureRecognizer.enabled = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedButton *)unInterestedButton
{
    if (!_unInterestedButton) {
        _unInterestedButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kDislikeH, kDislikeH)];
        _unInterestedButton.imageName = @"hs_dislike";
//        _unInterestedButton.imageColorThemeKey = kColorText10;
        [_unInterestedButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_unInterestedButton];
    }
    return _unInterestedButton;
}

- (TSVTagInfoView *)tagInfoView
{
    if (!_tagInfoView) {
        _tagInfoView = [[TSVTagInfoView alloc] initWithNightThemeEnabled:YES];
        [self.contentView addSubview:_tagInfoView];
    }
    return _tagInfoView;
}

- (TSVTagInfoView *)activityTag
{
    if (!_activityTag) {
        _activityTag = [[TSVTagInfoView alloc] initWithNightThemeEnabled:YES];
        _activityTag.style = TSVTagInfoViewStyleActivity;
        [self.contentView addSubview:_activityTag];
    }
    return _activityTag;
}

- (SSThemedImageView *)playIcon
{
    if (!_playIcon) {
        _playIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kIconH, kIconH)];
        _playIcon.backgroundColor = [UIColor clearColor];
        _playIcon.imageName = @"ugc_video_list_play";
        [self.contentView addSubview:_playIcon];
    }
    return _playIcon;
}

- (SSThemedLabel *)leftInfoLabel
{
    if (!_leftInfoLabel) {
        _leftInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _leftInfoLabel.textColorThemeKey = kColorText10;
        _leftInfoLabel.backgroundColor = [UIColor clearColor];
        _leftInfoLabel.font = [UIFont tt_fontOfSize:12];
        _leftInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _leftInfoLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_leftInfoLabel];
    }
    return _leftInfoLabel;
}

- (TTAsyncCornerImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20) allowCorner:YES];
        _avatar.cornerRadius = 10;
        _avatar.borderWidth = 0;
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (TSVDebugInfoView *)debugInfoView
{
    if (!_debugInfoView) {
        _debugInfoView = [[TSVDebugInfoView alloc] init];
    }

    return _debugInfoView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [UIView performWithoutAnimation:^{
        [self refreshUI];
    }];
}

- (ExploreOrderedData *)cellData {
    return self.orderedData;
}

- (void)refreshWithData:(ExploreOrderedData *)data {
    self.orderedData = data;
    
    [self refreshData];
}

- (void)refreshData
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self updatePic];
    
    self.bottomMaskImage.imageName = @"hs_gradient";
    
    TTShortVideoModel *model = self.orderedData.shortVideoOriginalData.shortVideo;

    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        self.debugInfoView.debugInfo = model.debugInfo;
        [self.contentView bringSubviewToFront:self.debugInfoView];
        self.debugInfoView.hidden = NO;
    } else {
        self.debugInfoView.hidden = YES;
    }

    NSInteger cellUIType = [self cellUIType];
    
    switch (cellUIType) {
        case TTHTSWaterfallCollectionCellUITypeNone://播放icon、播放数、点赞数
        {
            self.leftInfoLabel.text = [NSString stringWithFormat:@"%@次播放", [TTBusinessManager formatCommentCount:model.playCount]];
            NSString *diggCountStr = [TTBusinessManager formatCommentCount:model.diggCount];
            if ([self.orderedData.categoryID isEqualToString:@"ugc_video_local"]) {
                self.rightInfoLabel.text = model.distance;
            } else {
                self.rightInfoLabel.text = [NSString stringWithFormat:@"%@赞",diggCountStr];
            }
            if (!isEmptyString(model.labelForList)) {
                self.tagInfoView.hidden = NO;
                [self.tagInfoView refreshTagWithText:model.labelForList];
                self.tagInfoView.style = TSVTagInfoViewStyleDefault;
            } else {
                self.tagInfoView.hidden = YES;
            }
        }
            break;
        case TTHTSWaterfallCollectionCellUITypeRelationship:
        {
            [self.avatar tt_setImageWithURLString:model.author.avatarURL];
            self.leftInfoLabel.text = model.author.name;
            NSString *diggCountStr = [TTBusinessManager formatCommentCount:model.diggCount];
            if ([self.orderedData.categoryID isEqualToString:@"ugc_video_local"]) {
                self.rightInfoLabel.text = model.distance;
            } else {
                self.rightInfoLabel.text = [NSString stringWithFormat:@"%@赞",diggCountStr];
            }
            
            self.tagInfoView.hidden = NO;
            [self.tagInfoView refreshTagWithText:model.labelForList];
            self.tagInfoView.style = TSVTagInfoViewStyleRelationship;
        }
            break;
    }
    
    if (!isEmptyString(model.activity.name) && model.activity.showOnList && ![HTSVideoSwitch shouldHideActivityTag]) {
        self.activityTag.hidden = NO;
        [self.activityTag refreshTagWithText:model.activity.name];
    } else {
        self.activityTag.hidden = YES;
    }
    [self updateAttributeTitleWithModel:model richTextTrimmingHashTags:!self.activityTag.hidden];
    
    [self.leftInfoLabel sizeToFit];
    [self.rightInfoLabel sizeToFit];
    
    self.unInterestedButton.hidden = [model isAuthorMyself];
    
    [self setNeedsLayout];

    [CATransaction commit];
}

- (void)refreshUI {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.imageView.frame = CGRectMake(0, 0, self.width, self.height);
    
    self.bottomMaskImage.width = self.width;
    self.bottomMaskImage.height = self.width * 130 / 187;//阴影宽高比 187 : 130
    self.bottomMaskImage.left = 0;
    self.bottomMaskImage.bottom = self.height;
    
    self.unInterestedButton.right = self.width - 8;
    self.unInterestedButton.top = 8;
    
    CGFloat titleWidth = self.width - 8 * 2;
    CGSize titleRichLabelRealSize = [TTUGCAttributedLabel sizeThatFitsAttributedString:self.titleLabel.attributedText withConstraints:CGSizeMake(titleWidth, FLT_MAX) limitedToNumberOfLines:kTitleLabelNumberOfLines];
    self.titleLabel.frame = CGRectMake(8, 0, titleWidth, titleRichLabelRealSize.height);
    
    NSInteger cellUIType = [self cellUIType];

    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        self.debugInfoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 80);
    }
    
    if (cellUIType == TTHTSWaterfallCollectionCellUITypeRelationship) {
        self.avatar.hidden = NO;
        self.playIcon.hidden = YES;
        
        self.avatar.left = 8;
        self.avatar.bottom = self.height - 6;
        
        CGFloat centerY = self.avatar.centerY;
        
        self.rightInfoLabel.right = self.width - 8;
        self.rightInfoLabel.centerY = centerY;
        
        CGFloat leftInfoLabelMaxWidth = self.width - 8 - self.avatar.width - 6 - 6 - self.rightInfoLabel.width - 8;
        self.leftInfoLabel.left = self.avatar.right + 6;
        self.leftInfoLabel.centerY = centerY;
        self.leftInfoLabel.width = MIN(self.leftInfoLabel.width, leftInfoLabelMaxWidth);
        
        self.titleLabel.bottom = self.avatar.top - 5;
        
        CGFloat tagInfoViewWidth = MIN([self.tagInfoView originalContainerWidth], self.width - 8 * 2);
        self.tagInfoView.width = tagInfoViewWidth;
        self.tagInfoView.height = 20;
        self.tagInfoView.left = 8;
        CGFloat bottom;
        if (self.titleLabel.attributedText.length == 0) {
            bottom = self.avatar.top - 5;
        } else {
            bottom = self.titleLabel.top - 5;
        }
        if (!self.activityTag.hidden) {
            CGFloat activityTagWidth = MIN([self.activityTag originalContainerWidth], self.width - 8 * 2);
            self.activityTag.width = activityTagWidth;
            self.activityTag.height = 20;
            self.activityTag.left = 8;
            self.activityTag.bottom = bottom;
            bottom = self.activityTag.top - 6;
        }
        self.tagInfoView.bottom = bottom;
    } else {
        self.playIcon.hidden = NO;
        self.avatar.hidden = YES;
        
        self.playIcon.left = 8;
        self.playIcon.bottom = self.height - 8;
        
        CGFloat centerY = self.playIcon.centerY;
        
        self.titleLabel.bottom = self.playIcon.top - 5;
        
        CGFloat tagInfoViewWidth = MIN([self.tagInfoView originalContainerWidth], [[TSVTagInfoView class] maxContainerWidth]);
        self.tagInfoView.width = tagInfoViewWidth;
        self.tagInfoView.height = 20;
        self.tagInfoView.left = 8;
        CGFloat bottom;
        if (self.titleLabel.attributedText.length == 0) {
            bottom = self.playIcon.top - 5;
        } else {
            bottom = self.titleLabel.top - 5;
        }
        if (!self.activityTag.hidden) {
            CGFloat activityTagWidth = MIN([self.activityTag originalContainerWidth], self.width - 8 * 2);
            self.activityTag.width = activityTagWidth;
            self.activityTag.height = 20;
            self.activityTag.left = 8;
            self.activityTag.bottom = bottom;
            bottom = self.activityTag.top - 6;
        }
        self.tagInfoView.bottom = bottom;
        
        self.leftInfoLabel.left = self.playIcon.right + 4;
        self.leftInfoLabel.centerY = centerY;
        
        self.rightInfoLabel.right = self.width - 8;
        self.rightInfoLabel.centerY = centerY;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.avatar.hidden = YES;
    self.playIcon.hidden = YES;
}

- (BOOL)animatedCoverEnabled
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_animated_cover_image" defaultValue:@0 freeze:YES] boolValue];
}

- (void)updatePic {
    if ([self animatedCoverEnabled] &&
        self.orderedData.shortVideoOriginalData.shortVideo.animatedImageModel &&
        TTNetworkWifiConnected()) {
        @weakify(self);
        [self.imageView tsv_setImageWithModel:self.orderedData.shortVideoOriginalData.shortVideo.animatedImageModel
                             placeholderImage:nil
                                      options:0
                              isAnimatedImage:YES
                                      success:nil
                                      failure:^(NSError *error) {
                                          @strongify(self);
                                          [self.imageView tsv_setImageWithModel:self.orderedData.shortVideoOriginalData.shortVideo.detailCoverImageModel
                                              placeholderImage:nil];
                                      }];
    } else {
        [self.imageView tsv_setImageWithModel:self.orderedData.shortVideoOriginalData.shortVideo.detailCoverImageModel
                             placeholderImage:nil
                                      options:0
                              isAnimatedImage:NO
                                      success:nil
                                      failure:nil];
    }
}

- (NSDictionary *)titleLabelAttributedDictionary
{
    NSMutableDictionary * attributeDictionary = @{}.mutableCopy;
    UIFont *fontSize = [UIFont boldSystemFontOfSize:[TSVWaterfallCollectionViewCellHelper titleFontSize]];
    CGFloat lineHeight = [TSVWaterfallCollectionViewCellHelper titleLineHeight];
    [attributeDictionary setValue:fontSize forKey:NSFontAttributeName];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineHeightMultiple = lineHeight / fontSize.lineHeight;
    
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [attributeDictionary setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributeDictionary setValue:[UIColor tt_themedColorForKey:kColorText10] forKey:NSForegroundColorAttributeName];
    return attributeDictionary.copy;
}

- (void)updateAttributeTitleWithModel:(TTShortVideoModel *)model richTextTrimmingHashTags:(BOOL)trimmingHashTags
{
    NSString *titleStr = model.title;
    if (isEmptyString(titleStr)) {
        self.titleLabel.attributedText = nil;
        return;
    }
    TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:model.titleRichSpanJSONString];
    TTRichSpanText *richTitle = [[TTRichSpanText alloc] initWithText:titleStr richSpans:richSpans];
    if (trimmingHashTags && !isEmptyString(model.activity.name)) {
        NSRange subStrRange = [titleStr rangeOfString:model.activity.name];
        if (subStrRange.location != NSNotFound) {
            NSInteger startIndex = subStrRange.location - 1;
            [richTitle trimmingHashtagsWithStartIndex:startIndex];
        }
    }
    
    TTRichSpanText *titleRichSpanText = [richTitle replaceWhitelistLinks];
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:titleRichSpanText.text fontSize:[TSVWaterfallCollectionViewCellHelper titleFontSize]];
    
    NSDictionary *attrDic = [self titleLabelAttributedDictionary];
    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
    [mutableAttributedString addAttributes:attrDic range:NSMakeRange(0, attrStr.length)];
    [self.titleLabel setText:[mutableAttributedString copy]];
}

#pragma mark - unInterestButton action
- (void)unInterestButtonClicked:(id)sender
{
    [TTHTSTrackerHelper trackUnInterestButtonClickedWithExploreOrderData:self.orderedData extraParams:[self trackParamsDict]];
    [TTFeedDislikeView dismissIfVisible];
    [self showMenu];
}

- (void)showMenu
{
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    // add by zjing 添加不感兴趣
    viewModel.keywords = self.orderedData.shortVideoOriginalData.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.originalData.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _unInterestedButton.center;
    [dislikeView showAtPoint:point
                    fromView:_unInterestedButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (!self.orderedData) {
        return;
    }
    else {
        [TTHTSTrackerHelper trackDislikeViewOKBtnClickedWithExploreOrderData:self.orderedData extraParams:[self trackParamsDict]];
        if (self.dislikeBlock){
            self.dislikeBlock();
        }
    }
}

#pragma mark - helper

- (NSDictionary *)trackParamsDict
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.orderedData.categoryID forKey:@"category_name"];
    [params setValue:@"click_category" forKey:@"enter_from"];
    return params;
}

- (TTHTSWaterfallCollectionCellUIType)cellUIType
{
    if (!isEmptyString(self.orderedData.shortVideoOriginalData.shortVideo.labelForList)) {
        NSInteger layoutStyle = 0;
        
        if (self.orderedData.cellCtrls && [self.orderedData.cellCtrls isKindOfClass:[NSDictionary class]]) {
            layoutStyle = [self.orderedData.cellCtrls tt_integerValueForKey:@"cell_layout_style"];
        }
        
        if (layoutStyle == 14) {
            return TTHTSWaterfallCollectionCellUITypeRelationship;
        }
    }
    
    return TTHTSWaterfallCollectionCellUITypeNone;
}

@end

//
//  ExploreListCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "ExploreArticleCellView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "ExploreOriginalData.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreMixListDefine.h"
#import "ExploreCellHelper.h"
#import "TTLabelTextHelper.h"

#import "ExploreListHelper.h"
#import "TTArticleCategoryManager.h"
#import "TTImageView.h"
#import "ExploreArticleCellEntityWords.h"

#import "DetailActionRequestManager.h"

#import "TTInstallIDManager.h"

#import "TTAlphaThemedButton.h"
#import "TTNavigationController.h"
#import "TTUISettingHelper.h"
#import "NSObject+FBKVOController.h"
#import "TTDeviceUIUtils.h"
#import "TTThemeManager.h"
#import "TTBusinessManager+StringUtils.h"

#import "TTArticleCellHelper.h"
#import "TTActivityShareManager.h"
#import "UIImage+TTThemeExtension.h"
#import "TTLayOutCellDataHelper.h"
#import "TTFeedCellDefaultSelectHandler.h"
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"

#import <TTAccountBusiness.h>
#import "ExploreOrderedData+TTAd.h"

@interface ExploreArticleCellView ()
@property(nonatomic,assign)BOOL isViewHighlighted; // 优化：系统prepareforCell时会调用setHighlighted:NO，setSelected:NO，函数中代码会在列表滚动时调用，记录此变量避免不必要的调用

///...
@property (nonatomic, strong) TTArticleCellEntityWordView *entityWordView; // 实体词

@end

@implementation ExploreArticleCellView

- (void)dealloc
{
    self.orderedData = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReadModeChangeNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [self setLabelsColorClear:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readModeChanged:) name:kReadModeChangeNotification object:nil];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
}

- (void)setOrderedData:(ExploreOrderedData *)orderedData
{
    [self removeKVO];
    _orderedData = orderedData;
    _originalData = orderedData.originalData;
    [self addKVO];
}

- (id)cellData
{
    return self.orderedData;
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    
    _bottomLineView.backgroundColor = [UIColor tt_themedColorForKey:kCellBottomLineColor];
    
    [_unInterestedButton setImage:[UIImage themedImageNamed:@"add_textpage.png"] forState:UIControlStateNormal];
    
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    [self setLabelsColorClear:NO];
    
    _infoLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
    _sourceLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
    
    _liveTextLabel.textColor = SSGetThemedColorWithKey(kColorText8);
    _liveTextLabel.backgroundColor = SSGetThemedColorWithKey(kColorBackground15);
    
    _titleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    _titleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    
    [self updateTypeLabel];
    
    [self updateContentColor];
}

- (void)fontSizeChanged
{
    _titleLabel.font = [UIFont systemFontOfSize:kCellTitleLabelFontSize];
    _titleLabel.lineHeight = kCellTitleLineHeight;
    _abstractLabel.font = [UIFont systemFontOfSize:kCellAbstractViewFontSize];
    _infoLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
    _sourceLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
    [self refreshUI];
}

- (void)readModeChanged:(NSNotification*)notification
{
    [self updateAbstract];
    [self refreshUI];
}

- (TTLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[TTLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
        _titleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
        _titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _titleLabel.numberOfLines = kCellTitleLabelMaxLine;
        _titleLabel.lineHeight = kCellTitleLineHeight;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)sourceLabel
{
    if (!_sourceLabel) {
        _sourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _sourceLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
        _sourceLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
        _sourceLabel.clipsToBounds = YES;
        [self.infoBarView addSubview:_sourceLabel];
    }
    return _sourceLabel;
}

- (UILabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _infoLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
        _infoLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
        _infoLabel.clipsToBounds = YES;
        [self.infoBarView addSubview:_infoLabel];
    }
    return _infoLabel;
}

- (UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.textAlignment  = NSTextAlignmentCenter;
        _typeLabel.font = [UIFont systemFontOfSize:kCellTypeLabelFontSize];
        _typeLabel.layer.cornerRadius = kCellTypeLabelCornerRadius;
        _typeLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _typeLabel.clipsToBounds = YES;
        [self.infoBarView addSubview:_typeLabel];
    }
    return _typeLabel;
}

- (UILabel *)abstractLabel
{
    if (!_abstractLabel) {
        _abstractLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _abstractLabel.numberOfLines = 0;
        _abstractLabel.font = [UIFont systemFontOfSize:kCellAbstractViewFontSize];
        _abstractLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _abstractLabel.clipsToBounds = YES;
        [self addSubview:_abstractLabel];
    }
    return _abstractLabel;
}

- (void)removeAbstractLabel {
    if (_abstractLabel.superview) {
        [_abstractLabel removeFromSuperview];
    }
}

- (UIView *)bottomLineView
{
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(kCellLeftPadding,  self.frame.size.height-[TTDeviceHelper ssOnePixel], self.frame.size.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel])];
        _bottomLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];;
        [self addSubview:_bottomLineView];
    }
    
    return _bottomLineView;
}

- (UIButton *)unInterestedButton
{
    if (self.listType == ExploreOrderedDataListTypeFavorite ||
        self.listType == ExploreOrderedDataListTypeReadHistory ||
        self.listType == ExploreOrderedDataListTypePushHistory ||
        self.hideUnInerestedButton ||
        (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue]) ||
        ([self.orderedData.article isVideoSourceUGCVideo] && !isEmptyString([[self.orderedData.article userInfo] tt_stringValueForKey:@"user_id"]) && [[[self.orderedData.article userInfo] tt_stringValueForKey:@"user_id"] isEqualToString:[TTAccountManager userID]])) {
        if (_unInterestedButton) {
            [_unInterestedButton removeFromSuperview];
            _unInterestedButton = nil;
        }
        return nil;
    }
    
    if (!_unInterestedButton) {
        _unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [_unInterestedButton setImage:[UIImage themedImageNamed:@"add_textpage.png"] forState:UIControlStateNormal];
        
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_unInterestedButton];
    }
    return _unInterestedButton;
}

// 荐/热
- (TTImageView *)logoIcon
{
    if (!_logoIcon) {
        _logoIcon = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        _logoIcon.imageContentMode = TTImageViewContentModeScaleAspectFit;
        _logoIcon.backgroundColor = [UIColor clearColor];
        _logoIcon.enableNightCover = NO;
        [self.infoBarView addSubview:_logoIcon];
    }
    return _logoIcon;
}

- (TTArticlePicView *)picView {
    if (!_picView) {
        _picView = [[TTArticlePicView alloc] initWithStyle: TTArticlePicViewStyleNone];
        [self addSubview:_picView];
    }
    return _picView;
}

- (UILabel *)liveTextLabel
{
    if (!_liveTextLabel) {
        _liveTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kCellPicLabelWidth, kCellPicLabelHeight)];
        _liveTextLabel.text = @"直播";
        _liveTextLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10]];
        _liveTextLabel.textColor = SSGetThemedColorWithKey(kCellPicLabelTextColor);
        _liveTextLabel.backgroundColor = SSGetThemedColorWithKey(kCellPicLabelBackgroundColor);
        _liveTextLabel.textAlignment = NSTextAlignmentCenter;
        _liveTextLabel.layer.cornerRadius = kCellPicLabelCornerRadius;
        _liveTextLabel.clipsToBounds = YES;
        _liveTextLabel.hidden = YES;
        
        SSThemedView *redDot = [[SSThemedView alloc] initWithFrame:CGRectMake(6, _liveTextLabel.height/2 - 3, 6, 6)];
        redDot.backgroundColorThemeKey = kColorText4;
        redDot.layer.cornerRadius = 3;
        [_liveTextLabel addSubview:redDot];
        
        _liveTextLabel.contentInset = UIEdgeInsetsMake(0,3, 0, 0);
        _liveTextLabel.right = self.picView.width - 6;
        _liveTextLabel.bottom = self.picView.height - 6;
        _liveTextLabel.hidden = YES;
        [self.picView addSubview:self.liveTextLabel];
        
        
    }
    return _liveTextLabel;
}


- (ExploreArticleCellCommentView *)commentView
{
    if (!_commentView) {
        _commentView = [[ExploreArticleCellCommentView alloc] initWithFrame:CGRectZero];
        _commentView.delegate = self;
        [self addSubview:_commentView];
        [self sendSubviewToBack:_commentView];
    }
    return _commentView;
}

- (void)removeCommentView
{
    if (_commentView.superview) {
        _commentView.delegate = nil;
        [_commentView removeFromSuperview];
    }
}

- (UIView *)infoBarView {
    if (!_infoBarView) {
        _infoBarView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_infoBarView];
    }
    return _infoBarView;
}

///...
- (TTArticleCellEntityWordView *)entityWordView
{
    if (!_entityWordView) {
        _entityWordView = [[TTArticleCellEntityWordView alloc] initWithFrame:CGRectZero];
        [self addSubview:_entityWordView];
    }
    return _entityWordView;
}

#pragma mark - unInterestButton action
- (void)unInterestButtonClicked:(id)sender
{
    [self showMenu];
}

- (void)showMenu
{
    [TTFeedDislikeView dismissIfVisible];
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.article.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.unInterestedButton.center;
    [dislikeView showAtPoint:point
                    fromView:self.unInterestedButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted)
    {
        if (!self.isViewHighlighted) {
            [self setLabelsColorClear:YES];
            self.backgroundColor = [TTUISettingHelper cellViewHighlightedBackgroundColor];
            [_commentView updateContentWithHighlightColor];
            self.isViewHighlighted = YES;
        }
    }
    else
    {
        if (self.isViewHighlighted) {
            [self setLabelsColorClear:NO];
            self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
            [_commentView updateContentWithNormalColor];
            self.isViewHighlighted = NO;
        }
    }
}

- (void)setLabelsColorClear:(BOOL)clear
{
    UIColor *color;
    
    if (clear) {
        color = [UIColor clearColor];
    } else {
        color = [TTUISettingHelper cellViewBackgroundColor];
    }
    
    _titleLabel.backgroundColor = color;
    _sourceLabel.backgroundColor = color;
    _infoLabel.backgroundColor = color;
    _typeLabel.backgroundColor = color;
    _abstractLabel.backgroundColor = color;
}

#pragma mark

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.bottomLineView.bottom = self.height;
}

- (void)updateTitleLabel
{
    if (self.titleLabel)
    {
        [self updateContentColor];
        
        if (!isEmptyString(self.orderedData.article.title)) {
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            self.titleLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] : [UIFont tt_fontOfSize:kCellTitleLabelFontSize];
            self.titleLabel.lineHeight = kCellTitleLineHeight;
            self.titleLabel.text = self.orderedData.article.title;
        } else {
            self.titleLabel.text = nil;
        }
    }
}

- (void)updateAbstract
{
    Article *article = self.orderedData.article;
    
    // 摘要
    self.hasAbstract = [ExploreCellHelper shouldDisplayAbstract:article listType:self.listType] && !isEmptyString(article.abstract);
    
    if (self.hasAbstract && ![self.orderedData isVideoPGCCard]) {
        if (self.abstractLabel.superview == nil) {
            [self addSubview:self.abstractLabel];
        }
        
        if (!isEmptyString(article.abstract)) {
            NSMutableAttributedString *attributedString = [TTLabelTextHelper attributedStringWithString:article.abstract fontSize:kCellAbstractViewFontSize lineHeight:kCellAbstractViewLineHeight];
            self.abstractLabel.attributedText = attributedString;
        }
        else {
            self.abstractLabel.text = @"";
        }
        
        [self updateAbstractTextColor];
    }
    else {
        [self removeAbstractLabel];
    }
}

- (void)updateCommentView
{
    Article *article = self.orderedData.article;
    
    self.hasCommentView = [ExploreCellHelper shouldDisplayComment:article listType:self.listType];
    
    if (self.hasCommentView) {
        if (self.commentView.superview == nil) {
            self.commentView.delegate = self;
            [self addSubview:self.commentView];
        }
        [self.commentView reloadCommentDict:article.displayComment cellWidth:self.width];
        self.commentView.contentLabel.highlighted = [self.orderedData hasRead];
    }
    else
    {
        [self removeCommentView];
    }
}

- (void)updateContentColor
{
    Article *currentArticle = self.orderedData.article;
    
    if (!currentArticle.managedObjectContext)
    {
        return;
    }
    
    BOOL hasRead = [self.orderedData hasRead];
    _titleLabel.highlighted = hasRead;
}

- (void)updateAbstractTextColor
{
    _abstractLabel.textColor = [UIColor tt_themedColorForKey:kCellAbstractViewTextColor];
}

- (void)updateTypeLabel
{
    _logoIcon.size = CGSizeZero;
    [_logoIcon setImageWithURLString:nil];
    
    // 标签展示规则
    // 收藏>推广>专题>Gif>热>荐 （如果置顶，显示置顶文案，服务端控制文案内容）
    if (self.orderedData.stickStyle != 0) {
        self.typeLabel.text = self.orderedData.stickLabel;
        [ExploreCellHelper colorTypeLabel:self.typeLabel orderedData:self.orderedData];
    }
    else if(self.orderedData.originalData.userRepined
            && self.listType != ExploreOrderedDataListTypeFavorite
            && self.listType != ExploreOrderedDataListTypeReadHistory
            && self.listType != ExploreOrderedDataListTypePushHistory) {
        self.typeLabel.text = NSLocalizedString(@"收藏", nil);
        UIColor *textClr = [UIColor tt_themedColorForKey:kCellTypeLabelTextRed];
        UIColor *borderClr = [UIColor tt_themedColorForKey:kCellTypeLabelLineRed];
        self.typeLabel.textColor = textClr;
        self.typeLabel.layer.borderColor = borderClr.CGColor;
    }
    else {
        self.typeLabel.text = nil;
        
        TTImageInfosModel *iconModel = nil;
        Article *article = (Article *)(self.originalData);
        
        if ([article isKindOfClass:[Article class]]) {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                iconModel = article.listSourceIconModel;
            } else {
                iconModel = article.listSourceIconNightModel;
                if (!iconModel) {
                    iconModel = article.listSourceIconModel;
                }
            }
        }
        
        if (iconModel) {
            [self.logoIcon setImageWithModel:iconModel];
            if (iconModel.width > 0 && iconModel.height > 0) {
                CGFloat w = (CGFloat)(kCellTypeLabelHeight * iconModel.width) / iconModel.height;
                _logoIcon.size = CGSizeMake(ceilf(w), kCellTypeLabelHeight);
            } else {
                _logoIcon.size = CGSizeMake(kCellTypeLabelWidth, kCellTypeLabelHeight);
            }
            
        } else {
            if (!isEmptyString(self.orderedData.displayLabel)) {
                self.typeLabel.text = self.orderedData.displayLabel;
            } else {
                if ((self.orderedData.tip & 1) > 0)
                {
                    self.typeLabel.text = NSLocalizedString(@"热", nil);
                }
                else if ((self.orderedData.tip & 2) > 0)
                {
                    self.typeLabel.text = NSLocalizedString(@"荐", nil);
                }
            }
            [ExploreCellHelper colorTypeLabel:self.typeLabel orderedData:self.orderedData];
        }
    }
}

- (void)updateEntityWordView
{
    if (self.orderedData.article.entityWordInfoDict) {
        if (!_entityWordView.superview) {
            [self addSubview:self.entityWordView];
        }
        [_entityWordView updateEntityWordViewWithOrderedData:self.orderedData];
    } else {
        if (_entityWordView.superview) {
            [_entityWordView removeFromSuperview];
        }
    }
}

- (void)layoutTypeLabel
{
    CGFloat x = 0, y = 0, w = 0, h = 0;
    
    if (_logoIcon.width > 0) {
        _logoIcon.frame = CGRectMake(0, floor((self.infoBarView.height - _logoIcon.height) / 2), _logoIcon.width, _logoIcon.height);
        self.typeLabel.hidden = YES;
        _logoIcon.hidden = NO;
    }
    else if (!isEmptyString(self.typeLabel.text)) {
        _logoIcon.hidden = YES;
        self.typeLabel.hidden = NO;
        [self.typeLabel sizeToFit];
        w = self.typeLabel.width + kCellTypeLabelInnerPadding * 2;
        h = kCellTypeLabelHeight;
        x = 0;
        y = floor((self.infoBarView.height - h) / 2);
    }
    
    self.typeLabel.frame = CGRectMake(x, y, w, h);
}

- (BOOL)hasLogoIcon
{
    return _logoIcon.width > 0;
}

- (void)layoutUnInterestedBtn
{
    CGFloat centerX = self.infoBarView.width - kCellUninterestedButtonWidth / 2;
    CGPoint p = CGPointMake(centerX, self.infoBarView.height / 2);
    p = [self convertPoint:p fromView:self.infoBarView];
    self.unInterestedButton.center = p;
}

- (void)layoutEntityWordViewWithPic:(BOOL)hasPic
{
    if (self.orderedData.article.entityWordInfoDict) {
        CGFloat pointY = self.height - kCellEntityWordViewHeight;
        if (hasPic) {
            pointY -= kCellBottomPaddingWithPic;
        } else {
            pointY -= kCellBottomPadding;
        }
        self.entityWordView.frame = CGRectMake(kCellLeftPadding,
                                               pointY,
                                               self.width - kCellLeftPadding - kCellRightPadding,
                                               kCellEntityWordViewHeight);
    }
}

- (void)layoutBottomLine
{
    self.bottomLineView.frame = CGRectMake(kCellLeftPadding,  self.height - [TTDeviceHelper ssOnePixel], self.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
    
    if ([self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
        _bottomLineView.hidden = YES;
    }
    else {
        _bottomLineView.hidden = NO;
    }
}

- (void)layoutInfoBarSubViews
{
    self.infoLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
    self.sourceLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
    [self layoutTypeLabel];
    [self layoutInfoLabel];
    [self layoutUnInterestedBtn];
}

- (void)layoutInfoLabel
{
    Article *article = self.orderedData.article;
    
    CGFloat x;
    
    if (self.typeLabel.width > 0) {
        x = self.typeLabel.right + kCellTypelabelRightPaddingToInfoLabel;
    }
    else if (_logoIcon.width > 0) {
        x = self.logoIcon.right + kCellTypelabelRightPaddingToInfoLabel;
    }
    else {
        x = 0;
    }
    
    CGFloat sourceMaxWidth = self.infoBarView.width - x - kCellUninterestedButtonWidth - 4;
    CGFloat infoMaxWidth = sourceMaxWidth;
    BOOL hideSource = [self.orderedData isAdButtonUnderPic] && ![TTLayOutCellDataHelper isAdShowSourece:self.orderedData];
    if (!isEmptyString(article.source) && [self.orderedData isShowSourceLabel] && !hideSource) {
        self.sourceLabel.text = article.source;
        [self.sourceLabel sizeToFit];
        if (self.sourceLabel.width > sourceMaxWidth) {
            self.sourceLabel.frame = CGRectMake(x, floor((self.infoBarView.height - kCellTypeLabelHeight) / 2), sourceMaxWidth, kCellTypeLabelHeight);
        }
        else{
            self.sourceLabel.frame = CGRectMake(x, floor((self.infoBarView.height - kCellTypeLabelHeight) / 2), ceilf(self.sourceLabel.width), kCellTypeLabelHeight);
        }
        infoMaxWidth -= self.sourceLabel.width;
        x += self.sourceLabel.width;
        
        // 取消了加V
        infoMaxWidth -= [TTDeviceHelper isPadDevice] ? 14.f : 8.f;
        x += [TTDeviceHelper isPadDevice] ? 14.f : 8.f;
    }
    else{
        self.sourceLabel.text = @"";
        [self.sourceLabel sizeToFit];
    }
    
    NSArray *subStringArray = [TTLayOutCellDataHelper getInfoStringWithOrderedData:self.orderedData hideTimeLabel:self.hideTimeLabel];
    
    if ([subStringArray count] > 0) {
        NSString *infoStr = [subStringArray lastObject];
        self.infoLabel.text = [infoStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.infoLabel sizeToFit];
        
        int index = (int)subStringArray.count - 1;
        while (self.infoLabel.width > infoMaxWidth && index > 0) {
            index -= 1;
            infoStr = [subStringArray objectAtIndex:index];
            self.infoLabel.text = [infoStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.infoLabel sizeToFit];
        }
    }
    else {
        self.infoLabel.text = @"";
        self.infoLabel.hidden = YES;
    }
    
    CGRect rect;
    if (self.infoLabel.width <= infoMaxWidth) {
        rect = CGRectMake(x, floor((self.infoBarView.height - kCellTypeLabelHeight) / 2), ceil(self.infoLabel.width), kCellTypeLabelHeight);
        self.infoLabel.frame = CGRectIntegral(rect);
        self.infoLabel.hidden = NO;
    } else {
        self.infoLabel.text = @"";
        self.infoLabel.hidden = YES;
    }
}

- (void)layoutAbstractAndCommentView:(CGPoint)origin
{
    CGFloat x = origin.x;
    CGFloat y = origin.y;
    
    if (self.hasAbstract) {
        self.abstractLabel.frame = CGRectMake(x, y + kCellAbstractVerticalPadding - kCellAbstractViewCorrect, self.frame.size.width - kCellLeftPadding - kCellRightPadding, 0);
        CGSize abstractSize = [ExploreCellHelper updateAbstractSize:self.orderedData.article cellWidth:self.width];
        self.abstractLabel.height = abstractSize.height;
        y = self.abstractLabel.bottom;
    }
    
    if (self.hasCommentView) {
        CGSize commentSize = [ExploreCellHelper updateCommentSize:[self.orderedData.article commentContent] cellWidth:self.width];
        self.commentView.frame = CGRectMake(x, y + kCellCommentTopPadding, self.width - kCellLeftPadding - kCellRightPadding, commentSize.height);
    }
}

- (void)exploreArticleCellCommentViewSelected:(ExploreArticleCellCommentView*)commentView
{
    [self showComment:nil];
}

- (void)showComment:(id)sender
{
    TTFeedCellSelectContext *context = [TTFeedCellSelectContext new];
    context.refer = [self getRefer];
    context.orderedData = self.orderedData;
    if (self.isCardSubCellView) {
        context.categoryId = self.cardCategoryId;
    } else {
        context.categoryId = self.orderedData.categoryID;
    }
    context.clickComment = YES;
    [self didSelectWithContext:context];
}

#pragma mark - KVO

static void *ExploreArticleCellContext = &ExploreArticleCellContext;

- (void)addKVO
{
    if (self.originalData) {
        [self.KVOController observe:self.originalData keyPaths:@[@"userRepined", @"hasRead", @"commentCount"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:ExploreArticleCellContext];
    }
}

- (void)removeKVO
{
    if (self.originalData) {
        [self.KVOController unobserveAll];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    LOGD(@"CellView KVO: %p %@", object, keyPath);
    
    NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (!newValue || [newValue isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if ([oldValue isKindOfClass:[NSNull class]] || ([oldValue isKindOfClass:[NSNumber class]] && [newValue isKindOfClass:[NSNumber class]] && ![oldValue isEqualToNumber:newValue])) {
        // 只处理主线程的修改，忽略子线程中插入数据库过程中的修改，解决由此导致的crash
        if ([NSThread isMainThread]) {
            [self handleChangedValue:newValue forKeyPath:keyPath];
        }
    }
}

- (void)handleChangedValue:(NSNumber *)newValue forKeyPath:(NSString *)keyPath {
    if([keyPath isEqualToString:@"userRepined"])
    {
        [self updateTypeLabel];
        [self layoutInfoBarSubViews];
    }
    else if([keyPath isEqualToString:@"hasRead"])
    {
        _titleLabel.highlighted = [newValue boolValue];
        _commentView.contentLabel.highlighted = [newValue boolValue];
    }
    else if([keyPath isEqualToString:@"commentCount"])
    {
        [self updateTypeLabel];
        [self layoutInfoBarSubViews];
    }
}

- (BOOL)shouldRefesh {
    if (self.orderedData.originalData) {
        return self.orderedData.originalData.needRefreshUI;
    }
    return NO;
}

- (void)refreshDone {
    if (self.orderedData.originalData) {
        self.orderedData.originalData.needRefreshUI = NO;
    }
}

//------------------------------------------------------------------
#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (!self.orderedData) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    
    NSArray *filterWords = [dislikeView selectedWords];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}


- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType
{
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:[@(self.orderedData.article.uniqueID) stringValue] forKey:@"group_id"];
    [eventContext setValue:self.orderedData.article.itemID forKey:@"item_id"];
    NSString * screenName = [NSString stringWithFormat:@"channel_%@", self.orderedData.categoryID];
    NSString * shareType = [TTActivityShareManager shareTargetStrForTTLogWithType:itemType];
//    [TTLogManager logEvent:shareType context:eventContext screenName:screenName];//TTLogManager 不用了
}

- (NSString *)screenName {
    if (!isEmptyString(self.orderedData.categoryID)) {
        return [NSString stringWithFormat:@"channel_%@",self.orderedData.categoryID];
    }
    if (!isEmptyString(self.orderedData.concernID)) {
        return  [NSString stringWithFormat:@"channel_%@",self.orderedData.concernID];
    }
    return @"channel_unknown";
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context{
    CGRect picViewFrame = CGRectZero;
    TTArticlePicViewStyle picViewStyle = TTArticlePicViewStyleNone;
    TTArticlePicView *picView = self.picView;
    if (picView && picView.superview) {
        picViewFrame = [picView convertRect:picView.bounds toView:self];
        picViewStyle = picView.style;
    }
    context.picViewFrame = picViewFrame;
    context.picViewStyle = picViewStyle;
    context.targetView = self;
    [super didSelectWithContext:context];
}

@end

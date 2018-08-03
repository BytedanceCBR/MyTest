//
//  FantasyCardCell.h
//  Article
//
//  Created by chenren on 1/02/18.
//
//

#import "FantasyCardCellView.h"
#import "FantasyCardData.h"
#import "EssayData.h"
#import "MTLabel.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTUISettingHelper.h"
#import "SSAppStore.h"
#import "TTRoute.h"
#import "TTVFantasy.h"
#import "TTTrackerWrapper.h"
#import "TTAlphaThemedButton.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "TTFantasyWindowManager.h"

extern NSString * const kTTFEnterFromTypeKey;
@interface FantasyCardCellView ()

@property (nonatomic, strong) TTImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@property (nonatomic, strong) SSThemedLabel *bigWordsLabel;
@property (nonatomic, strong) SSThemedLabel *bigWordsTailLabel;
@property (nonatomic, strong) SSThemedButton *actionButton;
@property (nonatomic, strong) SSThemedView *adBackgroundView;
@property (nonatomic, strong) UIView *sepLineView;
@property (nonatomic, strong) SSThemedView *bottomView;
@property (nonatomic, strong) SSThemedButton *unInterestedButton; //不感兴趣

@end

@implementation FantasyCardCellView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.bigWordsLabel];
        [self addSubview:self.bigWordsTailLabel];
        [self addSubview:self.actionButton];
        [self addSubview:self.unInterestedButton];
    }
    
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    CGFloat height = 136.5f;
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        if (![TTDeviceHelper isPadDevice] && ![orderedData nextCellHasTopPadding]) {
            //height += kCellSeprateViewHeight();
        }
    }
    return height;
}

- (NSUInteger)refer
{
    return [[self cell] refer];
}

- (id)cellData
{
    return self.orderedData;
}

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] initWithFrame:CGRectMake(15, 16, 104, 104)];
        _imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _imageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    }
    return _imageView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(135, 20, [UIScreen mainScreen].bounds.size.width - 150, 18)];
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:13];
        }
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColorThemeKey = kColorText3;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_titleLabel addGestureRecognizer:singleTap];
    }
    return _titleLabel;
}

- (SSThemedLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(135, 42, [UIScreen mainScreen].bounds.size.width - 150, 24)];
        CGFloat fontSize = 17.0;
        if ([UIScreen mainScreen].bounds.size.width < 374) {
            fontSize = 15.0;
        }
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
        } else {
            _contentLabel.font = [UIFont systemFontOfSize:fontSize];
        }
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.textColorThemeKey = kColorText1;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_contentLabel addGestureRecognizer:singleTap];
    }
    return _contentLabel;
}

- (SSThemedLabel *)bigWordsLabel
{
    if (!_bigWordsLabel) {
        _bigWordsLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(135, 74, 100, 42)];
        CGFloat fontSize = 36.0;
        if ([UIScreen mainScreen].bounds.size.width < 374) {
            fontSize = 32.0;
        }
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _bigWordsLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size:fontSize];
        } else {
            _bigWordsLabel.font = [UIFont systemFontOfSize:fontSize];
        }
        _bigWordsLabel.textAlignment = NSTextAlignmentLeft;
        _bigWordsLabel.textColorThemeKey = kColorText4;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_bigWordsLabel addGestureRecognizer:singleTap];
    }
    return _bigWordsLabel;
}

- (SSThemedLabel *)bigWordsTailLabel
{
    if (!_bigWordsTailLabel) {
        _bigWordsTailLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(205, 74, 65, 42)];
        CGFloat fontSize = 28.0;
        if ([UIScreen mainScreen].bounds.size.width < 374) {
            fontSize = 24.0;
        }
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _bigWordsTailLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
        } else {
            _bigWordsTailLabel.font = [UIFont systemFontOfSize:fontSize];
        }
        _bigWordsTailLabel.textAlignment = NSTextAlignmentLeft;
        _bigWordsTailLabel.textColorThemeKey = kColorText4;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_bigWordsTailLabel addGestureRecognizer:singleTap];
    }
    return _bigWordsTailLabel;
}

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        CGFloat width = 88.0;
        if ([UIScreen mainScreen].bounds.size.width < 374) {
            width = 78.0;
        }
        _actionButton = [[SSThemedButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - width - 20, 79, width, 32)];
        _actionButton.backgroundColorThemeKey = kColorBackground7;
        _actionButton.titleColorThemeKey = kColorText12;
        _actionButton.layer.masksToBounds = YES;
        _actionButton.layer.cornerRadius = 4.f;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
        [_actionButton addTarget:self action:@selector(didClickActionButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (SSThemedView *)adBackgroundView
{
    if (!_adBackgroundView) {
        _adBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _adBackgroundView.backgroundColorThemeKey = kColorBackground3;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickADBackgroundView)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_adBackgroundView addGestureRecognizer:singleTap];
    }
    return _adBackgroundView;
}

- (SSThemedButton *)unInterestedButton
{
    if (!_unInterestedButton) {
        _unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _unInterestedButton.imageName = @"add_textpage.png";
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unInterestedButton;
}

- (void)unInterestButtonClicked:(id)sender
{
    [TTFeedDislikeView dismissIfVisible];
    [self showMenu];
}

- (void)showMenu
{
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.article.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    viewModel.logExtra = self.orderedData.logExtra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.unInterestedButton.center;
    [dislikeView showAtPoint:point
                    fromView:self.unInterestedButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView
{
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

- (void)didClickADBackgroundView
{
    [self didSelectWithContext:nil];
}

- (void)didClickActionButton
{
    [self didSelectWithContext:nil];
}

- (void)updateContentColor
{
}

- (void)refreshUI
{
    FantasyCardData *fantasyCardData = self.orderedData.fantasyCardData;
    
    self.unInterestedButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 30 - 8, 7, 60, 44);
    
    [_imageView setImageWithURLString:fantasyCardData.imageURL];
    CGFloat fontSize = 36.0;
    if ([UIScreen mainScreen].bounds.size.width < 374) {
        fontSize = 32.0;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
        font = [UIFont fontWithName:@"DINAlternate-Bold" size:fontSize];
    }
    CGRect rect = [fantasyCardData.bigWords boundingRectWithSize:CGSizeMake(MAXFLOAT, 42)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName : font}
                                                         context:nil];
    _bigWordsTailLabel.left = _bigWordsLabel.left + rect.size.width + 1;
    _titleLabel.text = fantasyCardData.title;
    _contentLabel.text = fantasyCardData.content;
    _bigWordsLabel.text = fantasyCardData.bigWords;
    _bigWordsTailLabel.text = fantasyCardData.bigWordsTail;
    [_actionButton setTitle:fantasyCardData.buttonText forState:UIControlStateNormal];
    
//    if ([TTDeviceHelper isPadDevice] || [self.orderedData nextCellHasTopPadding]) {
//        _bottomView.frame = CGRectMake(0, 136.5f - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
//    } else {
//        _bottomView.frame = CGRectMake(0, 136.5f, self.width, kCellSeprateViewHeight());
//    }
    
    if ([self.orderedData nextCellHasTopPadding]) {
        _bottomView.frame = CGRectMake(0, 136.5f - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
    } else {
        _bottomView.frame = CGRectMake(15, 136.5f - [TTDeviceHelper ssOnePixel], self.width - 30, [TTDeviceHelper ssOnePixel]);
    }
    
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (!_bottomView) {
        _bottomView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColorThemeKey = kCellBottomLineColor;
        [self addSubview:_bottomView];
    }
}

+ (CGRect)frameForContentLabel:(NSString *)content cellWidth:(CGFloat)width isList:(BOOL)displayInList
{
    CGFloat titleFontSize;
    CGFloat lineH;
    if (displayInList) {
        titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
    }
    else{
        titleFontSize = [NewsUserSettingManager settedEssayDetailViewTextFontSize];
        lineH = [NewsUserSettingManager settedEssayDetailViewTextFontLineHeight];
    }
    UIFont *font = [UIFont systemFontOfSize:titleFontSize];
    
    CGFloat titleWidth = width - kCellLeftPadding - kCellRightPadding;
    CGFloat titleHeight = [MTLabel heightOfText:content lineHeight:lineH font:font width:titleWidth];
    
    CGRect frame = CGRectZero;
    frame.origin.x = kCellLeftPadding;
    frame.origin.y = cellTopPadding();
    frame.size.width = ceilf(titleWidth);
    frame.size.height = ceilf(titleHeight);
    
    return frame;
}

+ (CGFloat)viewTopPadding
{
    if ([TTDeviceHelper isPadDevice]) {
        return 20;
    } else {
        return 11;
    }
}

+ (CGFloat)viewBottomPadding
{
    if ([TTDeviceHelper isPadDevice]) {
        return 20;
    } else {
        return 11;
    }
}

- (void)ssLayoutSubviews {
    [super ssLayoutSubviews];
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _imageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    [self updateContentColor];
}

- (void)fontSizeChanged
{
    [super fontSizeChanged];
}

+ (NSUInteger)cellTypeForCacheHeightFromOrderedData:(id)orderedData
{
    if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
        // 由于同一个段子cell，位于不同的频道时UI有差别，故缓存高度时须附带频道ID
        return ((ExploreOrderedData *)orderedData).categoryID.hash;
    }
    return [[self class] hash];
}

// override
- (void)layoutInfoLabel
{
    if (![self shouldShowActionButtons]) {
    }
}

- (BOOL)shouldShowActionButtons
{
    // 优化的前提：同一列表中的orderedData有相同的categoryID
//    if (_shouldShowActionButtonsFlag == 0) {
        BOOL bShow = [ExploreCellHelper shouldShowEssayActionButtons:self.orderedData.categoryID];
//        _shouldShowActionButtonsFlag = bShow ? 1 : 2;
//    }
    
//    return (_shouldShowActionButtonsFlag == 1);
    return bShow;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context
{
    NSString *categoryID = @"";
    if (self.orderedData.categoryID) {
        categoryID = self.orderedData.categoryID;
    }
    if (self.orderedData.uniqueID) {
        [TTTrackerWrapper eventV3:@"fantasy_card_click" params:@{@"fantasy_card_id" : self.orderedData.uniqueID, @"category_name" : categoryID, @"click_position" : @"all"}];
    }
    
    FantasyCardData *fantasyCardData = self.orderedData.fantasyCardData;
    if (fantasyCardData.jumpURL) {
        [[TTRoute sharedRoute] openURL:[NSURL URLWithString:fantasyCardData.jumpURL] userInfo:nil objHandler:^(TTRouteObject *routeObj) {
            
            if ([SSCommonLogic fantasyWindowResizeable]) {
                [TTFantasyWindowManager sharedManager].trackerDescriptor = routeObj.paramObj.queryParams;
                [[TTFantasyWindowManager sharedManager] show];
            } else {
                [TTVFantasy ttf_enterFantasyFromViewController:[TTUIResponderHelper topmostViewController] trackerDescriptor:routeObj.paramObj.queryParams];
            }
            
            //[TTVFantasy ttf_enterFantasyFromViewController:[TTUIResponderHelper topmostViewController] trackerDescriptor:routeObj.paramObj.queryParams];
        }];
    }
    
    //[[TTFantasyWindowManager sharedManager] show];
}

@end

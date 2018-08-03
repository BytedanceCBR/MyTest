//
//  TTHotNewsCellView.m
//  Article
//
//  Created by Sunhaiyuan on 2018/1/22.
//

#import "TTHotNewsCellView.h"
#import "TTDeviceUIUtils.h"
#import "TTThemeManager.h"
#import "TTUISettingHelper.h"
#import "TTRoute.h"
#import "TTImageView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "NSString-Extension.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"
#import "TTAlphaThemedButton.h"
#import "TTFeedDislikeView.h"
#import "TTArticleSearchManager.h"
#import "TTSearchHomeSugModel.h"
#import "ExploreMixListDefine.h"
#import "TTLayOutCellDataHelper.h"
#import "NSObject+FBKVOController.h"
#import "TTLabelTextHelper.h"
#import "TTLabel.h"

#define ItemPadding 27.f
#define MAX_NEWS_COUNT 10
@interface TTHotNewsCellView()
@property (nonatomic, strong) SSThemedLabel                *showMoreLabel;
@property (nonatomic, strong) SSThemedButton               *showMoreIcon;
@property (nonatomic, strong) SSThemedLabel                *typeLabel;
@property (nonatomic, strong) TTLabel                      *titleLabel;
@property (nonatomic, strong) SSThemedView                 *bottomLineView;
@property (nonatomic, strong) SSThemedLabel                *sourceLabel;
@property (nonatomic, strong) SSThemedLabel                *infoLabel;
@property (nonatomic, strong) SSThemedView                 *showMoreBgView;
@property (nonatomic, strong) UIView                       *infoBarView;
@property (nonatomic, strong) UIButton                     *unInterestedButton;
@end

@implementation TTHotNewsCellView

- (SSThemedLabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.textAlignment  = NSTextAlignmentCenter;
        _typeLabel.font = [UIFont systemFontOfSize:kCellTypeLabelFontSize];
        _typeLabel.layer.cornerRadius = kCellTypeLabelCornerRadius;
        _typeLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _typeLabel.clipsToBounds = YES;
        [self addSubview:_typeLabel];
    }
    return _typeLabel;
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
        BOOL isBoldFont = [TTDeviceHelper isPadDevice];
        self.titleLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] : [UIFont tt_fontOfSize:kCellTitleLabelFontSize];
        self.titleLabel.lineHeight = kCellTitleLineHeight;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedView *)bottomLineView
{
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLineView;
}

- (SSThemedLabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _infoLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _infoLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
        _infoLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
        _infoLabel.clipsToBounds = YES;
    }
    return _infoLabel;
}

- (SSThemedLabel *)sourceLabel
{
    if (!_sourceLabel) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _sourceLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
        _sourceLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
        _sourceLabel.clipsToBounds = YES;
    }
    return _sourceLabel;
}

- (SSThemedView *)showMoreBgView {
    if (!_showMoreBgView) {
        _showMoreBgView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _showMoreBgView.backgroundColorThemeName = kColorBackground3;
        _showMoreBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShowMoreBtnClick)];
        [_showMoreBgView addGestureRecognizer:tap];
    }
    return _showMoreBgView;
}

- (UIView *)infoBarView {
    if (!_infoBarView) {
        _infoBarView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _infoBarView;
}

- (UIButton *)unInterestedButton
{
    if ((self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])) {
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


#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name: TTThemeManagerThemeModeChangedNotification object:nil];
        
        //showMore label
        self.showMoreLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.showMoreLabel];
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            self.showMoreLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: [self showMoreFontSize]];
        } else {
            self.showMoreLabel.font = [UIFont systemFontOfSize:[self showMoreFontSize]];
        }
        self.showMoreLabel.textColorThemeKey = kColorText1;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShowMoreBtnClick)];
        [self.showMoreLabel addGestureRecognizer:tap];
        self.showMoreLabel.userInteractionEnabled = YES;
        
        self.showMoreIcon = [[SSThemedButton alloc] initWithFrame:CGRectZero];

        //titleLabel
        [self addSubview:self.titleLabel];
        
        //typeLabel
        [self addSubview:self.typeLabel];
        
        //bottom line
        [self addSubview:self.bottomLineView];
        
        //info barview
        [self addSubview:self.infoBarView];
        
        //source Label
        [self.infoBarView addSubview:self.sourceLabel];
        
        //info Label
        [self.infoBarView addSubview:self.infoLabel];
        
        //show more background
        [self addSubview:self.showMoreBgView];
        [self.showMoreBgView addSubview:self.showMoreLabel];
        [self.showMoreBgView addSubview:self.showMoreIcon];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeKVO];
}


+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    CGFloat height = 0;
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        TTHotNewsData *hotNewsData = orderedData.hotNewsData;
        Article *article = hotNewsData.internalData.article;
        //跳转模式
        if (!article || isEmptyString(article.title)) { return 0; }
        CGFloat containerWidth = width - kCellLeftPadding - kCellRightPadding;
        CGFloat titleHeight = [article.title tt_sizeWithMaxWidth:containerWidth font:[TTDeviceHelper isPadDevice]? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] :[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
        height += titleHeight;
        height += cellTopPadding();
        height += kCellTitleBottomPaddingToInfo * 2 + 14.f;
        height += 36.f; // showMoreView height
        height += 20.f;
    }
    return height;
}

- (id)cellData {
    return self.orderedData;
}

- (NSUInteger)refer {
    return [[self cell] refer];
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        [self removeKVO];
        self.orderedData = data;
        self.article = self.orderedData.hotNewsData.internalData.article;
        [self addKVO];
    } else {
        self.orderedData = nil;
        [self removeKVO];
    }
}

#pragma mark - refresh UI
- (void)refreshUI {
    
    TTHotNewsData *hotNewsData = self.orderedData.hotNewsData;
    if (!hotNewsData) { return; }
    
    if (hotNewsData.showDislike) {
        self.unInterestedButton.hidden = NO;
    } else {
        self.unInterestedButton.hidden = YES;
    }
    
    if (!self.article) { return; }
    self.orderedData.hotNewsData.hasRead = self.orderedData.hotNewsData.internalData.article.hasRead;
    CGFloat max_x = 0;
    self.titleLabel.frame = CGRectMake(cellLeftPadding(), cellTopPadding(), self.width - cellLeftPadding() - cellRightPadding(), 0);
    self.titleLabel.text = self.article.title;
    BOOL hasRead = [hotNewsData hasRead];
    _titleLabel.highlighted = hasRead;
    [self.titleLabel sizeToFit];
    if (!isEmptyString(hotNewsData.label)) {
        self.typeLabel.frame = CGRectMake(cellLeftPadding(), self.titleLabel.bottom + kCellTitleBottomPaddingToInfo, 27.f, 14.f);
        self.typeLabel.text = hotNewsData.label;
        //要闻 样式
        self.typeLabel.layer.borderColor = [UIColor tt_themedColorForKey:kCellTypeLabelLineRed].CGColor;
        self.typeLabel.textColorThemeKey = kCellTypeLabelTextRed;
        //[self.typeLabel sizeToFit];
        max_x = self.typeLabel.right;
    }
    
    //info bar view
    self.infoBarView.frame = CGRectMake(floor(max_x + 10.f), 0, self.width - kCellLeftPadding - kCellRightPadding, kCellInfoBarHeight);
    self.infoBarView.top = self.titleLabel.bottom + kCellTitleBottomPaddingToInfo;
    
    max_x = 0;
    //source label
    if (!isEmptyString(self.article.source)) {
        self.sourceLabel.text = self.article.source;
        [self.sourceLabel sizeToFit];
        self.sourceLabel.left = max_x;
        self.sourceLabel.centerY = kCellInfoBarHeight * 0.5;
        max_x = self.sourceLabel.right;
    }
    
    //info label
    NSMutableString *text = [NSMutableString string];

    NSString *commentStr;
    if (!isEmptyString(self.article.infoDesc)) {
        commentStr = self.article.infoDesc;
    } else {
        NSUInteger count = hotNewsData.commentCount;
        count = MAX(0, count);
        commentStr = [NSString stringWithFormat:@"%@%@ ", [TTBusinessManager formatCommentCount:count], NSLocalizedString(@"评论", nil)];
        [text appendString:commentStr];
    }

    if (hotNewsData.behotTime) {
        [text appendString:[TTBusinessManager customtimeAndCustomdateStringSince1970:hotNewsData.behotTime]];
    }

    self.infoLabel.text = [text copy];
    [self.infoLabel sizeToFit];
    self.infoLabel.left = max_x + 10.f;
    self.infoLabel.centerY = self.sourceLabel.centerY;
    max_x = self.infoLabel.right;


    //show more
    if (!isEmptyString(hotNewsData.showMoreDesc)) {
        CGFloat width = self.width - cellLeftPadding() - cellRightPadding();
        self.showMoreBgView.frame = CGRectMake(cellLeftPadding(), self.infoBarView.bottom + kCellBottomPadding, width, 36.f);
        
        self.showMoreIcon.hidden = NO;
        self.showMoreLabel.hidden = NO;
        self.showMoreBgView.hidden = NO;
        
        self.showMoreLabel.text = hotNewsData.showMoreDesc;
        [self.showMoreLabel sizeToFit];
        self.showMoreLabel.centerX = self.showMoreBgView.width * 0.5;
        self.showMoreLabel.centerY = self.showMoreBgView.height * 0.5;
        [self.showMoreBgView addSubview:self.showMoreLabel];
        
        [self updateArrowIcon];
        self.showMoreIcon.left = self.showMoreLabel.right + 8.f;
        self.showMoreIcon.centerY = self.showMoreLabel.centerY;
    }
    //dislike button
    self.unInterestedButton.left = ceil(self.width - self.unInterestedButton.width + 6.5);
    self.unInterestedButton.centerY = self.infoBarView.centerY;
    
    //bottom line
//    self.bottomLineView.frame = CGRectMake(kCellLeftPadding, self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
    self.bottomLineView.hidden = YES;
}

#pragma mark - privates

- (void)updateTitleLabel
{
    if (self.titleLabel)
    {
        TTHotNewsData *hotNewsData = self.orderedData.hotNewsData;
        if (!hotNewsData) { return; }
        
        Article *article = hotNewsData.internalData.article;
        if (!article) { return; }
        
        if (!isEmptyString(article.title)) {
            BOOL isBoldFont = [TTDeviceHelper isPadDevice];
            self.titleLabel.font = isBoldFont ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] : [UIFont tt_fontOfSize:kCellTitleLabelFontSize];
            self.titleLabel.lineHeight = kCellTitleLineHeight;
            self.titleLabel.text = self.article.title;
        } else {
            self.titleLabel.text = nil;
        }
    }
}

- (void)showMenu
{
    
    [TTFeedDislikeView dismissIfVisible];
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    //    viewModel.keywords = self.orderedData.hotNewsSingleItemData.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lu", self.orderedData.hotNewsData.groupId];
    viewModel.logExtra = self.orderedData.logExtra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.unInterestedButton.center;
    [dislikeView showAtPoint:point
                    fromView:self.unInterestedButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)addKVO {
    [self.KVOController observe:self.orderedData.hotNewsData keyPaths:@[@"userRepined", @"hasRead", @"commentCount"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeKVO {
    if (self.orderedData) {
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
    if([keyPath isEqualToString:@"hasRead"])
    {
        _titleLabel.highlighted = [newValue boolValue];
    }
}

#pragma mark - UI settings

- (CGFloat)showMoreFontSize {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 16.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 14.f;
    } else {
        fontSize = 13.f;
    }
    return fontSize;
}

- (CGFloat)weatherInfoFontSize {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 13.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 12.f;
    } else {
        fontSize = 10.f;
    }
    return fontSize;
}

- (void)updateArrowIcon {
    self.showMoreIcon.imageName = @"all_card_arrow";
    [self.showMoreIcon sizeToFit];
}

#pragma mark - actions callback

- (void)onShowMoreBtnClick {
    TTHotNewsData *hotNewsData = self.orderedData.hotNewsData;
    if (isEmptyString(hotNewsData.showMoreSchemaUrl)) return;
    NSRange range = [hotNewsData.showMoreSchemaUrl rangeOfString:@"category="];
    NSUInteger index = range.location + range.length;
    NSString *descCategory = [hotNewsData.showMoreSchemaUrl substringFromIndex:index];
    if (isEmptyString(descCategory)) return;
    //埋点
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    [params setValue:self.orderedData.categoryID forKey:@"category_name"];
    [params setValue:@"stream" forKey:@"tab_name"];
    [params setValue:descCategory forKey:@"to_category_name"];
    [params setValue:@"list" forKey:@"position"];
    [params setValue:@"click_headline" forKey:@"enter_from"];
    [TTTrackerWrapper eventV3:@"click_more_news" params:params];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:hotNewsData.showMoreSchemaUrl]];
}

- (void)unInterestButtonClicked:(UIButton *)button {
    [self showMenu];
}

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
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    
    [params setValue:@"no_interest" forKey:@"dislike_type"];
    [params setValue:@"click_dislike" forKey:@"enter_from"];
    [params setValue:self.orderedData.categoryID forKey:@"category_name"];
    [params setValue:@"stream" forKey:@"tab_name"];
    [params setValue:@"list" forKey:@"position"];
    [TTTrackerWrapper eventV3:@"rt_dislike" params:params];
    
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    self.orderedData.hotNewsData.hasRead = @(YES);
    context.orderedData = self.orderedData.hotNewsData.internalData;
    [super didSelectWithContext:context];
}

#pragma mark - notification
- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.sourceLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.sourceLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
    self.infoLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    self.infoLabel.textColor = [UIColor tt_themedColorForKey:kCellInfoLabelTextColor];
    self.titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _titleLabel.textColor = [TTUISettingHelper cellViewTitleColor];
    _titleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    
    //要闻边框颜色
    self.typeLabel.layer.borderColor = [UIColor tt_themedColorForKey:kCellTypeLabelLineRed].CGColor;
    [self updateArrowIcon];
}

- (void)fontSizeChanged {
    [self updateTitleLabel];
}
@end



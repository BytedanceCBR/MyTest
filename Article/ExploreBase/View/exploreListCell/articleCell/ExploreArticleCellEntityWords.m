//
//  ExploreArticleCellEntityWords.m
//  Article
//
//  Created by Yang Xinyu on 4/1/16.
//
//

#import "ExploreArticleCellEntityWords.h"
#import "DetailActionRequestManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "Article.h"
#import "TTRoute.h"
#import "TTInstallIDManager.h"
#import "TTNetworkManager.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "TTFollowNotifyServer.h"

typedef NS_ENUM(NSInteger, TTArticleCellEntityWordViewType)
{
    TTArticleCellEntityWordViewTypeNone  = 0,
    TTArticleCellEntityWordViewTypeNomal = 1,
    TTArticleCellEntityWordViewTypeLike  = 2
};

#define kHeartButtonTitleNormal   @"关心"
#define kHeartButtonTitleSelected @"已关心"

/// 事件统计key
#define kEvent4EntityWord_listShow   @"list_show"
#define kEvent4EntityWord_listClick  @"list_click"
#define kEvent4EntityWord_listLike   @"list_like"
#define kEvent4EntityWord_listUnlike @"list_unlike"

@implementation TTArticleCellEntityWordView
{
    SSThemedView               * _likeBgView;
    SSThemedLabel              * _contentLabel;
    SSThemedView               * _separatorLine;
    SSThemedButton             * _relatedArticleButton;
    SSThemedButton             * _heartButton;

    ExploreOrderedData         * _orderedData;
    DetailActionRequestManager * actionRequestManager;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColorThemeKey = kCellEntityWordViewBorderColor;
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.backgroundColorThemeKey = kCellEntityWordViewBackgroundColor;
        
        // text label
        _contentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColorThemeKey = kCellEntityWordViewTextColor;
        _contentLabel.font = [UIFont systemFontOfSize:kCellEntityWordViewFontSize];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_contentLabel];
        
        // related article button
        _relatedArticleButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _relatedArticleButton.backgroundColor = [UIColor clearColor];
        _relatedArticleButton.imageName = @"like_arrow_textpage";
        _relatedArticleButton.highlightedImageName = @"like_arrow_textpage_press";
        [_relatedArticleButton addTarget:self action:@selector(relatedArticleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_relatedArticleButton];
        
        // like background view
        _likeBgView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _likeBgView.backgroundColorThemeKey = self.backgroundColorThemeKey;
        [self addSubview:_likeBgView];
        
        // separator line
        _separatorLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _separatorLine.backgroundColorThemeKey = kCellEntityWordViewSeparatorLineColor;
        [_likeBgView addSubview:_separatorLine];
        
        // heart button
        _heartButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _heartButton.backgroundColor = [UIColor clearColor];
        _heartButton.imageName = @"like_heart_textpage";
        _heartButton.selectedImageName = @"like_heart_textpage_select";
        NSString *heartString = @"关注";
        [_heartButton setTitle:NSLocalizedString(heartString, nil) forState:UIControlStateNormal];
        [_heartButton setTitle:NSLocalizedString(heartString, nil) forState:UIControlStateSelected];
        _heartButton.titleColorThemeKey = kCellEntityWordViewHeartButtonTextColor;
        _heartButton.selectedTitleColorThemeKey = kCellEntityWordViewHeartButtonSelectedTextColor;
        _heartButton.titleLabel.font = [UIFont systemFontOfSize:kCellEntityWordViewFontSize];
        _heartButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _heartButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
        [_heartButton addTarget:self action:@selector(heartButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_likeBgView addSubview:_heartButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _contentLabel.font = [UIFont systemFontOfSize:kCellEntityWordViewFontSize];
    _heartButton.titleLabel.font = _contentLabel.font;
    
    // related article button
    _relatedArticleButton.frame = self.bounds;
    CGFloat fontSize = kCellEntityWordViewFontSize;
    CGFloat imgSide = fontSize;
    CGFloat rightInset = kCellEntityWordViewRelatedButtonRightPadding;
    CGFloat verticalInset = (CGRectGetHeight(self.frame) - imgSide) / 2;
    _relatedArticleButton.imageEdgeInsets = UIEdgeInsetsMake(verticalInset, CGRectGetWidth(self.frame) - imgSide - rightInset, verticalInset, rightInset);
    
    CGFloat lineHeight = fontSize;
    
    
    CGFloat heartButtonWidth = kCellEntityWordViewFontSize * 3 + kCellEntityWordViewHeartButtonInsidePadding;
    _heartButton.frame = CGRectMake(kCellEntityWordViewHeartButtonHorizontalPadding, 0, heartButtonWidth, CGRectGetHeight(self.frame));
    
    CGFloat widthOflikeBgView = heartButtonWidth + kCellEntityWordViewHeartButtonHorizontalPadding * 2;
    _likeBgView.frame = CGRectMake(CGRectGetWidth(self.frame) - widthOflikeBgView, 0, widthOflikeBgView, CGRectGetHeight(self.frame));
    
    _separatorLine.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - lineHeight) / 2, [TTDeviceHelper ssOnePixel], lineHeight);
    
    _contentLabel.frame = CGRectMake(kCellEntityWordViewLeftPadding, 0, CGRectGetWidth(self.frame) - CGRectGetWidth(_likeBgView.frame) - kCellEntityWordViewLeftPadding, CGRectGetHeight(self.frame));
}

- (void)updateEntityWordViewWithOrderedData:(ExploreOrderedData *)orderedData
{
    _orderedData = orderedData;
    NSDictionary *entityInfoDict = orderedData.article.entityWordInfoDict;
    NSString *entityText = [entityInfoDict valueForKey:kEntityText];
    NSArray *entityMarkArray = [entityInfoDict valueForKey:kEntityMark];
    
    NSMutableDictionary *attributedTextInfo = [NSMutableDictionary dictionary];
    [attributedTextInfo setValue:entityText forKey:kSSThemedLabelText];
    [entityMarkArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull range, NSUInteger idx, BOOL * _Nonnull stop) {
        [attributedTextInfo setValue:kCellEntityWordViewHighlightTextColor forKey:NSStringFromRange([range rangeValue])];
    }];
    _contentLabel.attributedTextInfo = attributedTextInfo;
    
    TTArticleCellEntityWordViewType entityWordViewType = [[entityInfoDict valueForKey:kEntityStyle] integerValue];
    _likeBgView.hidden = !(TTArticleCellEntityWordViewTypeLike == entityWordViewType);
    _heartButton.selected = [[entityInfoDict valueForKey:kEntityFollowed] integerValue] == 1;
    
    // 事件统计
    if (![entityInfoDict objectForKey:@"hadAppeared"]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:entityInfoDict];
        [dict setValue:@"1" forKey:@"hadAppeared"];
        _orderedData.article.entityWordInfoDict = dict;
        [_orderedData.article save];
        //[[SSModelManager sharedManager] save:nil];
        
        [self sendEvent4EntityWordWithLabel:kEvent4EntityWord_listShow];
        // NSLog(@">>>>>>> entityInfoDict : %@", entityInfoDict);
    }
}

#pragma mark - Action

- (void)relatedArticleButtonPressed:(id)sender
{
    NSString *openPageURLStr = [_orderedData.article.entityWordInfoDict valueForKey:kEntityScheme];
    if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openPageURLStr]]) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPageURLStr]];
    }
    
    [self sendEvent4EntityWordWithLabel:kEvent4EntityWord_listClick];
}

- (void)listEntityWordLikeAction
{
    NSDictionary *dict = _orderedData.article.entityWordInfoDict;
    
    // 同步后台
    NSString *likeStatus = ([[dict valueForKey:kEntityFollowed] integerValue] == 1) ? @"0" : @"1";
    
    NSString * url = [CommonURLSetting listEntityWordCareURLString];
    if ([likeStatus isEqualToString:@"0"]) {
        url = [CommonURLSetting listEntityWordDiscareURLString];
    }
    
    NSString * concernID = [dict tt_stringValueForKey:kEntityConcernID];
    if (!isEmptyString(concernID)) {
        [[TTNetworkManager shareInstance] requestForBinaryWithURL:url
                                                           params:@{kEntityConcernID:concernID}
                                                           method:@"POST"
                                                 needCommonParams:YES
                                                         callback:^(NSError *error, id obj) {
                                                             
                                                             if (!error) { // Success
                                                                 [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:concernID
                                                                                                                  actionType:[likeStatus integerValue] == 1?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                                                                                    itemType:TTFollowItemTypeDefault
                                                                                                                    userInfo:nil];
                                                                 Article *article = _orderedData.article;
                                                                 NSMutableDictionary *originDict = [NSMutableDictionary dictionaryWithDictionary:article.entityWordInfoDict];
                                                                 originDict[kEntityFollowed] = ([likeStatus integerValue] == 1) ? @(1) : @(0);
                                                                 article.entityWordInfoDict = originDict;
                                                                 [article save];
                                                                 //[[SSModelManager sharedManager] save:nil];
                                                             }
                                                         }];
    }
    
    // 事件统计
    NSString *label = ([likeStatus integerValue] == 1) ? kEvent4EntityWord_listLike : kEvent4EntityWord_listUnlike;
    [self sendEvent4EntityWordWithLabel:label];
}

- (void)heartButtonPressed:(id)sender
{
    _heartButton.selected = !_heartButton.selected;
    //    _heartButton.titleLabel.font = [UIFont systemFontOfSize:_heartButton.selected ? 10 : 12];
    
//    if (_heartButton.selected && [TTFirstConcernManager firstTimeGuideEnabled]) {
//        TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//        __weak typeof(self) wself = self;
//        [manager showFirstConcernAlertViewWithDismissBlock:^{
//            __strong typeof(wself) self = wself;
//            [self listEntityWordLikeAction];
//        }];
//    }
//    else {
        [self listEntityWordLikeAction];
//    }
}

- (void)sendEvent4EntityWordWithLabel:(NSString *)label
{
    if (isEmptyString(label)) {
        return;
    }
    
    // label : list_show, list_click, list_like, list_unlike
    // source（category_name）；like（能否关心，1表示可以）；item_id（文章的item_id）；keyword（实体词的名字）
    Article *article = _orderedData.article;
    BOOL isLikeType = [[article.entityWordInfoDict valueForKey:kEntityStyle] integerValue] == TTArticleCellEntityWordViewTypeLike;
    [TTTrackerWrapper eventData:@{@"category": @"umeng",
                           @"tag":      @"like",
                           @"label":    label,
                           @"value":    @(article.uniqueID) ? : @"",
                           @"item_id":  article.groupModel.itemID ? : @"",
                           @"source":   _orderedData.categoryID ? : @"",
                           @"like":     isLikeType ? @"1" : @"0",
                           @"keyword":  [article.entityWordInfoDict valueForKey:kEntityWord] ? : @""
                           }];
}

@end


//
//  TTHashtagRightPicCell.m
//  Article
//
//  Created by lipeilun on 2017/11/2.
//

#import "TTHashtagRightPicCell.h"
#import <TTAlphaThemedButton.h>
#import "TTHashtagCardData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TTArticleCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import <TTLabelTextHelper.h>
#import "TTUISettingHelper.h"
#import "TTArticleCellConst.h"
#import <TTRoute.h>
#import <TTFeedDislikeView.h>
#import "ExploreMixListDefine.h"
#import "ExploreOrderedData+TTAd.h"
#import <JSONAdditions.h>


@interface TTHashtagRightPicCell()
@property (nonatomic, strong) TTHashtagRightPicCellView *hashtagRightPicCellView;
@end

@implementation TTHashtagRightPicCell

+ (Class)cellViewClass {
    return [TTHashtagRightPicCellView class];
}

- (ExploreCellViewBase *)createCellView {
    if (!_hashtagRightPicCellView) {
        _hashtagRightPicCellView = [[TTHashtagRightPicCellView alloc] initWithFrame:self.bounds];
    }
    
    return _hashtagRightPicCellView;
}

- (void)willDisplay {
    [(TTHashtagRightPicCellView *)self.cellView willAppear];
}

- (void)didEndDisplaying {
    [(TTHashtagRightPicCellView *)self.cellView didDisappear];
}
@end


@interface TTHashtagRightPicCellView()
@property (nonatomic, strong) TTAlphaThemedButton *closeButton;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *subtitleLabel;
@property (nonatomic, strong) SSThemedLabel *readLabel;
@property (nonatomic, strong) SSThemedLabel *discussLabel;
@property (nonatomic, strong) TTImageView *rightImageView;
@property (nonatomic, strong) SSThemedView *bottomLineView;
@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) TTHashtagCardData *hashtagData;
@end

@implementation TTHashtagRightPicCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
        [self addSubview:self.readLabel];
        [self addSubview:self.discussLabel];
        [self addSubview:self.rightImageView];
        [self addSubview:self.closeButton];
        [self addSubview:self.bottomLineView];
    }
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    CGSize picSize = [TTArticleCellHelper resizablePicSize:width - kCellLeftPadding - kCellRightPadding];
    return picSize.height + kCellTopPaddingWithRightPic + kCellBottomPaddingWithPic;
}
    
- (id)cellData {
    return self.orderedData;
}

- (void)willAppear {
    NSMutableDictionary *extraParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [extraParams setValue:self.orderedData.categoryID forKey:@"category_name"];
    [extraParams setValue:self.hashtagData.forumModel.concern_id forKey:@"concern_id"];
    [extraParams setValue:self.hashtagData.forumModel.forum_id forKey:@"forum_id"];
    [extraParams setValue:@(self.hashtagData.uniqueID) forKey:@"group_id"];
    [extraParams setValue:@(100375) forKey:@"demand_id"];
    
    [TTTrackerWrapper eventV3:@"topic_show" params:extraParams];
}

- (void)refreshUI {
    CGFloat containerWidth = self.width - kCellLeftPadding - kCellRightPadding;
    CGSize picSize = [TTArticleCellHelper resizablePicSize:containerWidth];
    self.rightImageView.frame = CGRectMake(self.width - kCellRightPadding - picSize.width, kCellTopPaddingWithRightPic, picSize.width, picSize.height);
    
    CGSize titleSize = CGSizeMake(containerWidth - kCellTitleRightPaddingToPic - picSize.width, 0);
    
    NSString *titleStr = self.orderedData.hashtagData.title;
    
    titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kCellTitleLabelFontSize forWidth:titleSize.width forLineHeight:kCellTitleLineHeight constraintToMaxNumberOfLines:kCellTitleLabelMaxLine];
    CGFloat titlePadding = kCellTitleLineHeight - kCellTitleLabelFontSize;
    CGFloat titleRealHeight = titleSize.height - titlePadding;
    CGFloat titleAndSourceHeight = titleRealHeight + kCellInfoBarHeight + kCellTitleBottomPaddingToInfo;

    CGFloat titleY = ceil(kCellTopPaddingWithRightPic + (picSize.height - titleAndSourceHeight) / 2 - titlePadding / 2);
    CGRect titleFrame = CGRectMake(kCellLeftPadding, titleY, titleSize.width, titleSize.height);
    self.titleLabel.frame = titleFrame;
    self.titleLabel.textColor = [self.orderedData.originalData.hasRead boolValue] ? [TTUISettingHelper cellViewHighlightedtTitleColor] : [TTUISettingHelper cellViewTitleColor];
    self.titleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    self.titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    
    //不感兴趣按钮
    CGFloat unInterestedBtnX = 0, unInterestedBtnY = 0;
    CGFloat unInterestedBtnWidth = 60;
    CGFloat unInterestedBtnHeight = 44;
    CGFloat topOfBottom = self.titleLabel.bottom - titlePadding / 2 + kCellInfoBarTopPadding;
    unInterestedBtnX = ceil(self.left + containerWidth - kCellUninterestedButtonWidth / 2 - unInterestedBtnWidth / 2 - self.rightImageView.width);
    unInterestedBtnY = ceil(self.titleLabel.bottom - titlePadding / 2 + kCellInfoBarTopPadding + kCellInfoBarHeight / 2 - unInterestedBtnHeight / 2);
    self.closeButton.frame = CGRectMake(unInterestedBtnX, unInterestedBtnY, unInterestedBtnWidth, unInterestedBtnHeight);
    
    CGFloat midPaddingForInfos = 8;
    CGFloat maxInfoWidth = self.closeButton.left + 12 - self.titleLabel.left;//底部最大宽度
    NSString *subtitle = !isEmptyString([self.hashtagData forumModel].label) ? [self.hashtagData forumModel].label : @"话题";
    CGFloat subtitleWidth = [self calStringRealWidth:subtitle];
    CGFloat readWidth = [self calStringRealWidth:self.readLabel.text];
    CGFloat talkWidth = [self calStringRealWidth:self.discussLabel.text];
    if (subtitleWidth + readWidth + talkWidth + 2 * midPaddingForInfos > maxInfoWidth) {
        subtitleWidth = maxInfoWidth - readWidth - talkWidth - 2 * midPaddingForInfos;
    }
    
    CGFloat labelY = topOfBottom + floor((kCellInfoBarHeight - kCellTypeLabelHeight) / 2);
    self.subtitleLabel.frame = CGRectMake(self.titleLabel.left, labelY, subtitleWidth, kCellTypeLabelHeight);
    self.readLabel.frame = CGRectMake(self.subtitleLabel.right + midPaddingForInfos, labelY, readWidth, kCellTypeLabelHeight);
    self.discussLabel.frame = CGRectMake(self.readLabel.right + midPaddingForInfos, labelY, talkWidth, kCellTypeLabelHeight);
    
    self.bottomLineView.frame = CGRectMake(kCellLeftPadding, self.height - [TTDeviceHelper ssOnePixel], containerWidth, [TTDeviceHelper ssOnePixel]);
    if ([(ExploreOrderedData *)self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
        self.bottomLineView.hidden = YES;
    } else {
        self.bottomLineView.hidden = NO;
    }
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    
    if ([self.orderedData.originalData isKindOfClass:[TTHashtagCardData class]]) {
        self.hashtagData = (TTHashtagCardData *)self.orderedData.originalData;
    } else {
        self.hashtagData = nil;
        return;
    }
    
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:self.hashtagData.title fontSize:kCellTitleLabelFontSize lineHeight:kCellTitleLineHeight lineBreakMode:NSLineBreakByTruncatingTail];
    [self.titleLabel setAttributedText:titleAttributedStr];
    NSString *subtitle = !isEmptyString([self.hashtagData forumModel].label) ? [self.hashtagData forumModel].label : @"话题";
    self.subtitleLabel.text =  [subtitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.readLabel.text = [[self generationShowingTextCount:[[self.hashtagData forumModel] read_count]] stringByAppendingString:@"阅读"];
    self.discussLabel.text = [[self generationShowingTextCount:[[self.hashtagData forumModel] talk_count]] stringByAppendingString:@"讨论"];
    
    if (!isEmptyString([[self.hashtagData forumModel] banner_url])) {
        [self.rightImageView setImageWithURLString:[[self.hashtagData forumModel] banner_url]];
    }
}

- (void)themeChanged:(NSNotification*)notification {
    [super themeChanged:notification];
    
    self.titleLabel.textColor = [self.orderedData.originalData.hasRead boolValue] ? [TTUISettingHelper cellViewHighlightedtTitleColor] : [TTUISettingHelper cellViewTitleColor];
    self.titleLabel.highlightedTextColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    self.titleLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

- (CGFloat)calStringRealWidth:(NSString *)str {
    return ceil([str sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}].width);

}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    NSURL *url = [NSURL URLWithString:self.hashtagData.forumModel.schema];
    NSMutableDictionary *extraParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [extraParams setValue:self.orderedData.categoryID forKey:@"category_name"];
    [extraParams setValue:self.hashtagData.forumModel.concern_id forKey:@"concern_id"];
    [extraParams setValue:self.hashtagData.forumModel.forum_id forKey:@"forum_id"];
    [extraParams setValue:@(self.hashtagData.uniqueID) forKey:@"group_id"];
    [extraParams setValue:@(100375) forKey:@"demand_id"];

    [TTTrackerWrapper eventV3:@"topic_click" params:extraParams];
    
    NSMutableDictionary *routeDict = [NSMutableDictionary dictionary];
    [routeDict setValue:@(self.hashtagData.uniqueID) forKey:@"group_id"];
    [routeDict setValue:[self.orderedData.logPb tt_JSONRepresentation] forKey:@"gd_ext_json"];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(routeDict)];
        self.orderedData.originalData.hasRead = @(YES);
        [self.orderedData.originalData save];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.titleLabel.textColor = [self.orderedData.originalData.hasRead boolValue] ? [TTUISettingHelper cellViewHighlightedtTitleColor] : [TTUISettingHelper cellViewTitleColor];
        });
    }
}

- (void)onClickCloseButton:(TTAlphaThemedButton *)sender {
    [TTFeedDislikeView dismissIfVisible];
    
    NSMutableDictionary *extraParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [extraParams setValue:self.hashtagData.forumModel.concern_id forKey:@"concern_id"];
    [extraParams setValue:self.hashtagData.forumModel.forum_id forKey:@"forum_id"];
    wrapperTrackEventWithCustomKeys(@"dislike", @"menu_with_reason", [NSString stringWithFormat:@"%lld", self.hashtagData.uniqueID], nil, extraParams.copy);

    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = nil;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.hashtagData.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = sender.center;
    [dislikeView showAtPoint:point
                    fromView:sender
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 wrapperTrackEventWithCustomKeys(@"dislike", @"confirm_with_reason", [NSString stringWithFormat:@"%lld", self.hashtagData.uniqueID], nil, extraParams.copy);

                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    if (!self.orderedData) {
        return;
    }
    NSArray * filterWords = [view selectedWords];
    NSMutableDictionary * userInfo = @{}.mutableCopy;
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = filterWords;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

#pragma mark - util

- (NSString *)generationShowingTextCount:(NSInteger)number {
    NSString *countStr = [NSString stringWithFormat:@"%ld", number];
    
    if (number >= 10000) {
        countStr = [NSString stringWithFormat:@"%ld万", (long)roundf(number / 10000.0f)];
    }
    
    return countStr;
}

#pragma mark - GET/SET

- (TTAlphaThemedButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _closeButton.imageName = @"add_textpage.png";
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton addTarget:self action:@selector(onClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.clipsToBounds = YES;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (SSThemedLabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[SSThemedLabel alloc] init];
        _subtitleLabel.textColorThemeKey = kColorText3;
        _subtitleLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];

    }
    return _subtitleLabel;
}

- (SSThemedLabel *)readLabel {
    if (!_readLabel) {
        _readLabel = [[SSThemedLabel alloc] init];
        _readLabel.textColorThemeKey = kColorText3;
        _readLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
    }
    return _readLabel;
}

- (SSThemedLabel *)discussLabel {
    if (!_discussLabel) {
        _discussLabel = [[SSThemedLabel alloc] init];
        _discussLabel.textColorThemeKey = kColorText3;
        _discussLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
    }
    return _discussLabel;
}

- (TTImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[TTImageView alloc] init];
        _rightImageView.enableNightCover = YES;
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightImageView.clipsToBounds = YES;
        _rightImageView.backgroundColorThemeKey = kColorBackground3;
    }
    return _rightImageView;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLineView;
}

@end

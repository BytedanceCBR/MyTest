//
//  ExploreDetailNatantUserLikeAndShareView.m
//  Article
//
//  Created by 冯靖君 on 15/6/10.
//
//

#import "ExploreDetailNatantUserLikeAndShareView.h"

#import "SSThemed.h"
#import "TTIndicatorView.h"
#import "FRArchitectureManager.h"
#import "TTThemeManager.h"
#import "TTLabelTextHelper.h"

#define kButtonViewHeight           36.f
#define kItemEdgeMargin             15.f
#define kItemSpace                  6.f
#define kItemTopMargin              12.f
//#define kFriendsLikeLabelMaxWidth   150.0f
#define kFriendsLikeLabelMaxWidth   ([[UIScreen mainScreen] bounds].size.width - 30)

@interface ExploreDetailNatantUserLikeAndShareView ()

@property (nonatomic, strong) UILabel *likeFriendsLabel;
@property (nonatomic, assign) BOOL isDayMod;
@property (nonatomic, assign) ArticleLikeAndShareFlags flag;
@property (nonatomic, strong) ExploreOriginalData *originalData;

@end

@implementation ExploreDetailNatantUserLikeAndShareView

- (instancetype)initWithWidth:(CGFloat)width
{
    if (self = [super init]) {
        CGFloat buttonHeight = kButtonViewHeight;
        if ([TTDeviceHelper isPadDevice]) {
            buttonHeight = 50;
        }
        self.frame = CGRectMake(0, 0, width, buttonHeight + kItemTopMargin * 2);

        TTThemeMode themeMode = [[TTThemeManager sharedInstance_tt] currentThemeMode];
        self.isDayMod = (themeMode == TTThemeModeDay);
        [self reloadThemeUI];
    }
    return self;
}

- (void)refreshWithDetailViewModel:(NewsDetailViewModel *)viewModel
                          showFlag:(ArticleLikeAndShareFlags)flag
{
    self.viewModel = viewModel;
    self.originalData = [[self.viewModel sharedDetailManager] currentArticle];
    self.flag = flag;
    [self refreshUI];
}

- (ArticleLikeAction)likeOriginalDataIfNeeded
{
    BOOL useDig = [[[self.viewModel sharedDetailManager] currentOrderedData] isFeedUGC];
    if (![self.originalData.userLike boolValue]) {
        [self saveLikeOriginalDataState:YES];
        [_userLikeView getImageView].transform = CGAffineTransformIdentity;
        [_userLikeView getImageView].alpha = 1.f;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_userLikeView getImageView].transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            [_userLikeView getImageView].alpha = 0.f;
        } completion:^(BOOL finished){
            [_userLikeView refreshImageViewWithImage:[UIImage themedImageNamed:[self imageViewImageNameForLikeState:[self.originalData.userLike boolValue]]]];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [_userLikeView getImageView].alpha = 1.f;
                [_userLikeView getImageView].transform = CGAffineTransformIdentity;
                [_userLikeView refreshLabelWithText:[[self class] readableStringFromLikeCount:_originalData.likeCount]];
                [_userLikeView refreshLabelWithTextColorString:kColorText4];
            } completion:^(BOOL finished){
            }];
        }];
        if (!useDig) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"将增加推荐此类内容", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
        return ArticleLike;
    }
    else {
        if (useDig) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"您已经赞过", nil)
                                     indicatorImage:nil
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return ArticleDupLike;
        }
        else {
            [self saveLikeOriginalDataState:NO];
            [_userLikeView getImageView].transform = CGAffineTransformIdentity;
            [_userLikeView getImageView].alpha = 1.f;
            [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [_userLikeView getImageView].transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                [_userLikeView getImageView].alpha = 0.f;
            } completion:^(BOOL finished){
                [_userLikeView refreshImageViewWithImage:[UIImage themedImageNamed:[self imageViewImageNameForLikeState:[self.originalData.userLike boolValue]]]];
                [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [_userLikeView getImageView].transform = CGAffineTransformIdentity;
                    [_userLikeView getImageView].alpha = 1.f;
                    [_userLikeView refreshLabelWithText:[[self class] readableStringFromLikeCount:_originalData.likeCount]];
                    [_userLikeView refreshLabelWithTextColor:SSGetThemedColorInArray(@[[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1], [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1]])];
                } completion:^(BOOL finished){
                }];
            }];
            return ArticleUnlike;
        }
    }
}

- (void)saveLikeOriginalDataState:(BOOL)liked {
    if (liked) {
        self.originalData.likeCount = @([self.originalData.likeCount intValue] + 1);
        self.originalData.userLike = @(1);
    }
    else {
        self.originalData.likeCount = @([self.originalData.likeCount intValue] - 1);
        self.originalData.userLike = @(0);
    }
    
    [[SSModelManager sharedManager] save:nil];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self resizeBounds];
}

- (void)refreshUI
{
    if (_flag & ArticleShowLike) {
        [self addSubview:self.userLikeView];
        if (!isEmptyString(self.originalData.likeDesc)) {
            [self addSubview:self.likeFriendsLabel];
        }
    }
    if (_flag & ArticleShowWeixin) {
        [self addSubview:self.shareToWeixinView];
    }
    if (_flag & ArticleShowWeixinMoment) {
        [self addSubview:self.shareToWeixinMomentView];
    }
    
    [self resizeBounds];
}

- (void)resizeBounds
{
    int count = 0;
    if (_flag & ArticleShowLike) {
        count++;
    }
    if (_flag & ArticleShowWeixin) {
        count++;
    }
    if (_flag & ArticleShowWeixinMoment) {
        count++;
    }
    if (count) {
        CGFloat itemWidth = ceilf((self.width - 2 * kItemEdgeMargin - (count - 1) * kItemSpace)/count);
        CGFloat buttonHeight = kButtonViewHeight;
        if ([TTDeviceHelper isPadDevice]) {
            buttonHeight = 50;
        }
        __block UIView *view = self.subviews.firstObject;
        view.frame = CGRectMake(kItemEdgeMargin, kItemTopMargin, itemWidth, buttonHeight);
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull currView, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (currView != _likeFriendsLabel && idx > 0) {
                
                currView.frame = CGRectMake(CGRectGetMaxX(view.frame) + kItemSpace, kItemTopMargin, itemWidth, buttonHeight);
                view = currView;
            }
            
            if (!isEmptyString(self.originalData.likeDesc) && currView == _likeFriendsLabel) {
                [_likeFriendsLabel sizeToFit];
                CGFloat labelHeight = [TTLabelTextHelper heightOfText:_likeFriendsLabel.text fontSize:[[self class] friendsLikeLabelSize] forWidth:kFriendsLikeLabelMaxWidth];
                _likeFriendsLabel.frame = CGRectMake(_userLikeView.left + 4,
                                                     _userLikeView.bottom + 8,
                                                     MIN(_likeFriendsLabel.width, kFriendsLikeLabelMaxWidth),
                                                     labelHeight);
                self.height = _likeFriendsLabel.bottom + kItemTopMargin * 2;
                NSLog(@"self.height=%f",self.height);
            } else {
                self.height = _userLikeView.bottom + kItemTopMargin * 2;
                NSLog(@"self.height22=%f",self.height);
            }
        }];
    }
}

#pragma mark - Getter
- (TTRoundrectButtonView *)userLikeView
{
    if (!_userLikeView) {
        NSString *likeCountString = [[self class] readableStringFromLikeCount:_originalData.likeCount];
        NSString *imageName =  [self imageViewImageNameForLikeState:[_originalData.userLike boolValue]];
        _userLikeView = [[TTRoundrectButtonView alloc] initWithFrame:CGRectZero
                                                                text:likeCountString
                                                               image:[UIImage themedImageNamed:imageName]];
        NSString *textColorKey = [_originalData.userLike boolValue] ? kColorText4 : kColorText3;
        [_userLikeView refreshLabelWithTextColorString:textColorKey];
    }
    return _userLikeView;
}

- (UILabel *)likeFriendsLabel
{
    if (!_likeFriendsLabel) {
        _likeFriendsLabel = [[UILabel alloc] init];
        _likeFriendsLabel.backgroundColor = [UIColor clearColor];
        _likeFriendsLabel.font = [UIFont systemFontOfSize:[[self class] friendsLikeLabelSize]];
        _likeFriendsLabel.textColor = SSGetThemedColorInArray(@[[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1], [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1]]);
        _likeFriendsLabel.numberOfLines = 3;
        _likeFriendsLabel.text = _originalData.likeDesc;
    }
    return _likeFriendsLabel;
}

- (TTRoundrectButtonView *)shareToWeixinView
{
    if (!_shareToWeixinView) {
        _shareToWeixinView = [[TTRoundrectButtonView alloc] initWithFrame:CGRectZero
                                                                     text:@"微信"
                                                                    image:[UIImage themedImageNamed:@"new_weixin_details.png"]];
    }
    return _shareToWeixinView;
}

- (TTRoundrectButtonView *)shareToWeixinMomentView
{
    if (!_shareToWeixinMomentView) {
        _shareToWeixinMomentView = [[TTRoundrectButtonView alloc] initWithFrame:CGRectZero
                                                                           text:@"朋友圈"
                                                                          image:[UIImage themedImageNamed:@"new_pyq_details.png"]];
    }
    return _shareToWeixinMomentView;
}

#pragma mark - Themed

- (void)themeChanged:(NSNotification *)notification
{
    NSString *imageName = [self imageViewImageNameForLikeState:[_originalData.userLike boolValue]];
    [_userLikeView refreshImageViewWithImage:[UIImage themedImageNamed:imageName]];
    [_shareToWeixinView refreshImageViewWithImage:[UIImage themedImageNamed:@"new_weixin_details.png"]];
    [_shareToWeixinMomentView refreshImageViewWithImage:[UIImage themedImageNamed:@"new_weixin_details.png"]];
    _likeFriendsLabel.textColor = SSGetThemedColorInArray(@[[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1], [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1]]);
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
}

#pragma mark - Track

- (void)sendShowTrackIfNeededForGroup:(NSString *)groupID withLabel:(NSString *)label
{
    if (!self.hasShown && (_flag & ArticleShowLike)) {
        [super sendShowTrackIfNeededForGroup:groupID withLabel:label];
    }
}

#pragma mark - Helper

- (NSString *)imageViewImageNameForLikeState:(BOOL)liked
{
    BOOL useDig = [[[self.viewModel sharedDetailManager] currentOrderedData] isFeedUGC];
    if (liked) {
        return useDig ? @"goodicon_actionbar_details_press.png" : @"likeicon_actionbar_details_press.png";
    }
    else {
        return useDig ? @"goodicon_actionbar_details.png" : @"likeicon_actionbar_details.png";
    }
}

+ (CGFloat)friendsLikeLabelSize
{
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 12.f;
    }
    else {
        return 10.f;
    }
}

+ (NSString *)readableStringFromLikeCount:(NSNumber *)likeCountNumber
{
    int64_t likeCount = [likeCountNumber longLongValue];
    if (likeCount < 10000) {
        return [likeCountNumber stringValue];
    }
    else if (likeCount < 100000000) {
        return [NSString stringWithFormat:@"%.1f万", (float)likeCount / 10000.0f];
    }
    else {
        return [NSString stringWithFormat:@"%.1f亿", (float)likeCount / 100000000.0f];
    }
}

@end

//
//  NewsDetailNoCommentShareView.m
//  Article
//
//  Created by Zhang Leonardo on 14-7-11.
//
//

#import "NewsDetailNoCommentShareView.h"
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "TTActivity.h"

@interface NewsDetailNoCommentShareViewButton()
@property(nonatomic, retain, readwrite)UIButton * actionButton;
@property(nonatomic, retain)NSString * title;
@property(nonatomic, retain)NSString * imgName;
@property(nonatomic, retain)NSString * pImgName;
@end

@implementation NewsDetailNoCommentShareViewButton

- (void)dealloc
{
    self.title = nil;
    self.imgName = nil;
    self.pImgName = nil;
    self.actionButton = nil;
}

- (id)initWithTitle:(NSString *)title imageName:(NSString *)imgName pressImageName:(NSString *)pImgName
{
    CGRect frame = CGRectMake(0, 0, 75, 80);
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        self.imgName = imgName;
        self.pImgName = pImgName;
        
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_actionButton];
        [_actionButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_actionButton setTitle:_title forState:UIControlStateNormal];
        
        
        [self reloadThemeUI];
        [self refreshButtonContentInset];
    }
    return self;
}

- (void)refreshButtonContentInset
{
    [_actionButton sizeToFit];
    CGFloat actionButtonSpacing = 5.0;
    CGSize actionButtonImageSize = _actionButton.imageView.frame.size;
    [_actionButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -actionButtonImageSize.width, -(actionButtonImageSize.height+actionButtonSpacing), 0)];
    CGSize actionButtonTitleSize = _actionButton.titleLabel.frame.size;
    [_actionButton setImageEdgeInsets:UIEdgeInsetsMake(-(actionButtonTitleSize.height+actionButtonSpacing), 0, 0, -actionButtonTitleSize.width)];
    _actionButton.frame = self.bounds;
}

- (void)refreshTitle:(NSString *)title imgName:(NSString *)imgName pressImgName:(NSString *)pImgName
{
    self.title = title;
    self.imgName = imgName;
    self.pImgName = pImgName;
    [_actionButton setTitle:_title forState:UIControlStateNormal];
    [self reloadThemeUI];
    [self refreshButtonContentInset];
}

- (void)themeChanged:(NSNotification *)notification
{
    [_actionButton setImage:[UIImage themedImageNamed:_imgName] forState:UIControlStateNormal];
    [_actionButton setImage:[UIImage themedImageNamed:_pImgName] forState:UIControlStateHighlighted];
    [_actionButton setTitleColor:[UIColor colorWithHexString:SSUIString(@"SSActivityTitleColor", @"303030")] forState:UIControlStateNormal];
    [_actionButton setTitleColor:[UIColor colorWithHexString:SSUIString(@"NewsDetailNoCommentShareViewButtonHighlightColor", @"3030307f")] forState:UIControlStateHighlighted];
}

@end

@interface NewsDetailNoCommentShareView()<UIGestureRecognizerDelegate, TTActivityDelegate>
@property(nonatomic, retain)UITapGestureRecognizer *tapRecognizer;
@property(nonatomic, retain)UISwipeGestureRecognizer *swipeRecognizer;
@property(nonatomic, retain)UIView *maskView;
@property(nonatomic, retain)UIButton *closeButton;
@property(nonatomic, retain)UIView * topDivedeLineView;
@property(nonatomic, retain)UIView * bottomDivideLineView;
@property(nonatomic, retain)TTActivityShareManager * activityActionManager;
@property(nonatomic, retain)Article * article;
@property(nonatomic, retain)NSMutableArray * activityItems;
@property(nonatomic, retain)NSNumber * adID;

@property(nonatomic, retain)NSArray * sharePlatformButtons;

@property(nonatomic, retain)UIScrollView * sharePlatformContainer;

@end

@implementation NewsDetailNoCommentShareView

- (void)dealloc
{
    self.adID = nil;
    self.activityItems = nil;
    self.article = nil;
    self.activityActionManager = nil;
    self.sharePlatformContainer = nil;
    self.sharePlatformContainer = nil;
    self.favoriteButton = nil;
    self.fontButton = nil;
    self.notInterestButton = nil;
    self.reportButton = nil;
    self.topDivedeLineView = nil;
    self.bottomDivideLineView = nil;
    self.closeButton = nil;
    
    [_maskView removeGestureRecognizer:_tapRecognizer];
    self.tapRecognizer = nil;
    
    [_maskView removeGestureRecognizer:_swipeRecognizer];
    self.swipeRecognizer = nil;
    
    self.maskView = nil;
    

}

- (id)initWithFrame:(CGRect)frame article:(Article *)article adID:(NSNumber *)adID
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adID = adID;
        self.article = article;
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:SSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        _closeButton.frame = CGRectMake(0, frame.size.height - 53, SSWidth(self), 53);
        [_closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
        [self addSubview:_closeButton];

        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        
        self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.alpha = .35f;
        [_maskView addGestureRecognizer:_tapRecognizer];
        
        self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp;
        _swipeRecognizer.delegate = self;
        [_maskView addGestureRecognizer:_swipeRecognizer];
        

        self.bottomDivideLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_closeButton.frame) - 1, SSWidth(self), [SSCommon ssOnePixel])];
        [self addSubview:_bottomDivideLineView];
        
        self.favoriteButton = [[NewsDetailNoCommentShareViewButton alloc] initWithTitle:SSLocalizedString(@"加入收藏", nil) imageName:@"love_popover.png" pressImageName:@"love_popover_press.png"];
        [self addSubview:_favoriteButton];
        setFrameWithOrigin(_favoriteButton, 5, CGRectGetMinY(_bottomDivideLineView.frame) - SSHeight(_favoriteButton) - 17);
        float butPadding = 0;
        self.fontButton = [[NewsDetailNoCommentShareViewButton alloc] initWithTitle:SSLocalizedString(@"显示设置", nil) imageName:@"show_popover.png" pressImageName:@"show_popover_press.png"];
        [self addSubview:_fontButton];
        setFrameWithOrigin(_fontButton, CGRectGetMaxX(_favoriteButton.frame) + butPadding, CGRectGetMinY(_favoriteButton.frame));
        
        self.notInterestButton = [[NewsDetailNoCommentShareViewButton alloc] initWithTitle:SSLocalizedString(@"不感兴趣", nil) imageName:@"dislike_popover.png" pressImageName:@"dislike_popover_press.png"];
        [self addSubview:_notInterestButton];
        setFrameWithOrigin(_notInterestButton, CGRectGetMaxX(_fontButton.frame) + butPadding, CGRectGetMinY(_fontButton.frame));
        
        self.reportButton = [[NewsDetailNoCommentShareViewButton alloc] initWithTitle:SSLocalizedString(@"举报", nil) imageName:@"report_popover.png" pressImageName:@"show_popover_press.png"];
        [self addSubview:_reportButton];
        setFrameWithOrigin(_reportButton, CGRectGetMaxX(_notInterestButton.frame) + butPadding, CGRectGetMinY(_notInterestButton.frame));
        
        self.topDivedeLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_favoriteButton.frame) - 20 - 1, SSWidth(self), [SSCommon ssOnePixel])];
        [self addSubview:_topDivedeLineView];
        
        self.sharePlatformContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self), 117)];
        _sharePlatformContainer.showsHorizontalScrollIndicator = NO;
        _sharePlatformContainer.showsVerticalScrollIndicator = NO;
        _sharePlatformContainer.scrollEnabled = YES;
        _sharePlatformContainer.scrollsToTop = NO;
        [self addSubview:_sharePlatformContainer];
        
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:_article adID:_adID];
        CGRect itemFrame = CGRectMake(12, 20, 60, 80);
        for (int i = 0; i < [_activityItems count]; i ++) {
            TTActivity * activity = [_activityItems objectAtIndex:i];
            activity.delegate = self;
            activity.frame = itemFrame;
            [_sharePlatformContainer addSubview:activity];
            if (i != [_activityItems count] - 1) {
                itemFrame.origin.x = CGRectGetMaxX(itemFrame) + 15;
            }
        }
        
        _sharePlatformContainer.contentSize = CGSizeMake(CGRectGetMaxX(itemFrame) + 23, SSHeight(_sharePlatformContainer));
        
        [self reloadThemeUI];

    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    [_closeButton setTitleColor:[UIColor colorWithHexString:SSUIString(@"detailViewFunctionCloseButtonTextColor", @"505050")] forState:UIControlStateNormal];
    _bottomDivideLineView.backgroundColor = [UIColor colorWithHexString:SSUIString(@"NewsDetailNoCommentShareViewDivideViewColor", @"dddddd")];
    _topDivedeLineView.backgroundColor = [UIColor colorWithHexString:SSUIString(@"NewsDetailNoCommentShareViewDivideViewColor", @"dddddd")];
    _maskView.backgroundColor = [UIColor colorWithHexString:SSUIString(@"detailViewFunctionMaskViewBackgroundColor", @"000000")];
    
    [self refreshFavoriteButton];
}

- (void)refreshFavoriteButton
{
    if ([_article.userRepined boolValue]) {
        [_favoriteButton refreshTitle:SSLocalizedString(@"取消收藏", nil) imgName:@"loved_popover.png" pressImgName:@"loved_popover_press.png"];
    }
    else {
        [_favoriteButton refreshTitle:SSLocalizedString(@"加入收藏", nil) imgName:@"love_popover.png" pressImgName:@"love_popover_press.png"];
    }
}

- (void)refreshNotInterestButton
{
    if ([[_article notInterested] boolValue]) {
        [_notInterestButton refreshTitle:SSLocalizedString(@"取消不感兴趣", nil) imgName:@"dislike_popover.png" pressImgName:@"dislike_popover_press.png"];
    }
    else {
        [_notInterestButton refreshTitle:SSLocalizedString(@"不感兴趣", nil) imgName:@"dislike_popover.png" pressImgName:@"dislike_popover_press.png"];
    }
}


- (void)tapped:(UIGestureRecognizer*)recognizer
{
    [self dismiss];
}

- (void)swiped:(UIGestureRecognizer*)recognizer
{
    [self dismiss];
}
- (void)close:(id)sender
{
    [self dismiss];
}


- (void)showInView:(UIView*)view atPoint:(CGPoint)point
{
    if (_sharePlatformContainer.contentOffset.x != 0) {
        _sharePlatformContainer.contentOffset = CGPointMake(0, 0);
    }
    [self refreshNotInterestButton];
    [self refreshFavoriteButton];
    setFrameWithOrigin(self, 0, SSHeight(view));
    _maskView.frame = view.bounds;
    [view addSubview:_maskView];
    [view addSubview:self];
    [UIView animateWithDuration:.25 animations:^{
        setFrameWithOrigin(self, point.x, point.y);
    } completion:^(BOOL finished) {
        _isDisplay = YES;
    }];
}

- (void)dismiss
{
    UIView *superview = [self superview];
    [_maskView removeFromSuperview];
    if(superview)
    {
        [UIView animateWithDuration:.25 animations:^{
            
            setFrameWithOrigin(self, 0, SSHeight(superview));
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            _isDisplay = NO;
        }];
    }
}


#pragma mark -- SSActivityDelegate

- (void)activity:(TTActivity *)activity activityButtonClicked:(TTActivityType)type
{
    [self dismiss];
    NSString *groupId = [NSString stringWithFormat:@"%lld", [self.article.uniqueID longLongValue]];
    [_activityActionManager performActivityActionByType:type inViewController:[SSCommon topViewControllerFor:self] sourceObjectType:TTShareSourceObjectTypeArticle uniqueId:groupId adID:nil platform:TTSharePlatformTypeOfMain groupFlags:self.article.groupFlags];
}

@end

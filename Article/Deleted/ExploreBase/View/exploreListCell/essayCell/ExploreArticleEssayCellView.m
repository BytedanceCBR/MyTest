//
//  ExploreArticleEssayCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-16.
//
//

#import "ExploreArticleEssayCellView.h"
#import "EssayData.h"

#import "MTLabel.h"
#import "NewsUserSettingManager.h"

#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTPhotoScrollViewController.h"
#import "TTArticleCategoryManager.h" //kTTMainCategoryID
#import "ArticleEssayActionButton.h"
#import "ExploreItemActionManager.h"
#import "ExploreDetailToolbarView.h"

#import "SSActivityView.h"
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "ExploreArticleEssayCellCommentView.h"
#import "SSThemed.h"
#import "NewsDetailLogicManager.h"
#import "ExploreListIItemDefine.h"
#import "TTCategoryDefine.h"
#import "ExploreCellRecomUserHeaderView.h"
#import "TTNavigationController.h"
#import "TTIndicatorView.h"
#import "TTReportManager.h"
#import "TTUISettingHelper.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIImage+TTThemeExtension.h"
#import "TTActionSheetController.h"
#import "NSObject+FBKVOController.h"
#import "NewsBaseDelegate.h"
#import "ArticleTabBarStyleNewsListViewController.h"
#import "TTExploreMainViewController.h"
#import "TTTopBar.h"
#import "EssayDetailViewController.h"
#import <TTInteractExitHelper.h>

#define kMaxEssayImageHeight (2 * [TTUIResponderHelper screenSize].height)
#define kTitleLabel (NSLocalizedString(@"内涵段子", nil))

//#define kFeedCategoryId @"fake"//kTTMainCategoryID

#define kHeaderViewStyleAlignTopHeight 24
//#define kHeaderViewTopPading 11
//#define kFooterViewBottomPading 11
#define kContentTopGap 16

#define SHOW_INFOBAR 0

#define kHasLine 1

#define kActionButtonBarGapY   3
#define kDigAndBuryIconGap (self.width * 0.1375)

@interface ExploreArticleEssayCellView ()<SSActivityViewDelegate, ExploreArticleEssayCellCommentViewDelegate>

@property(nonatomic, strong) MTLabel *contentLabel;
@property(nonatomic, strong) UIImageView *jagView;

@property (nonatomic, retain) ArticleEssayActionButton *diggButton;
@property (nonatomic, retain) ArticleEssayActionButton *buryButton;
@property (nonatomic, retain) ArticleEssayActionButton *favouriteButton;
@property (nonatomic, retain) ArticleEssayActionButton *shareButton;
@property (nonatomic, retain) ArticleEssayActionButton *commentButton;

@property (nonatomic, retain) ExploreItemActionManager * itemActionManager;
@property (nonatomic, retain) TTActivityShareManager *activityActionManager;
@property (nonatomic, retain) SSActivityView * phoneShareView;

 // 神评论
@property (nonatomic, retain) ExploreArticleEssayCellCommentView *godCommentView;
@property (nonatomic, retain) NSArray *godCommentItems;

@property(nonatomic,strong)SSThemedView *headerSepView;
@property(nonatomic,strong)SSThemedView *footerSepView;
@property(nonatomic,strong)ExploreCellRecomUserHeaderView *headerView;

@property(nonatomic, strong)UIView *sepLineView;
@property(nonatomic, strong)UIView *bottomView;

#if kHasLine
@property(nonatomic,strong)SSThemedView *topLine;
@property(nonatomic,strong)SSThemedView *topLine2;
@property(nonatomic,strong)SSThemedView *bottomLine;
@property(nonatomic,strong)SSThemedView *bottomLine2;
@property(nonatomic,strong)SSThemedView *leftLine;
@property(nonatomic,strong)SSThemedView *rightLine;
#endif
@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@end


@implementation ExploreArticleEssayCellView

- (void)dealloc {
    //[self unregisterEssayDataActionKVOIfNecessary];
}

- (MTLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[MTLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        CGFloat titleFontSize;
        CGFloat lineH;
        if (self.from == EssayCellStyleList) {
            titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
            lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
            _contentLabel.fontColor = [TTUISettingHelper cellViewTitleColor];
        }
        else{
            titleFontSize = [NewsUserSettingManager settedEssayDetailViewTextFontSize];
            lineH = [NewsUserSettingManager settedEssayDetailViewTextFontLineHeight];
            _contentLabel.fontColor = [UIColor tt_themedColorForKey:kColorText2];
        }
        if ([TTDeviceHelper isPadDevice]) {
            _contentLabel.font = [UIFont boldSystemFontOfSize:titleFontSize];
        }
        else {
            _contentLabel.font = [UIFont systemFontOfSize:titleFontSize];
        }
        _contentLabel.lineHeight = lineH;
        [_contentLabel setContentMode:UIViewContentModeRedraw];
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (void)updateContentColor
{
    if([self.orderedData hasRead])
    {
        _contentLabel.fontColor = [UIColor tt_themedColorForKey:kColorText3];
    }
    else
    {
        _contentLabel.fontColor = [TTUISettingHelper cellViewTitleColor];
    }
}

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColorThemeKey = kColorBackground2;
        [_imageView setImageContentMode:TTImageViewContentModeScaleAspectFillRemainTop];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(contentImageSingleTapRecognizer:)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [_imageView addGestureRecognizer:singleTap];

        [self addSubview:_imageView];
        
        UIImage *jagImage = [UIImage themedImageNamed:@"dividing_line.png"];
        
        jagImage = [self tiledImage:jagImage];
        
        _jagView = [[UIImageView alloc] initWithImage:jagImage];
    }
    return _imageView;
}

- (UIImage *)tiledImage:(UIImage *)img
{
    UIImage *tiledImg;
    if ([img respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        tiledImg = [img resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    } else {
        tiledImg = [img resizableImageWithCapInsets:UIEdgeInsetsZero];
    }
    return tiledImg;
}

- (void)contentImageSingleTapRecognizer:(UITapGestureRecognizer *)sender
{
    if (self.from == EssayCellStyleList) {
        wrapperTrackEvent(@"image", @"enter_essay_list");
    } else if (self.from == EssayCellStyleDetail) {
        wrapperTrackEvent(@"image", @"enter_essay_detail");
    }

    EssayData *essay = self.orderedData.essayData?:self.essayData;
    TTPhotoScrollViewController * controller = [[TTPhotoScrollViewController alloc] init];
    controller.targetView = self.imageView;
    TTImageInfosModel *tImage = [essay largeImageModel];
    if (tImage) {
        controller.imageInfosModels = [NSArray arrayWithObject:tImage];
    }
    UIImageView *imageView = self.imageView.imageView;
    if (imageView && imageView.image) {
        CGRect frame = [sender.view convertRect:imageView.frame toView:nil];
        CGFloat topBarHeight = 0;
        CGFloat bottomBarHeight = 0;
        if (self.essayData) { // 详情页
            UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
            topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + nav.navigationBar.height;
            bottomBarHeight = ExploreDetailGetToolbarHeight();
        } else { // 列表页
            if ([TTDeviceHelper isPadDevice]) {
                UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
                topBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + nav.navigationBar.height + 44; //TTTabbar高度
            } else {
                [[UIApplication sharedApplication] delegate];
                TTExploreMainViewController *mainListView = [(NewsBaseDelegate *)[[UIApplication sharedApplication] delegate] exploreMainViewController];
                topBarHeight = mainListView.topBar.height;
                bottomBarHeight = mainListView.tabBarController.tabBar.height;
            }
        }
        controller.dismissMaskInsets = UIEdgeInsetsMake(topBarHeight, 0, bottomBarHeight, 0); //点击关闭动画时候的边距
        controller.placeholders = @[imageView.image];
        controller.placeholderSourceViewFrames = @[[NSValue valueWithCGRect:frame]];
        controller.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
        controller.targetView = self;
    }
    
    [controller presentPhotoScrollView];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:EssayViewContentImageSingleTapNotification
//                                                        object:self
//                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_dataIndex]
//                                                                                           forKey:kEssayViewDataIndexKey]];
}

- (void)updatePic:(EssayData *)essay
{
    TTImageInfosModel *imageModel = essay.largeImageModel;
    if (imageModel) {
        [self.imageView setImageWithModel:imageModel placeholderImage:nil];
        _hasImage = YES;
    } else {
        [self.imageView setImageWithModel:nil];
        _hasImage = NO;
    }
}

- (void)layoutPic
{
    CGFloat imageHeight = 0.f;
    CGFloat imageWidth = self.width - kCellLeftPadding - kCellRightPadding;
    BOOL bClipped = NO;
    
    TTImageInfosModel *imageModel = self.imageView.model;
    
    if (imageModel && imageModel.width > 0) {
        imageHeight = (imageWidth * imageModel.height) / imageModel.width;
        bClipped = [[self class] clipLongImage:self.orderedData imageWidth:imageWidth clippedImageHeight:&imageHeight];
    }
    CGFloat titleFontSize;
    CGFloat lineH;
    if (self.from == EssayCellStyleList) {
        titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
    }
    else{
        titleFontSize = [NewsUserSettingManager settedEssayDetailViewTextFontSize];
        lineH = [NewsUserSettingManager settedEssayDetailViewTextFontLineHeight];
    }
    CGFloat y;
    if (self.contentLabel.height != 0) {
        y = self.contentLabel.bottom - (lineH - titleFontSize) + 3 + cellPaddingY();
    }
    else {
        y = self.contentLabel.bottom + cellPaddingY();
    }
    
    self.imageView.frame = CGRectMake(kCellLeftPadding, y, imageWidth, ceilf(imageHeight));
    
    if (bClipped) {
        _jagView.frame = CGRectMake(kJagViewLeftPadding, self.imageView.bottom - _jagView.height + 1, self.width - 2 * kJagViewLeftPadding, _jagView.height);
        if (_jagView.superview == nil) {
            [self addSubview:_jagView];
        }
    } else {
        [_jagView removeFromSuperview];
    }
}

- (void)updateCommentView
{
    EssayData *essay = self.orderedData.essayData;
    
    if (essay.godComments.count > 0 && [ExploreCellHelper shouldDisplayEssayGodComment:essay listType:self.listType]) {
        self.godCommentItems = [essay godCommentObjArray];
    } else {
        self.godCommentItems = nil;
    }
    
    if (self.godCommentItems.count > 0) {
        self.hasCommentView = NO; // 不显示普通评论
        
        if (self.godCommentView == nil) {
            self.godCommentView = [[ExploreArticleEssayCellCommentView alloc] initWithFrame:CGRectZero];
            self.godCommentView.delegate = self;
            [self addSubview:self.godCommentView];
        }
        [self.godCommentView refreshWithComments:self.godCommentItems viewWidth:self.width - kCellLeftPadding - kCellRightPadding];
    } else {
        self.hasCommentView = [ExploreCellHelper shouldDisplayEssayComment:essay listType:self.listType];
        [self.godCommentView removeFromSuperview];
        self.godCommentView = nil;
    }
    
    if (self.hasCommentView) {
        if (self.commentView.superview == nil) {
            self.commentView.delegate = self;
            [self addSubview:self.commentView];
        }
        [self.commentView reloadCommentDict:essay.comment cellWidth:self.width];
    }
    else
    {
        [self removeCommentView];
    }
}

//- (void)updateTimeLabel
//{
//    double time = [self.orderedData.essayData.createTime doubleValue];
//    NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
//    
//    NSString *publishTime =  [NSString stringWithFormat:@"%@", midnightInterval > 0 ?
//                              [TTDeviceHelper customtimeStringSince1970:time midnightInterval:midnightInterval] :
//                              [TTDeviceHelper customtimeStringSince1970:time]];
//    
//    self.timeLabel.text = publishTime;
//}

- (void)updateTitleLabel
{
    //self.titleLabel.text = kTitleLabel;
    [self updateContentColor];
}

- (void)updateHeaderView
{
    if (!self.headerView) {
        BOOL isPad = [TTDeviceHelper isPadDevice];
        
        self.headerView = [[ExploreCellRecomUserHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.width, kHeaderViewStyleAlignTopHeight)];
        [self addSubview:self.headerView];
        self.headerView.userInteractionEnabled = NO;
        
        self.headerSepView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [self.class viewTopPadding])];
        self.headerSepView.backgroundColorThemeKey = (isPad ? kColorBackground4 : kColorBackground3);
        [self addSubview:self.headerSepView];
        
        self.footerSepView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [self.class viewBottomPadding])];
        self.footerSepView.backgroundColorThemeKey = (isPad ? kColorBackground4 : kColorBackground3);
        [self addSubview:self.footerSepView];
        
        _topLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _topLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_topLine];
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLine];
        
        _topLine2 = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _topLine2.backgroundColorThemeKey = kColorLine7;
        [self addSubview:_topLine2];
        _bottomLine2 = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLine2.backgroundColorThemeKey = kColorLine7;
        [self addSubview:_bottomLine2];
        
        _leftLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _leftLine.backgroundColorThemeKey = kColorLine7;
        [self addSubview:_leftLine];
        
        _rightLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _rightLine.backgroundColorThemeKey = kColorLine7;
        [self addSubview:_rightLine];
    }
    [self.headerView setTitle:nil prefixStr:kTitleLabel headStyle:ExploreCardCellHeaderStyleAlignTop];
}

// 列表用
- (void)refreshWithData:(id)data
{
    //[self unregisterEssayDataActionKVOIfNecessary];

    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }

    //[self registerEssayDataActionKVOIfNecessay];
    self.bottomLineView.hidden = YES;
    self.leftLine.hidden = YES;
    self.rightLine.hidden = YES;
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        EssayData *essay = self.orderedData.essayData;
        if (essay) {
            if (![self shouldShowActionButtons]) {
                //[self updateTitleLabel];
                [self updateHeaderView];
                self.headerView.hidden = NO;
                self.headerSepView.hidden = NO;
                self.topLine.hidden = NO;
                self.topLine2.hidden = NO;
                if ((![self.orderedData nextCellHasTopPadding]) ||
                    [TTDeviceHelper isPadDevice]) {
                    self.footerSepView.hidden = NO;
                    if ([TTDeviceHelper isPadDevice]) {
                        self.bottomLine.hidden = YES;
                    } else {
                        self.bottomLine.hidden = NO;
                    }
                    
                    self.bottomLine2.hidden = NO;
                    
                    if ([TTDeviceHelper isPadDevice]) {
                        self.sepLineView.hidden = YES;
                        self.topLine.hidden = YES;
                        
                        self.leftLine.hidden = NO;
                        self.rightLine.hidden = NO;

                    } else {
                        self.sepLineView.hidden = NO;
                        self.topLine.hidden = NO;
                    }

                } else {
                    self.footerSepView.hidden = YES;
                    self.bottomLine.hidden = YES;
                    self.bottomLine2.hidden = YES;

                }
                self.unInterestedButton.hidden = NO;
            } else {
                //self.titleLabel.text = nil;
                self.headerView.hidden = YES;
                self.headerSepView.hidden = YES;
                self.footerSepView.hidden = YES;
                self.topLine.hidden = YES;
                self.topLine2.hidden = YES;
                self.bottomLine.hidden = YES;
                self.bottomLine2.hidden = YES;
                self.unInterestedButton.hidden = YES;

            }
            self.contentLabel.text = essay.content;
            [self updateContentColor];
            [self updatePic:essay];
            
            if ([self shouldShowActionButtons]) {
                [self loadActionButtons];
                [self updateActionButtons:essay];
                
                self.infoBarView.hidden = YES;
            } else {
#if SHOW_INFOBAR
                self.infoBarView.hidden = NO;
#endif
            }
        } else {
            if (![self shouldShowActionButtons]) {
                self.typeLabel.height = 0;
            }
        }
    }
    if (!_sepLineView) {
        _sepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self addSubview:_sepLineView];
    }
    
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        if ([TTDeviceHelper isPadDevice]) {
            _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        }
        [self addSubview:_bottomView];
    }

}

// 详情页用
- (void)refreshWithEssayData:(EssayData *)essay
{
//    [self unregisterEssayDataActionKVOIfNecessary];
    self.essayData = essay;
    if (essay) {
//        [self registerEssayDataActionKVOIfNecessay];
        self.contentLabel.text = essay.content;
        [self updatePic:essay];
    }
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
}

- (void)refreshUIForEssayDetailView
{
    if (self.from == EssayCellStyleList) {
        self.contentLabel.frame = [[self class] frameForContentLabel:self.contentLabel.text cellWidth:self.frame.size.width isList:YES];
    }
    else{
        self.contentLabel.frame = [[self class] frameForContentLabel:self.contentLabel.text cellWidth:self.frame.size.width isList:NO];
    }
    [self layoutPic];
    
//    [self layoutActionButtons];
    self.bottomLineView.hidden = YES;
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

- (void)refreshUI
{
    BOOL hasTitle;

    if (![self shouldShowActionButtons]) {
        hasTitle = YES;
        
        CGFloat topPadding = [self.class viewTopPadding];
        CGFloat bottomPadding = [self.class viewBottomPadding];
        
        self.headerView.frame = CGRectMake(0, topPadding, self.width, kHeaderViewStyleAlignTopHeight);
        self.headerSepView.frame = CGRectMake(0, 0, self.width, topPadding);
        self.footerSepView.frame = CGRectMake(0, self.height - bottomPadding, self.width, bottomPadding);

        self.topLine.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        self.topLine2.frame = CGRectMake(0, topPadding-[TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
        self.bottomLine.frame = CGRectMake(0, self.height-[TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
        self.bottomLine2.frame = CGRectMake(0, self.footerSepView.top, self.width, [TTDeviceHelper ssOnePixel]);
        self.leftLine.frame = CGRectMake(0, self.topLine2.top, [TTDeviceHelper ssOnePixel], self.bottomLine2.bottom-self.topLine2.top);
        self.rightLine.frame = CGRectMake(self.topLine2.right-[TTDeviceHelper ssOnePixel], self.topLine2.top, [TTDeviceHelper ssOnePixel], self.bottomLine2.bottom-self.topLine2.top);
        
        [self.headerView refreshUI];
        [self layoutUnInterestedBtn];
    } else {
        //self.titleLabel.height = 0;
        hasTitle = NO;
    }
    if (self.from == EssayCellStyleList) {
        self.contentLabel.frame = [[self class] frameForContentLabel:self.contentLabel.text cellWidth:self.frame.size.width isList:YES];
    }
    else{
        self.contentLabel.frame = [[self class] frameForContentLabel:self.contentLabel.text cellWidth:self.frame.size.width isList:NO];
    }
    if (hasTitle) {
        self.contentLabel.top = self.headerView.bottom + kContentTopGap;// + cellTitleBottomPadding();
    }
    
    [self layoutPic];

    CGPoint origin;
    if (_hasImage) {
        origin = CGPointMake(kCellLeftPadding, self.imageView.bottom + cellPaddingY());
    } else {
        CGFloat titleFontSize;
        CGFloat lineH;
        if (self.from == EssayCellStyleList) {
            titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
            lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
        }
        else{
            titleFontSize = [NewsUserSettingManager settedEssayDetailViewTextFontSize];
            lineH = [NewsUserSettingManager settedEssayDetailViewTextFontLineHeight];
        }
        CGFloat h = lineH - titleFontSize;

        origin = CGPointMake(kCellLeftPadding, self.contentLabel.bottom - h + 3 + cellPaddingY());
    }

    [self layoutAbstractAndCommentView:origin];
    
    if ([self shouldShowActionButtons]) {
        _diggButton.hidden = NO;
        _buryButton.hidden = NO;
        _favouriteButton.hidden = NO;
        _shareButton.hidden = NO;
        _commentButton.hidden = NO;

        [self layoutActionButtons];
    } else {
        if (self.orderedData) {
            _diggButton.hidden = YES;
            _buryButton.hidden = YES;
            _favouriteButton.hidden = YES;
            _shareButton.hidden = YES;
            _commentButton.hidden = YES;

#if SHOW_INFOBAR
            CGFloat y;
            if (self.godCommentView) {
                y = self.godCommentView.bottom + cellPaddingY();
            } else if (self.hasCommentView) {
                y = self.commentView.bottom + cellPaddingY();
            } else if (_hasImage) {
                y = self.imageView.bottom + cellPaddingY();
            } else {
                y = origin.y;
            }
            self.infoBarView.frame = CGRectMake(kCellLeftPadding, y, self.width - kCellLeftPadding - kCellRightPadding, cellInfoBarHeight());

            [self layoutInfoBarSubViews];
#endif
        }
    }
    [self layoutBottomLine];
    CGRect rect = self.bottomLineView.frame;
    rect.origin.x = 0;
    rect.size.width = self.width;
    self.bottomLineView.frame = rect;
    _sepLineView.frame = CGRectMake(0, _diggButton.bottom, self.width, [TTDeviceHelper ssOnePixel]);

    if ([TTDeviceHelper isPadDevice]) {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, 0);
    } else {
        _bottomView.frame = CGRectMake(0, _sepLineView.bottom, self.width, kCellSeprateViewHeight());
    }
}

- (void)layoutUnInterestedBtn
{
    CGFloat centerX = self.width - kCellLeftPadding - kCellUninterestedButtonWidth / 2 - 1;
    CGPoint p = CGPointMake(centerX, self.headerView.centerY);
    self.unInterestedButton.center = p;
}

- (void)layoutAbstractAndCommentView:(CGPoint)origin
{
    CGFloat x = origin.x;
    CGFloat y = origin.y;
    
    // 更新函数包含布局逻辑，所以放在layout中
    [self updateCommentView];

    if (self.godCommentView) {
        self.godCommentView.origin = origin;
    }
    else if (self.hasCommentView) {
        CGSize commentSize = [ExploreCellHelper updateCommentSize:[self.orderedData.essayData commentContent] cellWidth:self.width];
        self.commentView.frame = CGRectMake(x, y, self.width - 2*kCellLeftPadding, commentSize.height + kCellCommentViewVerticalPadding*2);
    }
}

- (void)ssLayoutSubviews {
    [super ssLayoutSubviews];
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    if(self.from != EssayCellStyleList){
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    }
    _imageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground17];
    
    UIImage *jagImage = [UIImage themedImageNamed:@"dividing_line.png"];
    
    jagImage = [self tiledImage:jagImage];
    
    _jagView.image = jagImage;
    
    _sepLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    _bottomView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    [self updateActionButtonsTheme];
}

- (void)fontSizeChanged
{
    CGFloat titleFontSize;
    CGFloat lineH;
    if (self.from == EssayCellStyleList) {
        titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
    }
    else{
        titleFontSize = [NewsUserSettingManager settedEssayDetailViewTextFontSize];
        lineH = [NewsUserSettingManager settedEssayDetailViewTextFontLineHeight];
    }
    if ([TTDeviceHelper isPadDevice]) {
        _contentLabel.font = [UIFont boldSystemFontOfSize:titleFontSize];
    }
    else {
        _contentLabel.font = [UIFont systemFontOfSize:titleFontSize];
    }
    _contentLabel.lineHeight = lineH;
    [super fontSizeChanged];
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

// 在推荐列表，大图默认高度不超过宽度
// 在频道列表，大图高度不超过两倍屏高
+ (BOOL)clipLongImage:(ExploreOrderedData *)orderedData imageWidth:(CGFloat)imageWidth clippedImageHeight:(CGFloat *)pImageClipHeight
{
    if (!orderedData) {
        return NO;
    }
    
    TTImageInfosModel *imageModel = orderedData.essayData.largeImageModel;
    if (imageModel && imageModel.width > 0) {
        CGFloat imageHeight = (imageWidth * imageModel.height) / imageModel.width;
        if ([orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            if (imageHeight > imageWidth) {
                if (pImageClipHeight) *pImageClipHeight = imageWidth;
                return YES;
            } else {
                if (pImageClipHeight) *pImageClipHeight = imageHeight;
                return NO;
            }
        } else {
            if (imageHeight > kMaxEssayImageHeight) {
                if (pImageClipHeight) *pImageClipHeight = kMaxEssayImageHeight;
                return YES;
            } else {
                if (pImageClipHeight) *pImageClipHeight = imageHeight;
                return NO;
            }
        }
    } else {
        if (pImageClipHeight) *pImageClipHeight = 0;
        return NO;
    }
}

// 列表页用
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellType = [self cellTypeForCacheHeightFromOrderedData:orderedData];
        
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellType];
        if (cacheH > 0) {
            //NSLog(@"hit cacheH: %f %p %@", cacheH, (__bridge void*)orderedData, orderedData.essayData.content);
            if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
                cacheH -= kCellSeprateViewHeight();
            }
            return cacheH;
        }
        
        EssayData *essay = orderedData.essayData;
        
        CGRect titleRect = CGRectZero;
        
        BOOL showActionButtons = [ExploreCellHelper shouldShowEssayActionButtons:orderedData.categoryID];
        
        if (!showActionButtons) {
            //titleRect = [self frameForTitleLabel:kTitleLabel cellWidth:width];
            titleRect.size.height = [self viewTopPadding] + kHeaderViewStyleAlignTopHeight;
        }
        
        CGRect contentLabelRect = [[self class] frameForContentLabel:essay.content cellWidth:width isList:YES];
        
        CGFloat titleFontSize = [NewsUserSettingManager settedEssayTextFontSize];
        CGFloat lineH = [NewsUserSettingManager settedEssayTextFontLineHeight];
        CGFloat contentHeight = 0;
        if(contentLabelRect.size.height != 0){
            contentHeight = contentLabelRect.size.height - (lineH - titleFontSize) + 3;
        }
#if SHOW_INFOBAR
        CGFloat sourceLabelHeight = cellInfoBarHeight();
#else
        CGFloat sourceLabelHeight = 0;
#endif
        
        CGFloat height;
        
        if (showActionButtons) {
            height = cellTopPadding() + contentHeight + kEssayActionButtonH;
        } else {
            height = cellBottomPadding() + contentHeight + sourceLabelHeight;
            if (titleRect.size.height > 0) {
                height += titleRect.size.height + kContentTopGap;
                
                if (![orderedData nextCellHasTopPadding] ||
                    [TTDeviceHelper isPadDevice])
                {
                    height += [self viewBottomPadding];
                }
            }
        }
        
        TTImageInfosModel *imageModel = essay.largeImageModel;
        
        if (imageModel && imageModel.width > 0) {
            CGFloat imageClipHeight = 0;
            CGFloat imageWidth = width - kCellLeftPadding - kCellRightPadding;
            [self clipLongImage:data imageWidth:imageWidth clippedImageHeight:&imageClipHeight];
            height += imageClipHeight + cellPaddingY();
        }
        
        BOOL bGodCommentView = [ExploreCellHelper shouldDisplayEssayGodComment:essay listType:listType];
        
        if (bGodCommentView) {
            CGFloat h = [ExploreArticleEssayCellCommentView heightForComments:[essay godCommentObjArray] viewWidth:width - kCellLeftPadding - kCellRightPadding];
            height += h + cellPaddingY();
        } else {
            BOOL hasCommentView = [ExploreCellHelper shouldDisplayEssayComment:essay listType:listType];
            
            if (hasCommentView) {
                CGSize commentSize = [ExploreCellHelper updateCommentSize:[essay commentContent] cellWidth:width];
                height += commentSize.height + kCellCommentViewVerticalPadding*2 + cellPaddingY();
            }
        }
        if ([TTDeviceHelper isPadDevice]) {
            height += [TTDeviceHelper ssOnePixel];
        }
        else {
            height += kCellSeprateViewHeight() + [TTDeviceHelper ssOnePixel];
        }
        [orderedData saveCacheHeight:ceilf(height) forListType:listType cellType:cellType];
        
        //NSLog(@"save cacheH: %f %p %@", height, (__bridge void*)orderedData, orderedData.essayData.content);
        if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
            height -= kCellSeprateViewHeight();
        }
        return ceilf(height);
    }
    
    return 0.f;
}

// 段子详情页用
+ (CGFloat)heightWithActionButtonsForEssayData:(EssayData *)essay cellWidth:(CGFloat)width
{
    CGRect contentLabelRect = [[self class] frameForContentLabel:essay.content cellWidth:width isList:NO];
    
    CGFloat titleFontSize = [NewsUserSettingManager settedEssayDetailViewTextFontSize];
    CGFloat lineH = [NewsUserSettingManager settedEssayDetailViewTextFontLineHeight];
    
    CGFloat titleHeight = contentLabelRect.size.height - (lineH - titleFontSize);
    
    CGFloat height = cellTopPadding() + titleHeight + cellBottomPadding()/*kEssayActionButtonH*/;
    
    TTImageInfosModel *imageModel = essay.largeImageModel;
    
    if (imageModel && imageModel.width > 0) {
        CGFloat imageWidth = width - kCellLeftPadding - kCellRightPadding;
        TTImageInfosModel *imageModel = essay.largeImageModel;
        CGFloat imageHeight = 0;
        if (imageModel && imageModel.width > 0) {
            imageHeight = (imageWidth * imageModel.height) / imageModel.width;
        }

        height += imageHeight + cellPaddingY();
    }
    
    return ceilf(height);
}

+ (NSUInteger)cellTypeForCacheHeightFromOrderedData:(id)orderedData
{
    if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
        // 由于同一个段子cell，位于不同的频道时UI有差别，故缓存高度时须附带频道ID
        return ((ExploreOrderedData *)orderedData).categoryID.hash;
    }
    return [[self class] hash];
}

#pragma mark - action buttons
- (void)loadActionButtons
{
    if (self.diggButton) {
        return;
    }
    
    // bottom view subviews
    self.diggButton = [[ArticleEssayActionButton alloc] init];
    [_diggButton addTarget:self action:@selector(actionButtonClicked:)];
    [self addSubview:_diggButton];
    
    self.buryButton = [[ArticleEssayActionButton alloc] init];
    [_buryButton addTarget:self action:@selector(actionButtonClicked:)];
    [self addSubview:_buryButton];
    
    self.favouriteButton = [[ArticleEssayActionButton alloc] init];
    _favouriteButton.centerAlignImage = YES;
    [_favouriteButton addTarget:self action:@selector(actionButtonClicked:)];
    [_favouriteButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText3] forState:UIControlStateSelected];
    [self addSubview:_favouriteButton];
    
    self.commentButton = [[ArticleEssayActionButton alloc] init];
    _commentButton.disableRedHighlight = YES;
    [_commentButton addTarget:self action:@selector(actionButtonClicked:)];
    [self addSubview:_commentButton];
    
    self.shareButton = [[ArticleEssayActionButton alloc] init];
    _shareButton.centerAlignImage = YES;
    _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_shareButton addTarget:self action:@selector(actionButtonClicked:)];
    [self addSubview:_shareButton];
    
    [self updateActionButtonsTheme];
}

// override
- (void)layoutInfoLabel
{
    if (![self shouldShowActionButtons]) {
        [super layoutInfoLabel];
    }
}

#pragma mark - kvo

static void *ExploreArticleEssayCellContext = &ExploreArticleEssayCellContext;

- (void)addKVO
{
    if (self.from != EssayCellStyleList) return;
    
    if (self.orderedData && ![self shouldShowActionButtons])
        return;
    
    if (self.originalData) {
        [super addKVO];

        [self.KVOController observe:self.originalData keyPaths:@[@"userDigg", @"userBury", @"diggCount", @"buryCount"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:ExploreArticleEssayCellContext];
    }
}

- (void)removeKVO
{
    if (self.from != EssayCellStyleList) return;
    
    if (self.orderedData && ![self shouldShowActionButtons])
        return;
    
    if (self.originalData) {
        [self.KVOController unobserveAll];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (!newValue || [newValue isKindOfClass:[NSNull class]])
    {
        return;
    }

    if ([oldValue isKindOfClass:[NSNull class]] || ([oldValue isKindOfClass:[NSNumber class]] && [newValue isKindOfClass:[NSNumber class]] && ![oldValue isEqualToNumber:newValue])) {
        if ([NSThread isMainThread]) {
            [self handleChangedValue:newValue forKeyPath:keyPath];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleChangedValue:newValue forKeyPath:keyPath];
            });
        }
    }
}

- (void)handleChangedValue:(NSNumber *)newValue forKeyPath:(NSString *)keyPath {
    EssayData *essayData = nil;

    if (self.originalData && [self.originalData isKindOfClass:[EssayData class]]) {
        essayData = (EssayData *)self.originalData;
    } else {
        essayData = self.essayData;
    }

    // 重写基类实现
    if([keyPath isEqualToString:@"hasRead"])
    {
        [self updateContentColor];
    }
    else if ([keyPath isEqualToString:@"userDigg"] || [keyPath isEqualToString:@"userBury"]) {
        if (essayData.userDigg) {
            [_diggButton setEnabled:YES selected:YES];
            [_buryButton setEnabled:YES selected:NO];
        }
        else if (essayData.userBury) {
            [_diggButton setEnabled:YES selected:NO];
            [_buryButton setEnabled:YES selected:YES];
        }
        else {
            [_diggButton setEnabled:YES selected:NO];
            [_buryButton setEnabled:YES selected:NO];
        }
    }
    else if([keyPath isEqualToString:@"diggCount"]) {
        if (essayData.diggCount) {
            [_diggButton setTitle:[TTBusinessManager formatCommentCount:essayData.diggCount]];
        }
        else{
            [_diggButton setTitle:NSLocalizedString(@" 赞", nil)];
        }
    }
    else if([keyPath isEqualToString:@"buryCount"]) {
        if (essayData.buryCount) {
            [_buryButton setTitle:[TTBusinessManager formatCommentCount:essayData.buryCount]];
        }
        else{
            [_buryButton setTitle:NSLocalizedString(@" 踩", nil)];
        }
    }
    else if([keyPath isEqualToString:@"userRepined"]) {
        _favouriteButton.minWidth = 39.f;
        [_favouriteButton setEnabled:YES selected:essayData.userRepined];
    }
    else if([keyPath isEqualToString:@"commentCount"]) {
        NSString * commentTitle = nil;
        if (essayData.commentCount) {
            commentTitle = [TTBusinessManager formatCommentCount:essayData.commentCount];
        }
        else{
            commentTitle = NSLocalizedString(@" 评论", nil);
        }
        [_commentButton setTitle:commentTitle];
    }
}

- (void)actionButtonClicked:(id)sender
{
    EssayData *essayData = self.orderedData.essayData?:self.essayData;
    
    if (sender == _diggButton || sender == _buryButton) {
        if (essayData.userDigg) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经赞过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            return;
        }
        else if (essayData.userBury) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经踩过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            return;
        }
    }

    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if (sender == _diggButton) {
        [_diggButton doZoomInAndDisappearMotion];
        essayData.userDigg = YES;
        essayData.diggCount = essayData.diggCount + 1;
        [essayData save];
        //[[SSModelManager sharedManager] save:nil];
        
       // __weak __typeof__(self) wself = self;
        [_itemActionManager sendActionForOriginalData:essayData adID:nil actionType:DetailActionTypeDig finishBlock:^(id userInfo, NSError *error) {
//            if (!error) {
//                if ([wself.orderedData.essayData.uniqueID longLongValue] == [essayData.uniqueID longLongValue]) {
//                    [wself updateActionButtons:essayData];
//                }
//            }
        }];
        self.diggButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.diggButton.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.diggButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            self.diggButton.imageView.alpha = 0;
        } completion:^(BOOL finished) {
             [self updateActionButtons:essayData];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.diggButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                self.diggButton.imageView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];
        
        if ([TTDeviceHelper isPadDevice]) {
            wrapperTrackEvent(_trackEventName, [NSString stringWithFormat:@"%@_dig", _trackLabelPrefix]);
        }
        wrapperTrackEvent(@"xiangping", @"digg");
    }
    else if (sender == _buryButton) {
        [_buryButton doZoomInAndDisappearMotion];
        essayData.userBury = YES;
        essayData.buryCount = essayData.buryCount + 1;
        [essayData save];
        //[[SSModelManager sharedManager] save:nil];
        
        //__weak __typeof__(self) wself = self;
        [_itemActionManager sendActionForOriginalData:essayData adID:nil actionType:DetailActionTypeBury finishBlock:^(id userInfo, NSError *error) {
//            if (!error) {
//                if ([wself.orderedData.essayData.uniqueID longLongValue] == [essayData.uniqueID longLongValue]) {
//                    [wself updateActionButtons:essayData];
//                }
//            }
        }];
        
        self.buryButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.buryButton.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.buryButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            self.buryButton.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self updateActionButtons:essayData];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.buryButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                self.buryButton.imageView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }];

        if ([TTDeviceHelper isPadDevice]) {
            wrapperTrackEvent(_trackEventName, [NSString stringWithFormat:@"%@_bury", _trackLabelPrefix]);
        }
        wrapperTrackEvent(@"xiangping", @"bury");
    }
    else if (sender == _favouriteButton) {
        if (essayData.userRepined == YES) {
//            __weak __typeof__(self) wself = self;
            [_itemActionManager unfavoriteForOriginalData:essayData adID:nil finishBlock:^(id userInfo, NSError *error) {
//                if (!error) {
//                    if ([wself.orderedData.essayData.uniqueID longLongValue] == [essayData.uniqueID longLongValue]) {
//                        [wself updateActionButtons:essayData];
//                    }
//                }
            }];
            self.favouriteButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.favouriteButton.imageView.contentMode = UIViewContentModeCenter;
            [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.favouriteButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                self.favouriteButton.imageView.alpha = 0;
            } completion:^(BOOL finished) {
                [self updateActionButtons:essayData];
                [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.favouriteButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                    self.favouriteButton.imageView.alpha = 1;
                } completion:^(BOOL finished) {
                }];
            }];
           
            NSString * tipMsg = NSLocalizedString(@"取消收藏", nil);
            UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
            if (!isEmptyString(tipMsg)) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
            }
            wrapperTrackEvent(@"xiangping", @"list_unfavorite");
        }
        else {
//            __weak __typeof__(self) wself = self;
            [_itemActionManager favoriteForOriginalData:essayData adID:nil finishBlock:^(id userInfo, NSError *error) {
//                if (!error) {
//                    if ([wself.orderedData.essayData.uniqueID longLongValue] == [essayData.uniqueID longLongValue]) {
//                        [wself updateActionButtons:essayData];
//                    }
//                }
            }];
            
            self.favouriteButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.favouriteButton.imageView.contentMode = UIViewContentModeCenter;
            [UIView animateWithDuration:0.1f animations:^{
                self.favouriteButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                self.favouriteButton.imageView.alpha = 0;
            } completion:^(BOOL finished) {
                [self updateActionButtons:essayData];
                 self.favouriteButton.imageView.alpha = 0;
                [UIView animateWithDuration:0.3f animations:^{
                    self.favouriteButton.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
                    self.favouriteButton.imageView.alpha = 1;
                } completion:^(BOOL finished) {
                }];
            }];
        
            NSString * tipMsg = NSLocalizedString(@"收藏成功", nil);
            UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
            if (!isEmptyString(tipMsg)) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
            }
            if ([TTDeviceHelper isPadDevice]) {
                wrapperTrackEvent(_trackEventName, [NSString stringWithFormat:@"%@_favourite", _trackLabelPrefix]);
            }
            wrapperTrackEvent(@"xiangping", @"list_favorite");
        }
        [self updateActionButtons:essayData];
    }
    else if (sender == _shareButton) {
        [self shareButtonDidPress];
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.essayData.uniqueID];
        NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeEssay];
        NSString *label = [TTActivityShareManager labelNameForShareActivityType:TTActivityTypeShareButton];
        wrapperTrackEventWithCustomKeys(tag, label, uniqueID, self.orderedData.categoryID, nil);

    } else if (sender == _commentButton) {
        [self commentButtonDidPress];
        wrapperTrackEvent(@"xiangping", @"more_comment");
    }
}

- (void)shareButtonDidPress {
    
    EssayData *essayData = self.orderedData.essayData?:self.essayData;

    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager essayActivitysForManager:_activityActionManager essayData:essayData];
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    [_phoneShareView showOnWindow:self.window];
    
       if (self.orderedData.essayData) {
        wrapperTrackEvent(@"list_content", @"share_channel");
    }
}

#pragma mark -- SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        if (itemType == TTActivityTypeReport) {
            self.actionSheetController = [[TTActionSheetController alloc] init];

            [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
            [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
                
                if (parameters[@"report"]) {
                    NSString *groupID = [NSString stringWithFormat:@"%lld", self.orderedData.essayData.uniqueID];
                    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:groupID];
                    TTReportContentModel *model = [[TTReportContentModel alloc] init];
                    model.groupID = groupModel.groupID;
                    model.itemID = groupModel.itemID;
                    model.aggrType = @(groupModel.aggrType);
                    [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeEssay reportFrom:TTReportFromByEnterFromAndCategory(nil, self.orderedData.categoryID) contentModel:model extraDic:nil animated:YES];
                }
            }];
        } else {
            NSString *essayId = [NSString stringWithFormat:@"%lld", self.orderedData.essayData.uniqueID];
            [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self] sourceObjectType:TTShareSourceObjectTypeEssay uniqueId:essayId];
            [self sendEssayShareTrackWithItemType:itemType];
        }
        self.phoneShareView= nil;
    }
}

#pragma mark -- Track

- (void)sendEssayShareTrackWithItemType:(TTActivityType)itemType
{
    NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.essayData.uniqueID];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeEssay];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    wrapperTrackEventWithCustomKeys(tag, label, uniqueID, self.orderedData.categoryID, nil);
}

- (void)updateActionButtons:(EssayData *)essayData
{
    NSString * diggTitle = nil;
    if (essayData.diggCount) {
        diggTitle = [TTBusinessManager formatCommentCount:essayData.diggCount];
    }
    else{
        diggTitle = NSLocalizedString(@" 赞", nil);
    }
    //if (diggTitle.length>6) diggTitle = @"999999";
    [_diggButton setMaxWidth:72.0f];
    [_diggButton setTitle:diggTitle];
    
    NSString * buryTitle = nil;
    if (essayData.buryCount) {
        buryTitle = [TTBusinessManager formatCommentCount:essayData.buryCount];
    }
    else{
        buryTitle = NSLocalizedString(@" 踩", nil);
    }
    //if (buryTitle.length>5) buryTitle = @"99999";
    [_buryButton setMaxWidth:66.0f];
    [_buryButton setTitle:buryTitle];
    
    if (essayData.userDigg) {
        [_diggButton setEnabled:YES selected:YES];
        [_buryButton setEnabled:YES selected:NO];
    }
    else if (essayData.userBury) {
        [_diggButton setEnabled:YES selected:NO];
        [_buryButton setEnabled:YES selected:YES];
    }
    else {
        [_diggButton setEnabled:YES selected:NO];
        [_buryButton setEnabled:YES selected:NO];
    }
    
    _favouriteButton.minWidth = 39;
    [_favouriteButton setEnabled:YES selected:essayData.userRepined];
    
    NSString * commentTitle = nil;
    if (essayData.commentCount) {
        commentTitle = [TTBusinessManager formatCommentCount:essayData.commentCount];
    }
    else{
        commentTitle = NSLocalizedString(@" 评论", nil);
    }
    //if (commentTitle.length>4) commentTitle = @"9999";
    //_commentButton.minWidth = 38.f;
    _commentButton.maxWidth = 72.0f;
    [_commentButton setTitle:commentTitle];
    
    _shareButton.minWidth = 39.f;
}

- (void)updateActionButtonsTheme {
    [_diggButton setImage:[UIImage themedImageNamed:@"digup_video.png"] forState:UIControlStateNormal];
    [_diggButton setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateHighlighted];
    [_diggButton setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateSelected];
    [_diggButton updateThemes];
    
    [_buryButton setImage:[UIImage themedImageNamed:@"digdown_video.png"] forState:UIControlStateNormal];
    [_buryButton setImage:[UIImage themedImageNamed:@"digdown_video_press.png"] forState:UIControlStateHighlighted];
    [_buryButton setImage:[UIImage themedImageNamed:@"digdown_video_press.png"] forState:UIControlStateSelected];
    [_buryButton updateThemes];
    
    [_favouriteButton setImage:[UIImage themedImageNamed:@"love_video.png"] forState:UIControlStateNormal];
    [_favouriteButton setImage:[UIImage themedImageNamed:@"love_video_press.png"] forState:UIControlStateHighlighted];
    [_favouriteButton setImage:[UIImage themedImageNamed:@"love_video_press.png"] forState:UIControlStateSelected];
    [_favouriteButton updateThemes];
    
    [_commentButton setImage:[UIImage themedImageNamed:@"comment_video.png"] forState:UIControlStateNormal];
    [_commentButton setImage:[UIImage themedImageNamed:@"comment_video_press.png"] forState:UIControlStateHighlighted];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
    [_commentButton updateThemes];
    
    [_shareButton setImage:[UIImage themedImageNamed:@"repost_video.png"] forState:UIControlStateNormal];
    [_shareButton setImage:[UIImage themedImageNamed:@"repost_video_press.png"] forState:UIControlStateHighlighted];
    [_shareButton updateThemes];
}

- (void)layoutActionButtons {
    CGRect vFrame = self.bounds;
    CGRect tmpFrame;
    
    CGFloat x = 0, y = 0;
    
    x = self.contentLabel.left;
    
    if (self.godCommentView) {
        y = self.godCommentView.bottom /*+ kPaddingY*/;
    } else if (self.hasCommentView) {
        y = self.commentView.bottom;
    } else if (_hasImage) {
        y = self.imageView.bottom;
    } else {
        CGFloat lineDescent = (self.contentLabel.lineHeight - self.contentLabel.font.lineHeight);
        y = self.contentLabel.bottom - lineDescent;
    }
    
    y = ceilf(y);
    
    tmpFrame = _diggButton.frame;
    tmpFrame.origin.x = x;
    tmpFrame.origin.y = y;//vFrame.size.height - tmpFrame.size.height - kPaddingY/3;
    _diggButton.frame = tmpFrame;
    
    tmpFrame = _buryButton.frame;
    tmpFrame.origin.x = CGRectGetMinX(_diggButton.frame) + kDigAndBuryIconGap + 20;
    tmpFrame.origin.y = CGRectGetMinY(_diggButton.frame);
    _buryButton.frame = tmpFrame;
    
    tmpFrame = _commentButton.frame;
    tmpFrame.origin.x = CGRectGetMinX(_buryButton.frame) + kDigAndBuryIconGap + 20.f;//vFrame.size.width - tmpFrame.size.width - 8.f;
    tmpFrame.origin.y = CGRectGetMinY(_diggButton.frame);//vFrame.size.height - tmpFrame.size.height - 10.f;
    _commentButton.frame = tmpFrame;
    
    _shareButton.width = MAX(_shareButton.minWidth, _shareButton.width);
    tmpFrame = _shareButton.frame;
    tmpFrame.origin.x = vFrame.size.width - tmpFrame.size.width - x + 9.5f;
    tmpFrame.origin.y = CGRectGetMinY(_diggButton.frame);
    _shareButton.frame = tmpFrame;

    tmpFrame = _favouriteButton.frame;
    tmpFrame.origin.x = _shareButton.left - tmpFrame.size.width - 3;//CGRectGetMaxX(_commentButton.frame) + 8.f;
    tmpFrame.origin.y = CGRectGetMinY(_diggButton.frame);
    _favouriteButton.frame = tmpFrame;
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

#pragma mark - ExploreArticleEssayCellCommentViewDelgate 神评论
- (void)exploreArticleEssayCellCommentView:(ExploreArticleEssayCellCommentView *)view commentClicked:(ExploreArticleEssayCommentObject *)commentObj {
    long long commentID = [commentObj.user.ID longLongValue];
    if (commentID != 0) {
        NSString * label = @"click_headline";
        NSString *categoryID = self.orderedData.categoryID;
        
        if (!isEmptyString(categoryID) && ![categoryID isEqualToString:kTTMainCategoryID]) {
            label = [NSString stringWithFormat:@"click_%@", categoryID];
        }
        [NewsDetailLogicManager trackEventTag:@"click_list_comment" label:label value:@(commentID) extValue:nil  groupModel:self.orderedData.article.groupModel];
    }

    [self commentButtonDidPress];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [_godCommentView updateBackgroudColorWithHighlighted:highlighted];
}

// 普通评论
- (void)exploreArticleCellCommentViewSelected:(ExploreArticleCellCommentView*)commentView {
    NSDictionary *comentDic = self.orderedData.essayData.comment;
    long long commentID = [[comentDic objectForKey:@"comment_id"] longLongValue];
    if (commentID != 0) {
        NSString * label = @"click_headline";
        if (!isEmptyString(self.orderedData.categoryID) && ![self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            label = [NSString stringWithFormat:@"click_%@", self.orderedData.categoryID];
        }
        [NewsDetailLogicManager trackEventTag:@"click_list_comment" label:label value:@(commentID) extValue:nil  groupModel:nil];
    }

    [self commentButtonDidPress];
}

- (void)commentButtonDidPress {
    EssayData *essay = self.orderedData.essayData;
    EssayDetailViewController * controller = [[EssayDetailViewController alloc] initWithEssayData:essay scrollToComment:YES trackEvent:@"essay_tab" trackLabel:self.orderedData.categoryID];
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
    [topController.navigationController pushViewController:controller animated:YES];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    EssayData *essay = self.orderedData.essayData;
    
    EssayDetailViewController * controller = [[EssayDetailViewController alloc] initWithEssayData:essay scrollToComment:NO trackEvent:@"essay_tab" trackLabel:self.orderedData.categoryID];
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
    [topController.navigationController pushViewController:controller animated:YES];
}

@end

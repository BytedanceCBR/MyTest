//
//  ArticleCategoryManagerView.m
//  Article
//
//  Created by Zhang Leonardo on 13-11-21.
//
//

#import "ArticleCategoryManagerView.h"
#import "TTArticleCategoryManager.h"
#import "TTIndicatorView.h"
#import "SSThemed.h"
#import "ArticleCategoryManagerViewConstant.h"
#import "ArticleCategorySubscribeCell.h"
#import "ExploreLogicSetting.h"
#import "ArticleBadgeManager.h"
//#import "FRConcernGuideViewController.h"

#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

#import "VVeboImageView.h"
#import "SSWebViewController.h"
#import "TTNavigationController.h"
#import "ArticleCategoryWAPViewController.h"
#import "TTLoadMoreView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"


#import "UIView+CustomTimingFunction.h"
#import "UIButton+TTAdditions.h"

NSString *const kCategoryManagerViewWillDisplayNotification     = @"kCategoryManagerViewWillDisplayNotification";
//NSString *const kCategoryManagerViewWillHideNotification        = @"kCategoryManagerViewWillHideNotification";
NSString *const kDisplayCategoryManagerViewNotification         = @"kDisplayCategoryManagerViewNotification";
NSString *const kCloseCategoryManagerViewNotification         = @"kCloseCategoryManagerViewNotification";


@interface ArticleCategoryManagerView()<ArticleCategorySubscribeCellDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    CGPoint _panGestureBeganPoint;
    CGPoint _panGesturePreviousPoint;//上一个点
    CGPoint _lastHitViewCenter;
    
    CGFloat _viewWidth;
    CGFloat _contentY;
    //CGPoint _longPressViewPreviousCenter;
    BOOL _userChanged;//记录用户是否改变过排序
    BOOL _appeared;
    BOOL _editing;
    
//    NSUInteger _backupStatusBarStyle;
}


@property (nonatomic, assign) BOOL isDraggingFloatView;
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) CGFloat originY;

@property(nonatomic, strong)SSThemedLabel * moreCategoryLabel;
@property(nonatomic, strong)UIPanGestureRecognizer * panGestureRecognizer;
@property(nonatomic, strong)UILongPressGestureRecognizer * longPressGestureRecognizer;
@property(nonatomic, strong)NSMutableArray * subscribedCategoryCells;
@property(nonatomic, strong)NSMutableArray * unsubscribedCategoryCells;
@property(nonatomic, strong)ArticleCategorySubscribeCell * draggingView;
@property(nonatomic, strong)ArticleCategorySubscribeCell * longPressView;
@property(nonatomic, assign)BOOL showedAllUnsubCells;//default is NO
@property(nonatomic, strong)TTCategory * lastAddCategoryModel;
@property(nonatomic, strong)SSThemedScrollView *contentScrollView;
@property(nonatomic, assign, getter=isEditing)BOOL editing;
@property(nonatomic, strong)UIView * topView;
@property(nonatomic, strong)UIView * topViewBottomLine;
@property(nonatomic, strong)SSThemedLabel *topInfoLabel;
@property(nonatomic, strong)SSThemedLabel *moreInfoLabel;
@property(nonatomic, strong)SSThemedImageView *bottomMaskView;
@property(nonatomic, strong)SSThemedButton *editButton;
@property(nonatomic, strong)SSThemedButton *closeButton;

@property(nonatomic,strong)UIView *containerView;

@property(nonatomic, strong)SSThemedView *rootMaskView;

// “订阅”频道
@property(nonatomic, strong)ArticleCategorySubscribeCell *subscribeCell;
@property(nonatomic, strong)SSThemedButton *moreCategoriesButton;
@property(nonatomic, strong)CAShapeLayer * dashBorderLayer;

@property(nonatomic, strong)NSMutableDictionary * categoryIDCellMap;

@property(nonatomic, strong)SSThemedLabel * titleLabel;

@property (nonatomic, copy) void(^didShowBlock)(void);
@property (nonatomic, copy) void(^didDisappearBlock)(void);

//@property (nonatomic, assign) BOOL newStyle;

@end

@implementation ArticleCategoryManagerView

- (void)dealloc
{
    [self removeGestureRecognizer:_longPressGestureRecognizer];
    [self removeGestureRecognizer:_panGestureRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGFloat)categoryCellHorizonGap {
    if ([TTDeviceHelper is736Screen]) {
        return 14.7f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 11.f;
    }
    else
    {
        return 10.f;
    }
}

- (CGFloat)categoryCellVerticalGap {
    if ([TTDeviceHelper is736Screen]) {
        return 14.7f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 11.f;
    }
    else
    {
        return 10.f;
    }

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        _backupStatusBarStyle = -1;
        
        _userChanged = NO;
        _showedAllUnsubCells = NO;
//        _newStyle = YES;
        
        self.clipsToBounds = YES;
        
        _viewWidth = [ArticleCategorySubscribeCell articleCategorySubscribeCellWidth] * kCellNumberPerRow + (kCellNumberPerRow - 1) * [self categoryCellHorizonGap];
        if ([TTDeviceHelper isPadDevice]) {
            _viewWidth = [TTUIResponderHelper splitViewFrameForView:self].size.width - kCategoryCellLeftPadding * 2;
        }
        
        // 毛玻璃效果
        /*
        if ([TTDeviceHelper OSVersionNumber] >= 7.f) {
            self.blurBgView = [[UIToolbar alloc] initWithFrame:self.bounds];
            _blurBgView.translucent = YES;
            self.backgroundColor = [UIColor clearColor];
            [self addSubview:_blurBgView];
        }*/
        
        self.subscribedCategoryCells = [NSMutableArray arrayWithCapacity:20];
        self.unsubscribedCategoryCells = [NSMutableArray arrayWithCapacity:20];
        self.categoryIDCellMap = [NSMutableDictionary dictionaryWithCapacity:20];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
        self.originY = self.top;
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        _longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_longPressGestureRecognizer];
        
        self.rootMaskView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.rootMaskView.backgroundColorThemeKey = kColorBackground15;
        
        CGFloat topViewY = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat topViewH = 44;
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, topViewY, self.width, topViewH)];
        //_topView.backgroundColor = [UIColor clearColor];
//        self.topView.clipsToBounds = YES;
//        self.topView.layer.masksToBounds = YES;
        [self addSubview:_topView];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self).offset(topViewY);
            make.height.equalTo(@(topViewH));
        }];

        // 顶部圆角
        [self updateTopViewLayerMask];
        
        self.topViewBottomLine = [[UIView alloc] init];
        [_topView addSubview:_topViewBottomLine];
        _topViewBottomLine.hidden = YES;
        
        [_topViewBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_topView);
            make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
        }];
        
        self.contentScrollView = [[SSThemedScrollView alloc] initWithFrame:CGRectMake(0, _topView.height - 1, self.width, self.height - _topView.height - topViewY)];
        _contentScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _contentScrollView.scrollIndicatorInsets = _contentScrollView.contentInset;
        _contentScrollView.clipsToBounds = YES;
        _contentScrollView.alwaysBounceVertical = YES;
        _contentScrollView.bounces = YES;
        _contentScrollView.backgroundColor = [UIColor clearColor];
        _contentScrollView.delegate = self;
        
        [self addSubview:_contentScrollView];
        [self bringSubviewToFront:_topView];

        [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
//            make.height.equalTo(@(self.height - self.topView.height - topViewY));
            make.top.equalTo(_topView.mas_bottom).offset(-1);
        }];
        
        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = [UIColor clearColor];
        [self.contentScrollView addSubview:self.containerView];
        
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentScrollView);
            make.width.mas_equalTo(_viewWidth);
            make.centerX.equalTo(self.contentScrollView);
        }];
        
        self.titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.text = NSLocalizedString(@"我的频道", nil);
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:[self fontSize]];
        
        [self.containerView addSubview:_titleLabel];
    
        CGFloat delta = 0;
        if ([TTDeviceHelper is736Screen]) { // iPhone 6P
            delta = -2;
        }
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView);
            make.top.equalTo(self.containerView).offset(9 + delta);
        }];
        
        self.topInfoLabel = [[SSThemedLabel alloc] init];
        _topInfoLabel.textColorThemeKey = kColorText3;
        _topInfoLabel.backgroundColor = [UIColor clearColor];
        _topInfoLabel.text = @"点击进入频道";//@"拖拽可以排序";
        [_topInfoLabel setFont:[UIFont systemFontOfSize:[self infoLabelFontSize]]];

        [self.containerView addSubview:_topInfoLabel];
        [_topInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_titleLabel).offset(-2);
            make.left.equalTo(_titleLabel.mas_right).offset(9);
        }];
        
        CGSize editBtnSize = [self editButtonSize];
        self.editButton = [[SSThemedButton alloc] init];
        [_editButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_editButton setTitle:NSLocalizedString(@"编辑", nil) forState:UIControlStateNormal];
        _editButton.layer.cornerRadius = editBtnSize.height/2;
        _editButton.titleLabel.font = [UIFont systemFontOfSize:[self editButtonFontSize]];
        _editButton.clipsToBounds = YES;
        _editButton.titleColorThemeKey = kColorText4;
        _editButton.highlightedTitleColorThemeKey = kColorText4Highlighted;
        _editButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _editButton.borderColorThemeKey = kColorLine2;
        _editButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 0);
        
        [self.containerView addSubview:_editButton];
        
        
        [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_titleLabel).offset(-3);
            make.width.mas_equalTo(editBtnSize.width);
            make.height.mas_equalTo(editBtnSize.height);
            make.right.equalTo(self.containerView);

        }];
        
        self.moreCategoryLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        [_moreCategoryLabel setText:NSLocalizedString(@"频道推荐", nil)];
        _moreCategoryLabel.textColorThemeKey = kColorText1;
        [_moreCategoryLabel setFont:[UIFont systemFontOfSize:[self fontSize]]];
        [_moreCategoryLabel sizeToFit];
        _moreCategoryLabel.backgroundColor = [UIColor clearColor];
        [self.containerView addSubview:_moreCategoryLabel];

//        [self.moreCategoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.titleLabel);
//        }];
        
        self.moreInfoLabel = [[SSThemedLabel alloc] init];
        _moreInfoLabel.textColorThemeKey = kColorText3;
        _moreInfoLabel.backgroundColor = [UIColor clearColor];
        _moreInfoLabel.text = NSLocalizedString(@"点击添加频道", nil);
        [_moreInfoLabel setFont:[UIFont systemFontOfSize:[self infoLabelFontSize]]];
        
        [self.containerView addSubview:_moreInfoLabel];
        [_moreInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_moreCategoryLabel).offset(-2);
            make.left.equalTo(_moreCategoryLabel.mas_right).offset(9);
        }];


        NSString * title = @"更多频道";
        self.moreCategoriesButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, [ArticleCategorySubscribeCell articleCategorySubscribeCellWidth], [ArticleCategorySubscribeCell articleCategorySubscribeCellHeight])];
        _moreCategoriesButton.backgroundColor = [UIColor clearColor];
        [_moreCategoriesButton setTitle:title forState:UIControlStateNormal];
        [_moreCategoriesButton setTitle:title forState:UIControlStateHighlighted];
        _moreCategoriesButton.titleColorThemeKey = kColorText4;
        [_moreCategoriesButton.titleLabel setFont:[UIFont systemFontOfSize:[ArticleCategorySubscribeCell articleCategorySubscribeCellTitleFontSizeWithText:title]]];
        [_moreCategoriesButton addTarget:self action:@selector(moreCategoriesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_moreCategoriesButton];
        
        self.dashBorderLayer = [CAShapeLayer layer];
        _dashBorderLayer.fillColor = nil;
        CGFloat lineWidth = [TTDeviceHelper ssOnePixel];
        _dashBorderLayer.lineWidth = lineWidth;
        _dashBorderLayer.lineDashPattern = @[@2, @2];
        _dashBorderLayer.frame = CGRectMake(lineWidth, lineWidth, (_moreCategoriesButton.width) - lineWidth * 2, (_moreCategoriesButton.height) - lineWidth * 2);
        _dashBorderLayer.path = [[UIBezierPath bezierPathWithRect:_dashBorderLayer.bounds] CGPath];
        [_moreCategoriesButton.layer addSublayer:_dashBorderLayer];
        
        if ([TTDeviceHelper isPadDevice]) {
            self.bottomMaskView = [[SSThemedImageView alloc] init];
            _bottomMaskView.imageName = @"add_channels_bg_iPad";
            _bottomMaskView.contentMode = UIViewContentModeScaleToFill;
            [self addSubview:_bottomMaskView];
            
            [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(self);
            }];
        }
        self.closeButton = [[TTAlphaThemedButton alloc] init];
        _closeButton.contentMode = UIViewContentModeScaleToFill;
        [_closeButton addTarget:self action:@selector(closeClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([TTDeviceHelper isPadDevice]) {
            [self addSubview:_closeButton];
        } else {
            [_topView addSubview:_closeButton];
        }

        _closeButton.imageName = [TTDeviceHelper isPadDevice] ? @"add_channels_close_iPad" : @"close_channel";
        
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([TTDeviceHelper isPadDevice]) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self).offset(-30);
            } else {
                make.width.mas_equalTo(_closeButton.imageView.image.size.width + 10 * 2);
                make.height.mas_equalTo(_closeButton.imageView.image.size.height + 10 * 2);
                make.left.equalTo(self.topView);
                make.centerY.equalTo(self.topView);
            }
        }];
        
        [self reloadThemeUI];
        
        [self layoutIfNeeded];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBadgeRefreshedNotification:) name:kArticleBadgeManagerRefreshedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryHasChangeNotification:) name:kArticleCategoryHasChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryHasChangeNotification:) name:kAritlceCategoryGotFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootViewWillTransitionToSize:) name:kRootViewWillTransitionToSize object:nil];
    }
    
    return self;
}

- (void)rootViewWillTransitionToSize:(NSNotification *)noti
{
    CGSize size = [noti.object CGSizeValue];
    [self willTransitionToSize:size];
}

- (void)willTransitionToSize:(CGSize)size
{
    CGRect frame = CGRectZero;
    frame.size = size;
    self.frame = frame;
    
    [self reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        _viewWidth = [TTUIResponderHelper splitViewFrameForView:self].size.width - kCategoryCellLeftPadding * 2;
        [self refreshUI];
        
        [self updateTopViewLayerMask];
    }
    
    self.rootMaskView.frame = self.bounds;
    
    [self layoutIfNeeded];
}

- (void)didAppear
{
    [super didAppear];
}

- (void)willAppear
{
    [super willAppear];
    if(!_appeared)
    {
        _appeared = YES;
        [self reloadData];
    }
}

- (void)willDisappear {
    [super willDisappear];
}

//- (void)didMoveToWindow {
//    [super didMoveToWindow];
//    
//    if (self.window && !_newStyle) {
//        BOOL nightMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight;
//        if (_backupStatusBarStyle == -1 ) {
//            _backupStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
//        
//            [[UIApplication sharedApplication] setStatusBarStyle:(nightMode ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault) animated:YES];
//            
//        } else {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [[UIApplication sharedApplication] setStatusBarStyle:(nightMode ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault) animated:YES];
//            });
//        }
//    }
//}

- (void)updateTopViewLayerMask {
    CGRect rect = self.topView.bounds;
    CGSize radio = CGSizeMake(6, 6);
    UIRectCorner corner = UIRectCornerTopLeft|UIRectCornerTopRight;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radio];
    CAShapeLayer *masklayer = [[CAShapeLayer alloc] init];
    masklayer.frame = rect;
    masklayer.path = path.CGPath;
    self.topView.layer.mask = masklayer;
}

- (void)editButtonClicked:(id)sender
{
    wrapperTrackEvent(@"channel_manage", _editing ? @"finish" : @"edit");
    [self setEditing:!_editing];
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    
    for(ArticleCategorySubscribeCell *cell in _subscribedCategoryCells)
    {
        cell.editing = _editing;
    }
    
    if(_editing)
    {
        [_editButton setTitle:NSLocalizedString(@"完成", @"") forState:UIControlStateNormal];
        _topInfoLabel.text = NSLocalizedString(@"拖拽可以排序", @"");
    }
    else
    {
        [_editButton setTitle:NSLocalizedString(@"编辑", @"") forState:UIControlStateNormal];
        _topInfoLabel.text = NSLocalizedString(@"点击进入频道", @"");
    }
}

- (BOOL)isEditing
{
    return _editing;
}

- (void)prepareCells
{
    [_subscribedCategoryCells removeAllObjects];
    [_unsubscribedCategoryCells removeAllObjects];
    
    NSArray * preFixedAndSubscribeCategories = nil;
    NSArray * unsubscribeCategories = nil;
    
    preFixedAndSubscribeCategories = [[TTArticleCategoryManager sharedManager] preFixedAndSubscribeCategories];
    unsubscribeCategories = [[TTArticleCategoryManager sharedManager] unsubscribeCategories];
    
    
    NSMutableDictionary * newCategoryIDCellMap = [NSMutableDictionary dictionaryWithCapacity:preFixedAndSubscribeCategories.count + unsubscribeCategories.count];
    for (TTCategory * model in preFixedAndSubscribeCategories) {
        // 防止服务端传回重复的频道
        if (![newCategoryIDCellMap objectForKey:model.categoryID]) {
            ArticleCategorySubscribeCell * cell = [_categoryIDCellMap objectForKey:model.categoryID];
            if (!cell) {
                cell = [[ArticleCategorySubscribeCell alloc] init];
                cell.delegate = self;
            }
            
            [cell refreshCategoryModel:model];
            [_subscribedCategoryCells addObject:cell];
            if (!cell.superview) {
                [self.containerView addSubview:cell];
                // for animation
                
                cell.origin = CGPointMake(-(cell.width), -(cell.height));
                
            }
            [newCategoryIDCellMap setObject:cell forKey:model.categoryID];
            if([model.categoryID isEqualToString:kTTSubscribeCategoryID])
            {
                self.subscribeCell = cell;
            }
        }
    }
    
    for (TTCategory * model in unsubscribeCategories) {
        // 防止服务端传回重复的频道
        if (![newCategoryIDCellMap objectForKey:model.categoryID]) {
            ArticleCategorySubscribeCell * cell = [_categoryIDCellMap objectForKey:model.categoryID];
            if (!cell) {
                cell = [[ArticleCategorySubscribeCell alloc] init];
                cell.delegate = self;
            }
            
            [cell refreshCategoryModel:model];
            if (!cell.superview) {
                [self.containerView addSubview:cell];
                // for animation
                cell.origin = CGPointMake(-(cell.width), -(cell.height));
            }
            [_unsubscribedCategoryCells addObject:cell];
            [newCategoryIDCellMap setObject:cell forKey:model.categoryID];
        }
    }
    
    NSArray * allOldCells = [_categoryIDCellMap allValues];
    for (ArticleCategorySubscribeCell * cell in allOldCells) {
        NSString * categoryID = cell.model.categoryID;
        if (!isEmptyString(categoryID) && ![newCategoryIDCellMap objectForKey:categoryID]) {
            [cell removeFromSuperview];
        }
    }
    self.categoryIDCellMap = newCategoryIDCellMap;
}

- (void)reloadData
{
    [self prepareCells];
    
    [self refreshUI];
    [self refreshSubscribeBadge];
    [self reloadThemeUI];
}


- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor clearColor];//[UIColor tt_themedColorForKey:kColorBackground3];
    
    NSString *bgColorKey = kColorBackground4;
    
    self.contentScrollView.backgroundColor = [UIColor tt_themedColorForKey:bgColorKey];
    _dashBorderLayer.strokeColor = [[UIColor tt_themedColorForKey:kColorLine4] CGColor];
    
    UIColor * color = [UIColor tt_themedColorForKey:bgColorKey];
//    color = [color colorWithAlphaComponent:.96f];
    _topView.backgroundColor = color;
    _topViewBottomLine.backgroundColor = [UIColor tt_themedColorForKey:kColorLine7];
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (_longPressView == nil) {
            self.editing = YES;
            CGPoint currentPoint = [recognizer locationInView:self.containerView];
            self.longPressView = [self subscribedCellContainsPoint:currentPoint];
            
            [_longPressView refreshDraggingStatus:YES];
            
            [self.containerView bringSubviewToFront:_longPressView];
            
            // 统计 - 长按进入编辑状态
            wrapperTrackEvent(@"channel_manage", @"long_press");
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded){
        if (_longPressView) {
            //[UIView animateWithDuration:.1 animations:^{
                [_longPressView refreshDraggingStatus:NO];
//            } completion:^(BOOL finished) {
                self.longPressView = nil;
//            }];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(!_editing)
    {
        [self handlePanClose:recognizer];
        return;
    }
    
    CGPoint currentPoint = [recognizer locationInView:self.containerView];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _panGestureBeganPoint = currentPoint;
            if (self.longPressView) {
                self.draggingView = self.longPressView;
            } else {
                self.draggingView = [self draggingViewByPanRecognizer:recognizer];
            }
            _lastHitViewCenter = _draggingView.center;
            [_draggingView refreshDraggingStatus:YES];
            [self.containerView bringSubviewToFront:_draggingView];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if (_draggingView) {
                [_draggingView refreshDraggingStatus:NO];
                CGPoint center = _draggingView.center;
                if (center.y > CGRectGetMaxY(_moreCategoryLabel.frame)) {
                    ArticleCategorySubscribeCell * draggingView = _draggingView;
                    self.draggingView = nil;
                    [self reverseCategoryCellSubsribedStatus:draggingView];
                }
                else {
                    
                    [UIView animateWithDuration:0.25 animations:^{
                        _draggingView.center = _lastHitViewCenter;
                        
                    } completion:^(BOOL finished) {
                        self.draggingView = nil;
                    }];
                }
                
                // 统计 - 拖曳频道排序
                wrapperTrackEvent(@"channel_manage", @"subscribe_drag");
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_draggingView) {
                [self moveView:_draggingView fromPoint:_panGesturePreviousPoint toPoint:currentPoint];
                
                ArticleCategorySubscribeCell * hitView = [self subscribedCellContainsPoint:currentPoint];
                if (hitView) {
                    _lastHitViewCenter = hitView.center;
                    [self orderSubscribedViewBetweenDraggingViewAndHitView:hitView];
                    [self orderCellsByOrderIndex:_subscribedCategoryCells];
                    _userChanged = YES;
                    [UIView animateWithDuration:0.25 animations:^{
                        [self refreshSubscribedCellsFrame];
                    }];
                }
            }
        }
            break;
        default:
            break;
    }
    _panGesturePreviousPoint = currentPoint;
}

- (void)refreshSubscribedCellsFrame
{
    CGFloat x = 0;
    CGFloat y = self.titleLabel.bottom + [self offsetYForFirstSubscribedCell];
    
    for (NSUInteger i = 0; i < _subscribedCategoryCells.count; ++i) {
        ArticleCategorySubscribeCell * cell = [_subscribedCategoryCells objectAtIndex:i];
        
        if (cell != _draggingView) {
            cell.left = x;
            cell.top = y;
            cell.width = [ArticleCategorySubscribeCell articleCategorySubscribeCellWidth];
            cell.height = [ArticleCategorySubscribeCell articleCategorySubscribeCellHeight];
        }
        [cell refreshCategoryModel:cell.model];
        
        if ((i + 1) % kCellNumberPerRow == 0) {
            x = 0;
            CGFloat verticalGap = [self cellVerticalGap];
            y += ([ArticleCategorySubscribeCell articleCategorySubscribeCellHeight] + verticalGap);
        } else {
            CGFloat horizonGap = [self cellHorizontalGap];
            x += ([ArticleCategorySubscribeCell articleCategorySubscribeCellWidth] + horizonGap);
        }
    }
}

- (void)refreshUnsubscribedCellsFrame
{
    CGFloat x = 0;
    CGFloat y = self.moreCategoryLabel.bottom + [self offsetYForFirstUnsubscribedCell];
    
    for (NSUInteger i = 0; i < _unsubscribedCategoryCells.count; ++i) {
        ArticleCategorySubscribeCell * cell = [_unsubscribedCategoryCells objectAtIndex:i];
        
        cell.left = x;
        cell.top = y;
        cell.width = [ArticleCategorySubscribeCell articleCategorySubscribeCellWidth];
        cell.height = [ArticleCategorySubscribeCell articleCategorySubscribeCellHeight];
        
        [cell refreshCategoryModel:cell.model];
        
        if ((i + 1) % kCellNumberPerRow == 0) {
            x = 0;
            CGFloat verticalGap = [self cellVerticalGap];
            y += ([ArticleCategorySubscribeCell articleCategorySubscribeCellHeight] + verticalGap);
        } else {
            CGFloat horizonGap = [self cellHorizontalGap];
            x += ([ArticleCategorySubscribeCell articleCategorySubscribeCellWidth] + horizonGap);
        }
    }
}

- (void)refreshUI
{
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_viewWidth);
    }];
    
    [self refreshSubscribedCellsFrame];
    
    UIView *lastSubCell = [_subscribedCategoryCells lastObject];
    
    if (lastSubCell) {
        self.moreCategoryLabel.top = lastSubCell.bottom + [self moreCategoryLabelTopOffset];
        self.moreInfoLabel.bottom = _moreCategoryLabel.bottom - 2;
        
//        [self.moreCategoryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(lastSubCell.bottom + ([TTDeviceHelper isPadDevice] ? 50 : 30));
//            make.left.equalTo(self.titleLabel);
//        }];
//        [self.moreCategoryLabel setNeedsLayout];
//        [self.moreCategoryLabel layoutIfNeeded];
    }
    
    [self refreshUnsubscribedCellsFrame];
    
    UIView *lastUnsubCell = _unsubscribedCategoryCells.count > 0 ? [_unsubscribedCategoryCells lastObject] : nil;
    
    if (lastUnsubCell) {
        CGFloat horizonGap = [self cellHorizontalGap];
        CGFloat verticalGap = [self cellVerticalGap];
        
        if (_unsubscribedCategoryCells.count % kCellNumberPerRow != 0) {
            [self.moreCategoriesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(lastUnsubCell);
                make.left.mas_equalTo(lastUnsubCell.right + horizonGap);
                make.top.mas_equalTo(lastUnsubCell.top);
            }];
        } else {
            //新起一行
            [self.moreCategoriesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(lastUnsubCell);
                make.left.equalTo(@(0));
                make.top.mas_equalTo(lastUnsubCell.bottom + verticalGap);
            }];
        }
        
        [self toggleShowMoreCategoryLabel:YES];
    } else {
        [self.moreCategoriesButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@([ArticleCategorySubscribeCell articleCategorySubscribeCellHeight]));
            make.width.equalTo(@([ArticleCategorySubscribeCell articleCategorySubscribeCellWidth]));
            make.left.equalTo(@(0));
            make.top.greaterThanOrEqualTo(_moreCategoryLabel.mas_bottom).with.offset([self offsetYForFirstUnsubscribedCell]);
        }];
        
        if (![TTDeviceHelper isPadDevice]) {
            [self toggleShowMoreCategoryLabel:NO];
        } else {
            [self toggleShowMoreCategoryLabel:YES];
        }
    }
    NSString * title = @"更多频道";

    [self.moreCategoriesButton.titleLabel setFont:[UIFont systemFontOfSize:[ArticleCategorySubscribeCell articleCategorySubscribeCellTitleFontSizeWithText:title]]];
    
    [self.moreCategoriesButton layoutIfNeeded];
    CGFloat lineWidth = [TTDeviceHelper ssOnePixel];
    _dashBorderLayer.frame =  CGRectMake(lineWidth, lineWidth, _moreCategoriesButton.width - lineWidth * 2, _moreCategoriesButton.height - lineWidth * 2);
    _dashBorderLayer.path = [[UIBezierPath bezierPathWithRect:_dashBorderLayer.bounds] CGPath];
    
    
    CGFloat contentY = _moreCategoriesButton.bottom + self.bottomMaskView.height;
    if (![TTDeviceHelper isPadDevice]) {
        if (lastUnsubCell) {
            contentY = lastUnsubCell.bottom + 150/*self.bottomMaskView.height*/;
        } else {
            contentY = self.moreCategoryLabel.bottom + 150;
        }
        _moreCategoriesButton.hidden = YES;
    }

    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentY);
    }];
    
    _contentY = contentY;
    _contentScrollView.contentSize = CGSizeMake(_viewWidth, _contentY);
}

- (void)toggleShowMoreCategoryLabel:(BOOL)show
{
    self.moreCategoryLabel.hidden = !show;
    self.moreInfoLabel.hidden = !show;
}

- (CGFloat)offsetYForFirstUnsubscribedCell
{
    if ([TTDeviceHelper isPadDevice]) {
        return KUnsubscribedCellsTopPaddingForiPad;
    }
    else if ([TTDeviceHelper is736Screen]) {
        return 18.f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 20.f;
    }
    else
    {
        return KUnsubscribedCellsTopPadding;
    }
}

- (CGFloat)offsetYForFirstSubscribedCell
{
    if ([TTDeviceHelper isPadDevice]) {
        return KSubscribedCellsTopPaddingForiPad;
    }
    else if ([TTDeviceHelper is736Screen]) {
        return 18.f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 20.f;
    }
    else
    {
        return KSubscribedCellsTopPadding;
    }
}

- (CGFloat)cellHorizontalGap
{
    return [TTDeviceHelper isPadDevice] ? kCategoryCellHorizonGapForPad : [self categoryCellHorizonGap];
}

- (CGFloat)cellVerticalGap
{
    return [TTDeviceHelper isPadDevice] ? kCategoryCellVerticalGapForPad : [self categoryCellVerticalGap];
}

- (CGFloat)fontSize
{
//        return [TTDeviceHelper isPadDevice] ? 22 : 16;
    
    if ([TTDeviceHelper isPadDevice]) {
        return 22.f;
    }
    else if ([TTDeviceHelper is736Screen]) {
        return 18.f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 19.f;
    }
    else
    {
        return 16.f;
    }

}

- (CGFloat)infoLabelFontSize {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    }
    else if ([TTDeviceHelper is736Screen]) {
        return 13.3f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 12.f;
    }
    else
    {
        return 10.f;
    }
}

- (CGFloat)editButtonFontSize {
    if ([TTDeviceHelper isPadDevice]) {
        return 14.7f;
    }
    else if ([TTDeviceHelper is736Screen]) {
        return 14.7f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 14.f;
    }
    else
    {
        return 13.f;
    }
}

- (CGSize)editButtonSize {
    if ([TTDeviceHelper isPadDevice]) {
        return CGSizeMake(52, 24);
    }
    else if ([TTDeviceHelper is736Screen]) {
        return CGSizeMake(52, 24);
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return CGSizeMake(52, 24);
    }
    else
    {
        return CGSizeMake(47, 22);
    }
}

- (CGFloat)moreCategoryLabelTopOffset {
    if ([TTDeviceHelper isPadDevice]) {
        return 50.f;
    }
    else if ([TTDeviceHelper is736Screen]) {
        return 30.f;
    }
    else if([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice])
    {
        return 30.f;
    }
    else
    {
        return 23.f;
    }
}

//订阅列表重新排序，并且改变位置
- (void)orderSubscribedViewBetweenDraggingViewAndHitView:(ArticleCategorySubscribeCell *)hitView
{
    if (_draggingView == nil || hitView == nil) {
        return;
    }
    
    BOOL draggingViewIndexGreater = _draggingView.model.orderIndex > hitView.model.orderIndex;
    NSUInteger minIndex = MIN(_draggingView.model.orderIndex, hitView.model.orderIndex);
    NSUInteger maxIndex = MAX(_draggingView.model.orderIndex, hitView.model.orderIndex);
    
    NSUInteger hitViewOrderIndex = hitView.model.orderIndex;
    
    for (NSUInteger i = minIndex; i <= maxIndex; i++) {
        if (i < [_subscribedCategoryCells count]) {
            ArticleCategorySubscribeCell * cell = [_subscribedCategoryCells objectAtIndex:i];
            if (cell != _draggingView) {
                cell.model.orderIndex = cell.model.orderIndex + (draggingViewIndexGreater ? 1 : -1);
                [cell.model save];
            }
        }
    }
    
    _draggingView.model.orderIndex = hitViewOrderIndex;
    [_draggingView.model save];
}

- (void)orderCellsByOrderIndex:(NSMutableArray *)array
{
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ArticleCategorySubscribeCell * c1 = obj1;
        ArticleCategorySubscribeCell * c2 = obj2;
        if (c1.model.orderIndex < c2.model.orderIndex) return NSOrderedAscending;
        if (c1.model.orderIndex > c2.model.orderIndex) return NSOrderedDescending;
        return NSOrderedSame;
        
    }];
}

- (void)moveView:(UIView *)view fromPoint:(CGPoint)fPoint toPoint:(CGPoint)tPoint
{
    CGPoint detlaPoint = CGPointZero;
    detlaPoint.x = fPoint.x - tPoint.x;
    detlaPoint.y = fPoint.y - tPoint.y;
    
    CGPoint originCenter = view.center;
    CGPoint resultCenter = CGPointZero;
    resultCenter.x = originCenter.x - detlaPoint.x;
    resultCenter.y = originCenter.y - detlaPoint.y;
    view.center = resultCenter;
}


- (ArticleCategorySubscribeCell *)draggingViewByPanRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint dragPoint = [recognizer locationInView:self.containerView];
    return [self subscribedCellContainsPoint:dragPoint];
}

//返回订阅列表中包含了指定point的cell, 推荐和dragingView不返回
- (ArticleCategorySubscribeCell *)subscribedCellContainsPoint:(CGPoint)point
{
    for (ArticleCategorySubscribeCell * cell in _subscribedCategoryCells) {
        
        if (cell == _draggingView) {
            continue;
        }
        
        if (CGRectContainsPoint(cell.frame, point)) {
            if ([cell isCanNotChangeCell]) {
                return nil;
            }
            return cell;
        }
    }
    return nil;
}

- (void)save
{
    [TTArticleCategoryManager sharedManager].lastAddedCategory = _lastAddCategoryModel;
    [[TTArticleCategoryManager sharedManager] updateSubScribedCategoriesOrderIndex];
    [[TTArticleCategoryManager sharedManager] saveWithNotify:_userChanged];
    if (_userChanged) {
        // 直接同步
        [[TTArticleCategoryManager sharedManager] startGetCategory:_userChanged];
    }
    _userChanged = NO;
}

- (void)reverseCategoryCellSubsribedStatus:(ArticleCategorySubscribeCell *)cell
{
    if (cell == nil || [cell isCanNotChangeCell]) {
        return;
    }
    
    _userChanged = YES;
    
    [cell.superview bringSubviewToFront:cell];
    if (cell.model.subscribed) {
        [_unsubscribedCategoryCells insertObject:cell atIndex:0];
        [_subscribedCategoryCells removeObject:cell];
        [[TTArticleCategoryManager sharedManager] unSubscribe:cell.model];
    }
    else {
        [_subscribedCategoryCells addObject:cell];
        [_unsubscribedCategoryCells removeObject:cell];
        [[TTArticleCategoryManager sharedManager] subscribe:cell.model];
    }
    for (int i = 0; i < [_subscribedCategoryCells count]; i ++) {
        ArticleCategorySubscribeCell * cell = [_subscribedCategoryCells objectAtIndex:i];
        cell.model.orderIndex = i;
        [cell.model save];
    }
    NSInteger tmpIndex = [_subscribedCategoryCells count];
    for (ArticleCategorySubscribeCell * cell in _unsubscribedCategoryCells) {
        cell.model.orderIndex = tmpIndex;
        [cell.model save];
        tmpIndex ++;
    }

    [self orderCellsByOrderIndex:_subscribedCategoryCells];
    [self orderCellsByOrderIndex:_unsubscribedCategoryCells];
    [UIView animateWithDuration:0.25 animations:^{
        [self refreshUI];
    } completion:^(BOOL finished) {
        [[TTArticleCategoryManager sharedManager] saveWithNotify:YES];
    }];
    
    
    if (cell.model.subscribed) {
        self.lastAddCategoryModel = cell.model;
    }
    else {
        if (_lastAddCategoryModel != nil && [cell.model.categoryID isEqualToString:_lastAddCategoryModel.categoryID]) {
            self.lastAddCategoryModel = nil;
        }
    }
    
    
    if(cell.model.subscribed)
    {
        [cell setEditing:_editing];
    }
    else
    {
        [cell setEditing:NO];
    }
}

- (void)closeClicked:(id)sender
{
    wrapperTrackEvent(@"channel_manage", @"close");
    [self close];
}

- (void)didShow:(void(^)(void))showBlock didDisAppear:(void(^)(void))disappearBlock {
    if (showBlock) {
        self.didShowBlock = showBlock;
    }
    if (disappearBlock) {
        self.didDisappearBlock = disappearBlock;
    }
}

#pragma mark -- ArticleCategorySubscribeCellDelegate

- (void)categoryCellDidClicked:(ArticleCategorySubscribeCell *)cell
{
    if([[cell model] subscribed] && !_editing)
    {
        // 统计 - 非编辑状态，频道面板中，点击"我的频道"中的频道
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:0];
        [extra setValue:[cell model].categoryID forKey:@"channel_name"];
        wrapperTrackEventWithCustomKeys(@"channel_manage", @"click_mine", nil, nil, extra);
        
        // 统计 - 在频道面板中点击“订阅”频道
        if ([[cell model].categoryID isEqualToString:kTTSubscribeCategoryID]) {
            wrapperTrackEvent(@"subscription", @"enter_panel");
        }
//        cell.model.enterType = @"none";
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:cell.model forKey:@"model"];
        self.lastAddCategoryModel = nil;
        [self close];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryManagementViewCategorySelectedNotification object:self userInfo:userInfo];
    }
    else
    {
        
        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionary];
        [extraInfo setValue:cell.model.categoryID forKey:@"channel_name"];
        
        if ([cell model].subscribed) {
            wrapperTrackEventWithCustomKeys(@"channel_manage", @"remove", nil, nil, extraInfo);
        } else {
            wrapperTrackEventWithCustomKeys(@"channel_manage", @"click_more", nil, nil, extraInfo);
        }
        
        [self reverseCategoryCellSubsribedStatus:cell];
    }
}

- (void)closeButtonClicked:(ArticleCategorySubscribeCell *)cell
{
    [self reverseCategoryCellSubsribedStatus:cell];
}

#pragma mark -- UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _longPressGestureRecognizer && otherGestureRecognizer == _panGestureRecognizer){
        return YES;
    }

    if (gestureRecognizer == _panGestureRecognizer && otherGestureRecognizer == _contentScrollView.panGestureRecognizer) {
        if ([self isEditing]) {
            return NO;
        }
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _longPressGestureRecognizer) {
        CGPoint location = [gestureRecognizer locationInView:self.closeButton];
        if (CGRectContainsPoint(self.closeButton.bounds, location)) {
            return NO;
        }
    }
//    
//    if ([self isEditing] && gestureRecognizer == _contentScrollView.panGestureRecognizer) {
//        return NO;
//    }
    
    return YES;
}

- (void)handlePanClose:(UIPanGestureRecognizer *)recognizer {
    CGPoint locationPoint = [recognizer locationInView:recognizer.view.superview];
    //CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    CGPoint velocityPoint = [recognizer velocityInView:recognizer.view.superview];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.lastY = locationPoint.y;
            if (velocityPoint.y > 0 && _contentScrollView.contentOffset.y <= 0 && !self.isDraggingFloatView) {
                self.isDraggingFloatView = YES;
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (velocityPoint.y > 0 && _contentScrollView.contentOffset.y <= 0 && !self.isDraggingFloatView) {
                self.isDraggingFloatView = YES;
            }
            if (self.isDraggingFloatView) {
                CGFloat step = locationPoint.y - self.lastY;
                CGRect frame = self.frame;
                frame.origin.y += step;
                if (frame.origin.y < self.originY) {
                    frame.origin.y = self.originY;
                }
                if (frame.origin.y > self.superview.height) {
                    frame.origin.y = self.superview.height;
                }
                self.frame = frame;
                if (frame.size.height > 0) {
                    self.rootMaskView.alpha = 1 - (frame.origin.y - self.originY) / frame.size.height;
                }
            }
            self.lastY = locationPoint.y;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (self.isDraggingFloatView) {
                BOOL complete = ((velocityPoint.y > -100 && self.top > 0.3 * self.frame.size.height) || velocityPoint.y > 500);
                
                if (complete) {
                    [self close];
                } else {
                    CGRect frame = self.frame;
                    frame.origin.y = self.originY;
                    [UIView animateWithDuration:0.15 animations:^{
                        self.frame = frame;
                        self.rootMaskView.alpha = 1;
                    } completion:^(BOOL finished) {
                    }];
                }
                
            }
            self.isDraggingFloatView = NO;
            break;
        }
        default:
            break;
    }
}

- (void)closeIfNeeded
{
    if (self.superview || self.rootMaskView.superview) {
        [self close];
    }
}

- (void)close
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryManagerViewWillHideNotification object:self userInfo:nil];
    
    [UIView animateWithDuration:0.15 customTimingFunction:CustomTimingFunctionQuadIn animation:^{
        self.top = self.superview.height;
        self.rootMaskView.alpha = 0;
    } completion:^(BOOL finished) {
        [[TTArticleCategoryManager sharedManager] clearCategoryTipNewWithSave:NO];
        [TTArticleCategoryManager setHasNewTip:NO];
        
        [self setEditing:NO];
        
        [self save];

        [self.rootMaskView removeFromSuperview];
        [self removeFromSuperview];
        
        self.isShowing = NO;
        
        if (self.didDisappearBlock) {
            self.didDisappearBlock();
        }
    }];
}


- (void)showInView:(UIView *)view
{
    [view addSubview:self.rootMaskView];
    [view addSubview:self];
    
    self.isShowing = YES;
    
    self.contentScrollView.contentOffset = CGPointMake(0, -self.contentScrollView.contentInset.top);
    
    self.rootMaskView.frame = view.bounds;
    self.rootMaskView.alpha = 0;
    self.frame = view.bounds;
    self.top = view.height;
    self.height = view.height;
    self.topViewBottomLine.alpha = 0;
    
    [UIView animateWithDuration:0.35
           customTimingFunction:CustomTimingFunctionQuadIn
                          delay:0.f
         usingSpringWithDamping:0.92f
          initialSpringVelocity:20
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.top = 0;
                         self.rootMaskView.alpha = 1;
                     } completion:^(BOOL finished) {
                         self.topViewBottomLine.alpha = 1;
                     }];
    //每次显示重新获取频道推荐数据
    [[TTArticleCategoryManager sharedManager] startGetUnsubscribedCategory];
    
    if (self.didShowBlock) {
        self.didShowBlock();
    }
    
}

- (void)receiveBadgeRefreshedNotification:(NSNotification*)notification
{
    [self refreshSubscribeBadge];
}

- (void)receiveCategoryHasChangeNotification:(NSNotification*)notification
{
    [self reloadData];
}

- (void)refreshSubscribeBadge
{
    [_subscribeCell setShowBadge:[[ArticleBadgeManager shareManger].subscribeHasNewUpdatesIndicator boolValue]];
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + scrollView.contentInset.top <= 0 && !_topViewBottomLine.hidden) {
        _topViewBottomLine.hidden = YES;
    } else if (scrollView.contentOffset.y + scrollView.contentInset.top > 1 && _topViewBottomLine.hidden) {
        _topViewBottomLine.hidden = NO;
    }
    
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        scrollView.contentOffset = contentOffset;
        if (!self.isDraggingFloatView) {
            self.isDraggingFloatView = YES;
        }
    }
    if (self.isDraggingFloatView && self.top != self.originY) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        scrollView.contentOffset = contentOffset;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _contentScrollView.contentSize = CGSizeMake(_viewWidth, _contentY);
}

- (void)moreCategoriesButtonClicked:(id)sender
{
//    wrapperTrackEvent(@"channel_manage", @"more_channel");
//    UIViewController * topVC = [TTUIResponderHelper topViewControllerFor: self];
//    UIViewController * webViewVC = nil;
//    webViewVC = [[FRConcernGuideViewController alloc] init];
//    TTNavigationController * nv = [[TTNavigationController alloc] initWithRootViewController:webViewVC];
//    nv.ttDefaultNavBarStyle = @"White";
//    nv.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [topVC presentViewController:nv animated:YES completion:nil];
}

@end

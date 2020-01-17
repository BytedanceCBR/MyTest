#import "PopoverView.h"
#import "PopoverViewCell.h"
#import <TTThemed/SSThemed.h>
#import <TTRoute.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTBaseLib/UIImageAdditions.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>

static CGFloat const kPopoverViewMargin = 8.f;        ///< 边距
static CGFloat const kPopoverViewCellHeight = 44.f;   ///< cell指定高度
static CGFloat const kPopoverViewBgLeftEdge = 8.f;  ///< 阴影宽度
static CGFloat const kPopoverViewBgTopEdge = 15.f;  ///< 阴影宽度
static CGFloat const kPopoverViewBgRightEdge = 7.f;  ///< 阴影宽度

static NSString *kPopoverCellReuseId = @"_PopoverCellReuseId";

float PopoverViewDegreesToRadians(float angle)
{
    return angle*M_PI/180;
}

@interface PopoverView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

#pragma mark - UI
@property (nonatomic, weak) UIWindow *keyWindow;                ///< 当前窗口
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *shadeView;                ///< 遮罩层
@property (nonatomic, strong) SSThemedImageView *bgMaskImageView; ///< 背景图
@property (nonatomic, strong) SSThemedImageView *bgImageView; ///< 背景图
//@property (nonatomic, weak) CAShapeLayer *borderLayer;          ///< 边框Layer
@property (nonatomic, weak) UITapGestureRecognizer *tapGesture; ///< 点击背景阴影的手势
@property (nonatomic, strong) UIToolbar *bgCoverView; //背景蒙层
#pragma mark - Data
@property (nonatomic, copy) NSArray<PopoverAction *> *actions;
@property (nonatomic, assign) CGFloat windowWidth;   ///< 窗口宽度
@property (nonatomic, assign) CGFloat windowHeight;  ///< 窗口高度
@property (nonatomic, assign) BOOL isUpward;         ///< 箭头指向, YES为向上, 反之为向下, 默认为YES.

@end

@implementation PopoverView

#pragma mark - Lift Cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    [self initialize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabDidChange:) name:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tableView.frame = self.bounds;
    _bgCoverView.frame = CGRectMake(0, 0, self.bounds.size.width + kPopoverViewBgLeftEdge + kPopoverViewBgRightEdge, self.bounds.size.height + 2*kPopoverViewBgTopEdge);
    _bgMaskImageView.frame = CGRectMake(0, 0, self.bounds.size.width + kPopoverViewBgLeftEdge + kPopoverViewBgRightEdge, self.bounds.size.height + 2*kPopoverViewBgTopEdge);
    _bgImageView.frame = CGRectMake(-kPopoverViewBgLeftEdge, -kPopoverViewBgTopEdge, self.bounds.size.width + kPopoverViewBgLeftEdge + kPopoverViewBgRightEdge, self.bounds.size.height + 2*kPopoverViewBgTopEdge);
}

#pragma mark - Setter
- (void)setHideAfterTouchOutside:(BOOL)hideAfterTouchOutside
{
    _hideAfterTouchOutside = hideAfterTouchOutside;
    _tapGesture.enabled = _hideAfterTouchOutside;
}

- (void)setShowShade:(BOOL)showShade
{
    _showShade = showShade;
    
    _shadeView.backgroundColor = _showShade ? [UIColor colorWithWhite:0.f alpha:0.18f] : [UIColor clearColor];
    
//    if (_borderLayer) {
//
//        _borderLayer.strokeColor = _showShade ? [UIColor clearColor].CGColor : _tableView.separatorColor.CGColor;
//    }
}

- (void)setStyle:(PopoverViewStyle)style
{
    _style = style;
    
    _tableView.separatorColor = [PopoverViewCell bottomLineColorForStyle:_style];
    
    if (_style == PopoverViewStyleDefault) {
        self.backgroundColor = [UIColor clearColor];
    } else if (_style == PopoverViewStyleDark) {
        self.backgroundColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.00];
    }
}

#pragma mark - Private
/*! @brief 初始化相关 */
- (void)initialize
{
    // data
    _actions = @[];
    _isUpward = YES;
    _style = PopoverViewStyleDefault;
    _arrowStyle = PopoverViewArrowStyleRound;
    
    // current view
    self.backgroundColor = [UIColor clearColor];
    
    // keyWindow
    _keyWindow = [UIApplication sharedApplication].keyWindow;
    _windowWidth = CGRectGetWidth(_keyWindow.bounds);
    _windowHeight = CGRectGetHeight(_keyWindow.bounds);
    
    // shadeView
    _shadeView = [[UIView alloc] initWithFrame:_keyWindow.bounds];
    [self setShowShade:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
    [_shadeView addGestureRecognizer:tapGesture];
    _tapGesture = tapGesture;
    _tapGesture.delegate = self;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
    [_shadeView addGestureRecognizer:panGesture];
    panGesture.delegate = self;
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [PopoverViewCell bottomLineColorForStyle:_style];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.estimatedRowHeight = 0.0;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView registerClass:[PopoverViewCell class] forCellReuseIdentifier:kPopoverCellReuseId];
    
    _bgMaskImageView = [[SSThemedImageView alloc]initWithFrame:CGRectZero];
    
    UIImage *bgImage  = [UIImage themedImageNamed:@"bg_release_titlebar"];
    CGFloat top = bgImage.size.height/2.0 - 0.5;
    CGFloat left = bgImage.size.width/2.0 - 0.5;
    CGFloat bottom = bgImage.size.height/2.0 + 0.5;
    CGFloat right = bgImage.size.width/2.0 + 0.5;
    
    UIEdgeInsets edge = UIEdgeInsetsMake(top,left,bottom,right);
    UIImage *scretchedImage = [bgImage resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    [_bgMaskImageView setImage:scretchedImage];

    _bgImageView = [SSThemedImageView new];
    _bgImageView.maskView = _bgMaskImageView;
    UIImage *image = [UIImage imageWithUIColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    _bgImageView.image = image;
    [self addSubview:_bgImageView];
    _bgCoverView = [[UIToolbar alloc] init];
    _bgCoverView.barStyle = UIBarStyleBlackTranslucent;
    [_bgImageView addSubview:_bgCoverView];
    [self addSubview:_tableView];
}

/**
 显示弹窗指向某个点
 */
- (void)showToPoint:(CGPoint)toPoint
{
    // 截取弹窗时相关数据
    CGFloat arrowWidth = 28;
    CGFloat cornerRadius = 6.f;
//    CGFloat arrowCornerRadius = 2.5f;
//    CGFloat arrowBottomCornerRadius = 4.f;
    
    // 如果是菱角箭头的话, 箭头宽度需要小点.
    if (_arrowStyle == PopoverViewArrowStyleTriangle) {
        arrowWidth = 22.0;
    }
    
    // 如果箭头指向的点过于偏左或者过于偏右则需要重新调整箭头 x 轴的坐标
    CGFloat minHorizontalEdge = kPopoverViewMargin + cornerRadius + arrowWidth/2 + 2;
    if (toPoint.x < minHorizontalEdge) {
        toPoint.x = minHorizontalEdge;
    }
    if (_windowWidth - toPoint.x < minHorizontalEdge) {
        toPoint.x = _windowWidth - minHorizontalEdge;
    }
    
    // 遮罩层
    _shadeView.alpha = 0.f;
    [_keyWindow.rootViewController.view addSubview:_shadeView];
    
    // 刷新数据以获取具体的ContentSize
    [_tableView reloadData];
    // 根据刷新后的ContentSize和箭头指向方向来设置当前视图的frame
    CGFloat currentW = [self calculateMaxWidth]; // 宽度通过计算获取最大值
    CGFloat currentH = _tableView.contentSize.height;
    
    // 如果 actions 为空则使用默认的宽高
    if (_actions.count == 0) {
        currentW = 150.0;
        currentH = 20.0;
    }
    
    // 限制最高高度, 免得选项太多时超出屏幕
    CGFloat maxHeight = _isUpward ? (_windowHeight - toPoint.y - kPopoverViewMargin) : (toPoint.y - CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
    if (currentH > maxHeight) { // 如果弹窗高度大于最大高度的话则限制弹窗高度等于最大高度并允许tableView滑动.
        currentH = maxHeight;
        _tableView.scrollEnabled = YES;
        if (!_isUpward) { // 箭头指向下则移动到最后一行
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_actions.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
    CGFloat currentX = toPoint.x - currentW/2, currentY = toPoint.y;
    // x: 窗口靠左
    if (toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = kPopoverViewMargin;
    }
    // x: 窗口靠右
    if (_windowWidth - toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = _windowWidth - kPopoverViewBgRightEdge - currentW + 9.f;//9.f是相机宽度的一半
    }
    // y: 箭头向下
    if (!_isUpward) {
        currentY = toPoint.y - currentH;
    }
    
    self.frame = CGRectMake(currentX, currentY, currentW, currentH);
    
    // 截取箭头
    CGPoint arrowPoint = CGPointMake(toPoint.x - CGRectGetMinX(self.frame), _isUpward ? 0 : currentH); // 箭头顶点在当前视图的坐标
    
    [_keyWindow.rootViewController.view addSubview:self];
    
    // 弹出动画
    CGRect oldFrame = self.frame;
    self.layer.anchorPoint = CGPointMake(arrowPoint.x/currentW, _isUpward ? 0.f : 1.f);
    self.frame = oldFrame;
    _shadeView.alpha = 1.f;
}

/*! @brief 计算最大宽度 */
- (CGFloat)calculateMaxWidth
{
    CGFloat maxWidth = 0.f, titleLeftEdge = 12.f, imageWidth = 0.f, titleRightEdge = 17.f;
    UIFont *titleFont = [PopoverViewCell titleFont];

    for (PopoverAction *action in _actions) {

        imageWidth = 0.f;
        titleLeftEdge = 0.f;

        imageWidth = 28.f;

        CGFloat titleWidth = [action.title sizeWithAttributes:@{NSFontAttributeName : titleFont}].width;
        CGFloat contentWidth = PopoverViewCellHorizontalMargin*2 + imageWidth + titleLeftEdge + titleWidth + titleRightEdge + 10;
        if (contentWidth > maxWidth) {
            maxWidth = ceil(contentWidth); // 获取最大宽度时需使用进一取法, 否则Cell中没有图片时会可能导致标题显示不完整.
        }
    }

    // 如果最大宽度大于(窗口宽度 - kPopoverViewMargin*2)则限制最大宽度等于(窗口宽度 - kPopoverViewMargin*2)
    if (maxWidth > CGRectGetWidth(_keyWindow.bounds) - kPopoverViewMargin*2) {
        maxWidth = CGRectGetWidth(_keyWindow.bounds) - kPopoverViewMargin*2;
    }
    
    return maxWidth;
}

/**
 点击外部隐藏弹窗
 */
- (void)hide:(UIGestureRecognizer *)gesture
{
    __strong PopoverView *strongSelf = self;
    if(strongSelf.didHideBlock) {
        strongSelf.didHideBlock();
    }
    [UIView animateWithDuration:0.1f animations:^{
        strongSelf.shadeView.alpha = 0;
        strongSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [strongSelf.shadeView removeFromSuperview];
        [strongSelf removeFromSuperview];
    }];
}

#pragma mark - Public
+ (instancetype)popoverView
{
    return [[self alloc] init];
}

- (void)showToView:(UIView *)pointView withActions:(NSArray<PopoverAction *> *)actions
{
    // 判断 pointView 是偏上还是偏下
    CGRect pointViewRect = [pointView.superview convertRect:pointView.frame toView:_keyWindow];
    CGFloat pointViewUpLength = CGRectGetMinY(pointViewRect);
    CGFloat pointViewDownLength = _windowHeight - CGRectGetMaxY(pointViewRect);
    // 弹窗箭头指向的点
    CGPoint toPoint = CGPointMake(CGRectGetMidX(pointViewRect), 0);
    // 弹窗在 pointView 顶部
    if (pointViewUpLength > pointViewDownLength) {
        toPoint.y = pointViewUpLength - 5;
    }
    // 弹窗在 pointView 底部
    else {
        toPoint.y = CGRectGetMaxY(pointViewRect) + 14;
    }
    
    // 箭头指向方向
    _isUpward = pointViewUpLength <= pointViewDownLength;
    
    if (!actions) {
        _actions = @[];
    } else {
        _actions = [actions copy];
    }
    
    [self showToPoint:toPoint];
}

- (void)showToPoint:(CGPoint)toPoint withActions:(NSArray<PopoverAction *> *)actions
{
    if (!actions) {
        _actions = @[];
    } else {
        _actions = [actions copy];
    }
    
    // 计算箭头指向方向
    _isUpward = toPoint.y <= _windowHeight - toPoint.y;
    
    [self showToPoint:toPoint];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _actions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPopoverViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopoverViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPopoverCellReuseId];
    cell.style = _style;
    [cell setAction:_actions[indexPath.row]];
    if (_style == PopoverViewStyleDefault) {
        [cell showBottomLine:YES];
    } else {
        [cell showBottomLine:NO];
    }
    cell.backgroundColor = [UIColor clearColor];//关键语句
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopoverAction *action = _actions[indexPath.row];
    action.handler ? action.handler(action) : NULL;
    [BDTrackerProtocol eventV3:@"publisher_function_list_click" params:@{@"button_name" : !isEmptyString(action.label) ? action.label : @"",
                                                                        @"rank" : @(indexPath.row + 1),
                                                                        @"entrance" : !isEmptyString(self.entrance) ? self.entrance : @"",
                                                                        @"tab_name" : !isEmptyString(self.tabName) ? self.tabName : @"",
                                                                        @"category_name" : !isEmptyString(self.categoryName) ? self.categoryName : @""
                                                                        }];
    _actions = nil;
    [_shadeView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)tabDidChange:(NSNotification *)notification {
    [self hide:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

@end


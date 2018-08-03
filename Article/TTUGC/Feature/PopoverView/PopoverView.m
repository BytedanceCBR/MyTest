

#import "PopoverView.h"
#import "PopoverViewCell.h"
#import "SSThemed.h"
#import "TTArticleTabBarController.h"

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
@property (nonatomic, strong) SSThemedImageView *bgImageView; ///< 背景图
//@property (nonatomic, weak) CAShapeLayer *borderLayer;          ///< 边框Layer
@property (nonatomic, weak) UITapGestureRecognizer *tapGesture; ///< 点击背景阴影的手势

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabDidChange:) name:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tableView.frame = self.bounds;
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
    }
    else {
        
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
    
    _bgImageView = [[SSThemedImageView alloc]initWithFrame:CGRectZero];
    
    UIImage *bgImage  = [UIImage themedImageNamed:@"bg_release_titlebar"];
    CGFloat top = bgImage.size.height/2.0 - 0.5;
    CGFloat left = bgImage.size.width/2.0 - 0.5;
    CGFloat bottom = bgImage.size.height/2.0 + 0.5;
    CGFloat right = bgImage.size.width/2.0 + 0.5;
    
    UIEdgeInsets edge = UIEdgeInsetsMake(top,left,bottom,right);
    UIImage *scretchedImage = [bgImage resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    [_bgImageView setImage:scretchedImage];
    [self addSubview:_bgImageView];

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
//    CGFloat maskTop = 0; // 顶部Y值
//    CGFloat maskBottom = _isUpward ? currentH : currentH - kPopoverViewArrowHeight; // 底部Y值
//    UIBezierPath *maskPath = [UIBezierPath bezierPath];
//    // 左上圆角
//    [maskPath moveToPoint:CGPointMake(0, cornerRadius + maskTop)];
//    [maskPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius + maskTop)
//                        radius:cornerRadius
//                    startAngle:PopoverViewDegreesToRadians(180)
//                      endAngle:PopoverViewDegreesToRadians(270)
//                     clockwise:YES];
//    // 箭头向上时的箭头位置
//    if (_isUpward) {
//
//        [maskPath addLineToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, kPopoverViewArrowHeight)];
//        // 菱角箭头
//        if (_arrowStyle == PopoverViewArrowStyleTriangle) {
//
//            [maskPath addLineToPoint:arrowPoint];
//            [maskPath addLineToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, kPopoverViewArrowHeight)];
//        }
//        else {
//
//            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowCornerRadius, arrowCornerRadius)
//                             controlPoint:CGPointMake(arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius, kPopoverViewArrowHeight)];
//            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowCornerRadius, arrowCornerRadius)
//                             controlPoint:arrowPoint];
//            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, kPopoverViewArrowHeight)
//                             controlPoint:CGPointMake(arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius, kPopoverViewArrowHeight)];
//        }
//    }
//    // 右上圆角
//    [maskPath addLineToPoint:CGPointMake(currentW - cornerRadius, maskTop)];
//    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskTop + cornerRadius)
//                        radius:cornerRadius
//                    startAngle:PopoverViewDegreesToRadians(270)
//                      endAngle:PopoverViewDegreesToRadians(0)
//                     clockwise:YES];
//    // 右下圆角
//    [maskPath addLineToPoint:CGPointMake(currentW, maskBottom - cornerRadius)];
//    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskBottom - cornerRadius)
//                        radius:cornerRadius
//                    startAngle:PopoverViewDegreesToRadians(0)
//                      endAngle:PopoverViewDegreesToRadians(90)
//                     clockwise:YES];
//    // 箭头向下时的箭头位置
//    if (!_isUpward) {
//
//        [maskPath addLineToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, currentH - kPopoverViewArrowHeight)];
//        // 菱角箭头
//        if (_arrowStyle == PopoverViewArrowStyleTriangle) {
//
//            [maskPath addLineToPoint:arrowPoint];
//            [maskPath addLineToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, currentH - kPopoverViewArrowHeight)];
//        }
//        else {
//
//            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowCornerRadius, currentH - arrowCornerRadius)
//                             controlPoint:CGPointMake(arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius, currentH - kPopoverViewArrowHeight)];
//            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowCornerRadius, currentH - arrowCornerRadius)
//                             controlPoint:arrowPoint];
//            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, currentH - kPopoverViewArrowHeight)
//                             controlPoint:CGPointMake(arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius, currentH - kPopoverViewArrowHeight)];
//        }
//    }
//    // 左下圆角
//    [maskPath addLineToPoint:CGPointMake(cornerRadius, maskBottom)];
//    [maskPath addArcWithCenter:CGPointMake(cornerRadius, maskBottom - cornerRadius)
//                        radius:cornerRadius
//                    startAngle:PopoverViewDegreesToRadians(90)
//                      endAngle:PopoverViewDegreesToRadians(180)
//                     clockwise:YES];
//    [maskPath closePath];
//    // 截取圆角和箭头
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = self.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.layer.mask = maskLayer;
//    // 边框 (只有在不显示半透明阴影层时才设置边框线条)
//    if (!_showShade) {
//        CAShapeLayer *borderLayer = [CAShapeLayer layer];
//        borderLayer.frame = self.bounds;
//        borderLayer.path = maskPath.CGPath;
//        borderLayer.lineWidth = 1;
//        borderLayer.fillColor = [UIColor clearColor].CGColor;
//        borderLayer.strokeColor = [UIColor clearColor].CGColor;
//        [self.layer addSublayer:borderLayer];
//        _borderLayer = borderLayer;
//    }
    
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
    CGFloat maxWidth = 0.f, titleLeftEdge = 12.f, imageWidth = 0.f, imageMaxHeight = kPopoverViewCellHeight - PopoverViewCellVerticalMargin*2, titleRightEdge = 17.f;
    CGSize imageSize = CGSizeZero;
    UIFont *titleFont = [PopoverViewCell titleFont];

    for (PopoverAction *action in _actions) {

        imageWidth = 0.f;
        titleLeftEdge = 0.f;

        imageWidth = 28.f;

        CGFloat titleWidth;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) { // iOS7及往后版本
            titleWidth = [action.title sizeWithAttributes:@{NSFontAttributeName : titleFont}].width;
        } else { // iOS6
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            titleWidth = [action.title sizeWithFont:titleFont].width;
#pragma GCC diagnostic pop
        }

        CGFloat contentWidth = PopoverViewCellHorizontalMargin*2 + imageWidth + titleLeftEdge + titleWidth + titleRightEdge;
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
    [strongSelf.shadeView removeFromSuperview];
    [strongSelf removeFromSuperview];
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
    [cell showBottomLine:NO];
    cell.backgroundColor = [UIColor clearColor];//关键语句
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopoverAction *action = _actions[indexPath.row];
    action.handler ? action.handler(action) : NULL;
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


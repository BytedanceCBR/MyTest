//
//  Created by xubinbin on 2020/8/14.
//

#import "FHMessageSwipeTableCell.h"

#define CELL_WIDTH self.bounds.size.width
#define CELL_HEIGHT self.bounds.size.height


@interface FHMessageSwipeTableCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *swipeOverlayView; // 滑动时覆盖在cell上
@property (nonatomic, strong) UIImageView *swipeImageView; //显示移动后的cell上的内容
@property (nonatomic, strong) FHMessageSwipeView *rightSwipeView; // 右滑展示的view
@property (nonatomic, strong) FHMessageSwipeView *leftSwipeView; //左滑展示的View
@property (nonatomic, strong) FHMessageSwipeView *gestureAnimationSwipeView;

@property (nonatomic, assign) SwipeTableCellStyle swipeStyle; // 滑动样式 默认右滑
@property (nonatomic, assign) SwipeViewTransfromMode transformMode; // swipeView的弹出效果
@property (nonatomic, strong) NSArray<FHMessageSwipeButton *> *rightSwipeButtons; // 右滑buttons
@property (nonatomic, strong) NSMutableSet *perviusHiddenViewSet;//已经隐藏的view

@property (nonatomic, assign) CGFloat swipeOffset; //滑动偏移量
@property (nonatomic, assign) CGFloat targetOffset; // 最终目标偏移量
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture; // 滑动手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture; // 点击手势

@property (nonatomic, assign) CGPoint panStartPoint; //滑动手势开始点击的坐标
@property (nonatomic, assign) CGFloat panStartOffset; //滑动手势的偏移量
@property (nonatomic, assign) BOOL isShowSwipeOverlayView; // 保证显示、隐藏swipeImageView方法只走一次

@property (nonatomic, strong) CADisplayLink *dispalyLink; //定时器 一秒60次

@end

@implementation FHMessageSwipeTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initDatas];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if([super initWithCoder:aDecoder])
    {
        [self initDatas];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initDatas];
}

/**
 *  初始化数据
 */
- (void)initDatas
{
    self.swipeStyle = SwipeTableCellStyleRightToLeft; //默认右滑
    self.transformMode = SwipeViewTransfromModeStatic;
    self.swipeOffset = 0.0;
    self.targetOffset = 0.0;
    self.swipeThreshold = 0.5;
    self.isAllowMultipleSwipe = NO;
    self.isShowSwipeOverlayView = NO;
    _hideSwipeViewWhenScrollTableView = YES;
    self.hideSwipeViewWhenClickSwipeButton = YES;
    self.swipeOverlayViewBackgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.isAllowExpand = YES;
    self.expandThreshold = 1.5;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
}

/**
 * 复用问题
 */
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if(self.panGesture)
    {
        self.panGesture.delegate = nil;
        [self removeGestureRecognizer:self.panGesture];
        self.panGesture = nil;
    }
    if(self.swipeOverlayView)
    {
        [self.swipeOverlayView removeFromSuperview];
        self.swipeOverlayView = nil;
        _rightSwipeView = _leftSwipeView = nil;
        self.rightSwipeButtons = @[];
    }
    if(self.dispalyLink)
    {
        [self.dispalyLink invalidate];
        self.dispalyLink = nil;
    }
    [self initDatas];
}

- (BOOL)isClose {
    if (_swipeOffset == 0) {
        return YES;
    }
    return NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint newP = [self convertPoint:point toView:_editView];
    if ([_editView pointInside:newP withEvent:event] && self.swipeOffset == -88) {
        return [_editView hitTest:newP withEvent:event];
    }
    UIView *view = [super hitTest:point withEvent:event];
    
    if (!view)
    {
        // bug fixed: swipeView显示后再次拖动swipeView 会出现快速闪动现象
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath != nil || point.y < 0) {
            return view;
        }
        
        // 若点击区域在tableView上 而不在cell上，滑动时也会自动隐藏swipeView
        for(FHMessageSwipeTableCell *cell in self.tableView.visibleCells) // 滑动cell时，自动隐藏swipeView
        {
            if(cell.hideSwipeViewWhenScrollTableView && !cell.swipeOverlayView.hidden)
            {
                [cell hiddenSwipeAnimationAtCell:YES];
            }
        }
    }
    return view;
}

// 更改滑动按钮的内容 如置顶变成取消置顶
- (void)refreshButtonContent
{
    if(self.rightSwipeView)
    {
        [self.rightSwipeView removeFromSuperview];
        self.rightSwipeView = nil;
    }
    self.rightSwipeButtons = @[];
    
    [self getSwipeButtons];
    [self createSwipeOverlayViewIfNeed];
}

#pragma mark -- 处理滑动手势
/**
 *  处理滑动手势 上左x<0、y<0  下右x>0、y>0
 */
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    CGPoint currentPanPoint = [pan translationInView:self];
    
    if(pan.state == UIGestureRecognizerStateBegan)
    {
        self.panStartPoint = currentPanPoint;
        self.panStartOffset = self.swipeOffset;
        
        [self createSwipeOverlayViewIfNeed];
        // 不允许多个cell同时能滑动，则移除上一个cell的滑动手势
        if(!_isAllowMultipleSwipe)
        {
            for(FHMessageSwipeTableCell * cell in self.tableView.visibleCells)
            {
                if(cell != self) [cell cancelPanGesture];
            }
        }
    }
    else if(pan.state == UIGestureRecognizerStateChanged)
    {
        CGFloat offset = self.panStartOffset + currentPanPoint.x - self.panStartPoint.x;
        // 重新swipeOffset的setter方法，监测滑动偏移量
        self.swipeOffset = [self filterSwipeOffset:offset];
    }
    else if(pan.state == UIGestureRecognizerStateEnded)
    {
        CGFloat velocity = [self.panGesture velocityInView:self].x;
        CGFloat inertiaThreshold = 300; // 每秒走过多少像素
        
        if(velocity > inertiaThreshold) // 快速左滑
        {
            self.targetOffset = self.swipeOffset < 0 ? 0 : (self.leftSwipeView ? self.leftSwipeView.frame.size.width : self.targetOffset);
        }
        else if(velocity < -inertiaThreshold) // 快速右滑
        {
            self.targetOffset = self.swipeOffset > 0 ? 0 : (self.rightSwipeView ? -self.rightSwipeView.frame.size.width : self.targetOffset);
        }
        
        self.targetOffset = [self filterSwipeOffset:self.targetOffset];
        [self gestureAnimationWithOffset:self.targetOffset animationView:self.targetOffset <= 0 ? self.rightSwipeView : self.leftSwipeView];
        if (self.swipeOffset == -88) {
            [self openCompleted];
        }
    }
}

/**
 * 创建用于显示滑动过后cell内容的SwipeImageView, 并在其上添加滑动按钮
 */
- (void)createSwipeOverlayViewIfNeed
{
    [self getSwipeTableViewCellStyle];
    [self getSwipeButtons];
    
    if(!self.swipeOverlayView)
    {
        _swipeOverlayView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, CELL_WIDTH - 30, CELL_HEIGHT - 12)];
        _swipeOverlayView.backgroundColor = self.swipeOverlayViewBackgroundColor;
        _swipeOverlayView.hidden = YES;
        self.editView.hidden = YES;
        
        _swipeImageView = [[UIImageView alloc] initWithFrame:self.swipeOverlayView.bounds];
        _swipeImageView.userInteractionEnabled = YES;
        
        [_swipeOverlayView addSubview:_swipeImageView];
        [self.contentView addSubview:self.swipeOverlayView];
    }
    
    // 获取swipeButton距swipeTableView上左下右的距离
    UIEdgeInsets edge = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([self.swipeDelegate respondsToSelector:@selector(tableView:swipeButtonEdgeAtIndexPath:)]) {
        edge = [self.swipeDelegate tableView:self.tableView swipeButtonEdgeAtIndexPath:[self.tableView indexPathForCell:self]];
    }
    if(self.rightSwipeButtons.count && !self.rightSwipeView)
    {
        _rightSwipeView = [[FHMessageSwipeView alloc] initWithButtons:self.rightSwipeButtons fromRight:YES cellHeght:CELL_HEIGHT edge:edge];
        // 改变rightSwipeView的frame 使其显示在swipeImageView的最右端
        _rightSwipeView.frame = CGRectMake(self.swipeImageView.bounds.size.width, 0, 108, CELL_HEIGHT);
        [self.swipeOverlayView addSubview:_rightSwipeView];
    }
}

/**
 * 判断滑动是否合法 并返回滑动距离
 */
- (CGFloat)filterSwipeOffset:(CGFloat)offset
{
    UIView *swipeView = offset > 0 ? self.leftSwipeView : self.rightSwipeView;
    if(!swipeView)
    {
        return 0.0;
    }
    else if(self.swipeStyle == SwipeTableCellStyleRightToLeft && offset > 0)
    {
        return 0.0;
    }
    return offset;
}

/**
 *  当滑动下一个cell时 取消上一个cell的滑动手势
 */
- (void)cancelPanGesture
{
    self.panGesture.enabled = NO;
    self.panGesture.enabled = YES;
    // 将上一个cell恢复原状
    if(self.swipeOffset){
        [self hiddenSwipeAnimationAtCell:YES];
    }
}

#pragma mark -- 处理点击手势

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    BOOL hidden = YES;
    if([self.swipeDelegate respondsToSelector:@selector(tableView:hiddenSwipeViewWhenTapCellAtIndexPath:)])
    {
        // 判断点击cell是否隐藏swipeView
        hidden = [self.swipeDelegate tableView:self.tableView hiddenSwipeViewWhenTapCellAtIndexPath:[self.tableView indexPathForCell:self]];
    }
    if(hidden)
    {
        [self hiddenSwipeAnimationAtCell:YES];
    }
}

#pragma mark -- 处理手势动画效果

/**
 *  隐藏滑动按钮 即将cell恢复原状
 *
 *  @param isAnimation 是否隐藏
 */
- (void)hiddenSwipeAnimationAtCell:(BOOL)isAnimation
{
    FHMessageSwipeView *aView = self.swipeOffset < 0 ? self.rightSwipeView : self.leftSwipeView;
    [self gestureAnimationWithOffset:isAnimation ? 0 : self.swipeOffset animationView:aView];
}

/**
 *  隐藏或显示滑动按钮的动画
 *
 *  @param offset        滑动按钮的偏移量
 *  @param animationView 右滑或左滑View
 */
- (void)gestureAnimationWithOffset:(CGFloat)offset animationView:(FHMessageSwipeView *)animationView
{
    self.gestureAnimationSwipeView = animationView;
    if(self.dispalyLink){
        [self.dispalyLink invalidate];
        self.dispalyLink = nil;
    }
    
    if(offset !=0 ){
        [self createSwipeOverlayViewIfNeed];
    }
    
    if(!self.gestureAnimationSwipeView){
        self.swipeOffset = offset;
        return;
    }
    
    self.gestureAnimationSwipeView.from = self.swipeOffset;
    self.gestureAnimationSwipeView.to = offset;
    self.gestureAnimationSwipeView.start = 0;
    self.dispalyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleAnimation:)];
    [self.dispalyLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

/**
 *  定时器处理动画
 */
- (void)handleAnimation:(CADisplayLink *)link
{
    if (!self.gestureAnimationSwipeView.start) {
        self.gestureAnimationSwipeView.start = link.timestamp;
    }
    
    CFTimeInterval elapsed = link.timestamp - self.gestureAnimationSwipeView.start;
    //滑动超过SwipeView的一半 自动显示或隐藏全部内容
    self.swipeOffset = [self.gestureAnimationSwipeView value:elapsed duration:self.gestureAnimationSwipeView.duration from:self.gestureAnimationSwipeView.from to:self.gestureAnimationSwipeView.to];
    
    if(elapsed >= self.gestureAnimationSwipeView.duration)
    {
        [link invalidate];
        self.dispalyLink = nil;
    }
}

#pragma mark -- UIGestureRecognizerDelegates

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.isCanGesture) {
        return NO;
    }
    if([gestureRecognizer isEqual:self.panGesture])
    {
        CGFloat panX = [self.panGesture translationInView:gestureRecognizer.view].x;
        BOOL isAllClose = YES;
        for(FHMessageSwipeTableCell *cell in self.tableView.visibleCells) {
            if (!cell.isClose) {
                isAllClose = NO;
            }
        }
        if (isAllClose && panX > 0.1) {
            return NO;
        }
        
        if(self.editing)  return NO; // tableView在编辑状态
        
        if(self.targetOffset != 0.0) return YES; // 已经在滑动状态
        
        // 使UITableView可以滚动 解决滑动tableView和滑动cell冲突的问题
        CGPoint panPoint = [self.panGesture translationInView:self];
        if(fabs(panPoint.x) < fabs(panPoint.y))
        {
            for(FHMessageSwipeTableCell *cell in self.tableView.visibleCells) // 滑动cell时，自动隐藏swipeView
            {
                if(cell.hideSwipeViewWhenScrollTableView && !cell.swipeOverlayView.hidden)
                {
                    [cell hiddenSwipeAnimationAtCell:YES];
                }
            }
            return NO;
        }
    }
    else if(gestureRecognizer == self.tapGesture)
    {
        //解决和didSelect冲突问题
        CGPoint tapPoint = [self.tapGesture locationInView:self];
        return CGRectContainsPoint(self.swipeImageView.frame, tapPoint);
    }
    return YES;
}

#pragma mark -- 获取滑动按钮、滑动按钮的样式
/**
 *  获取滑动button的样式
 */
- (void)getSwipeTableViewCellStyle
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    if([self.swipeDelegate respondsToSelector:@selector(tableView: styleOfSwipeButtonForRowAtIndexPath:)])
    {
        self.swipeStyle = [self.swipeDelegate tableView:self.tableView styleOfSwipeButtonForRowAtIndexPath:indexPath];
    }
}

/**
 *  获取滑动button
 */
- (void)getSwipeButtons
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    if(self.swipeStyle == SwipeTableCellStyleRightToLeft)
    {
        if([self.swipeDelegate respondsToSelector:@selector(tableView: rightSwipeButtonsAtIndexPath:)])
        {
            self.rightSwipeButtons = [[self.swipeDelegate tableView:self.tableView rightSwipeButtonsAtIndexPath:indexPath] mutableCopy];
        }
    }
}

- (void)getSwipeViewTransformMode
{
    if([self.swipeDelegate respondsToSelector:@selector(tableView:swipeViewTransformModeAtIndexPath:)])
    {
        self.transformMode = [self.swipeDelegate tableView:self.tableView swipeViewTransformModeAtIndexPath:[self.tableView indexPathForCell:self]];
    }
}

#pragma mark -- 私有方法

/**
 *  截取平移过后的cell上的内容 以图片的形式显示出来
 */


- (UIImage *)fecthTranslatedCellInfo:(UIView *)cell
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)getImageFromImage:(UIImage *)mars {

    CGSize sz = [mars size];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz.width - 30, sz.height - 12), NO, 0);

    [mars drawAtPoint:CGPointMake(-15, 0)];

    UIImage* im = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return im;
}

/** 删除所有子视图*/
- (void)removeAllSubViewsAtView:(UIView *)view
{
    while (view.subviews.count) {
       [[view.subviews lastObject] removeFromSuperview];
    }
}

#pragma mark -- 显示、隐藏cell上的内容
/**
 * 显示self.swipeImageView
 */
- (void)showSwipeOverlayViewIfNeed
{
    if(self.isShowSwipeOverlayView) return;
    self.isShowSwipeOverlayView = YES;
    
    // 去除cell的选中状态，并保存
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 显示swipeOverlayView,并将移动后cell上的内容裁剪到swipeImageView上
    UIImage *image = [self fecthTranslatedCellInfo:self];
    self.swipeImageView.image = [self getImageFromImage:image];
    self.swipeImageView.layer.cornerRadius = 10;
    self.swipeImageView.layer.masksToBounds = YES;
    self.swipeOverlayView.hidden = NO;
    self.editView.hidden = NO;
    self.swipeImageView.userInteractionEnabled = YES;
    
    // 隐藏cell上的内容
    [self hiddenAccesoryViewAndContentOfCellIfNeed:YES];
    // 添加点击手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapGesture.delegate = self;
    [self.swipeImageView addGestureRecognizer:self.tapGesture];
}

/**
 * 隐藏self.swipeImageView
 */
- (void)hiddenSwipeOverlayViewIfNeed
{
    if(!self.isShowSwipeOverlayView) return;
    self.isShowSwipeOverlayView = NO;
    
    // 隐藏swipeImageView
    self.swipeOverlayView.hidden = YES;
    self.editView.hidden = YES;
    self.swipeImageView.image = nil;
    self.swipeImageView.userInteractionEnabled = NO;
    
    // 将cell上的内容还原
    [self hiddenAccesoryViewAndContentOfCellIfNeed:NO];
    // 移除点击手势
    if(self.tapGesture){
        [self.swipeImageView removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
    }
}

/**
 *  是否隐藏accesoryView和cell上的内容,从而使得滑动cell时不会看见原有cell上的内容
 */
- (void)hiddenAccesoryViewAndContentOfCellIfNeed:(BOOL)hidden
{
    // 若只设置self.accessoryType 则不走这个判断语句
    if(self.accessoryView){
        self.accessoryView.hidden = hidden;
    }
    
    // 设置了self.accessoryType 其实是个UIButton
    for(UIView *subView in self.contentView.superview.subviews)
    {
        if(subView != self.contentView && ([subView isKindOfClass:[UIButton class]] || [NSStringFromClass(subView.class) rangeOfString:@"Disclosure"].location != NSNotFound))
        {
            subView.hidden = hidden;
        }
    }
    
    for(UIView *subView in self.contentView.superview.subviews)
    {
        if (subView == self.contentView) continue;
        // 若是cell上的subView则隐藏
        if(hidden && !subView.hidden)
        {
            subView.hidden = YES;
            [self.perviusHiddenViewSet addObject:subView];
        }
        // 还原cell时，将隐藏的cell上的内容显示出来
        else if(!hidden && [self.perviusHiddenViewSet containsObject:subView])
        {
            subView.hidden = NO;
        }
    }
    if(!hidden){
        [self.perviusHiddenViewSet removeAllObjects];
    }
}

#pragma mark -- getter或setter

//重写tableView的getter方法 获取cell所在的tableView
- (UITableView *)tableView
{
    if(_tableView){
        return _tableView;
    }
    // 获取当前cell所在的父tableView
    UIView *view = self.superview;
    while (view != nil)
    {
        if([view isKindOfClass:[UITableView class]])
        {
            _tableView = (UITableView *)view;
        }
        view = view.superview;
    }
    return _tableView;
}

// 重写swipeOffset的setter方法 监测滑动手势
- (void)setSwipeOffset:(CGFloat)swipeOffset
{
    CGFloat sign = swipeOffset > 0 ? 1 : -1;
    FHMessageSwipeView *currentSwipeView = swipeOffset < 0 ? self.rightSwipeView : self.leftSwipeView;
    
    _swipeOffset = swipeOffset;
    CGFloat offset = fabs(_swipeOffset);
    
    if(!currentSwipeView || offset == 0)
    {
        [self hiddenSwipeOverlayViewIfNeed];
        self.targetOffset = 0.0;
        return;
    }
    else
    {
        [self showSwipeOverlayViewIfNeed];
        self.targetOffset = offset > currentSwipeView.bounds.size.width*self.swipeThreshold ? currentSwipeView.bounds.size.width*sign : 0;
    }
    // 平移swipeImageView，显示滑动后cell的内容
    if (swipeOffset < -88) {
        _swipeOffset = -88;
    }
    self.swipeImageView.transform = CGAffineTransformMakeTranslation(self.swipeOffset, 0);
    
    FHMessageSwipeView *viewArray[2] = {self.rightSwipeView, self.leftSwipeView};
    for (int i = 0; i< 2; i++)
    {
        FHMessageSwipeView *swipeView = viewArray[i];
        if(!swipeView) continue;
        
        BOOL expand = self.isAllowExpand && offset > currentSwipeView.frame.size.width * self.expandThreshold;
        // 拉伸
        if (expand)
        {
            self.targetOffset = currentSwipeView.frame.size.width * sign;
            
        }
        else
        {
            // 平移显示按钮
            CGFloat translation = MIN(offset, currentSwipeView.bounds.size.width)*sign;
            swipeView.transform = CGAffineTransformMakeTranslation(translation, 0);
            if(currentSwipeView != swipeView) continue;
            
            [self getSwipeViewTransformMode];
            currentSwipeView.mode = self.transformMode;
            CGFloat t = MIN(1.0f, offset/currentSwipeView.bounds.size.width);
            // swipeView的弹出、隐藏动画效果
            [currentSwipeView swipeViewAnimationFromRight:self.swipeOffset<0 ? YES : NO effect:t cellHeight:CELL_HEIGHT];
        }
    }
}

#pragma mark -- expand

- (void)expandToOffset:(CGFloat)offset
{
    
}

- (void)openCompleted {
    
}


#pragma mark -- 懒加载

- (NSArray<FHMessageSwipeButton *> *)rightSwipeButtons
{
    if(!_rightSwipeButtons)
    {
        _rightSwipeButtons = [NSArray array];
    }
    return _rightSwipeButtons;
}

- (NSMutableSet *)perviusHiddenViewSet
{
    if(!_perviusHiddenViewSet)
    {
        _perviusHiddenViewSet = [NSMutableSet set];
    }
    return _perviusHiddenViewSet;
}

@end
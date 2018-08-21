//
//  ExploreWidgetView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

#import "ExploreWidgetView.h"
#import "ExploreWidgetItemView.h"
#import "ExploreWidgetEmptyView.h"
#import "ExploreWidgetFetchListManager.h"
#import "TTBaseMacro.h"
#import "TTWidgetTool.h"

#define kOpenHostAppButtonTopPadding (([TTWidgetTool OSVersionNumber] >= 10.0) ? 13.0 : 17.0)
#define kOpenHostAppButtonBottomPadding (([TTWidgetTool OSVersionNumber] >= 10.0) ? 13.0 : 2.0)
#define kOPenHostAppButtonHeight 30

#define kLeftPadding (([TTWidgetTool OSVersionNumber] >= 10.0) ? 0.0 : 47.0)

#define kItemViewTag 111

@interface ExploreWidgetView()<ExploreWidgetItemViewDelegate>

@property(nonatomic, retain)UIButton * openHostAppButton;
@property(nonatomic, retain)NSMutableSet * reusePool;
@property(nonatomic, retain)ExploreWidgetEmptyView * emptyView;

@end

@implementation ExploreWidgetView

- (void)dealloc
{
    self.deleagte = nil;
    for (UIView *  view in self.subviews) {
        if ([view isKindOfClass:[ExploreWidgetItemView class]]) {
            ((ExploreWidgetItemView *)view).delegate = nil;
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reusePool = [NSMutableSet setWithCapacity:10];
        self.openHostAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _openHostAppButton.layer.cornerRadius = 5.f;
        [_openHostAppButton setTitle:@"查看更多" forState:UIControlStateNormal];
        if ([TTWidgetTool OSVersionNumber] >= 10.0) {
            [_openHostAppButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
            [_openHostAppButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_openHostAppButton setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f] forState:UIControlStateSelected];
            [_openHostAppButton setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f] forState:UIControlStateHighlighted];
            [_openHostAppButton setBackgroundColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.3f]];
        }
        else {
            [_openHostAppButton setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f] forState:UIControlStateNormal];
            [_openHostAppButton setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.25f] forState:UIControlStateSelected];
            [_openHostAppButton setTitleColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.25f] forState:UIControlStateHighlighted];
            [_openHostAppButton setBackgroundColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.5f]];
        }
        
        [_openHostAppButton addTarget:self action:@selector(openHostAppButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _openHostAppButton.frame = CGRectMake(0, 0, 223, kOPenHostAppButtonHeight);
        [self addSubview:_openHostAppButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _openHostAppButton.frame = CGRectMake([self ViewCenterAlignLeftPaddingForWidth:223], _openHostAppButton.frame.origin.y, _openHostAppButton.frame.size.width, _openHostAppButton.frame.size.height);
}

- (CGFloat)ViewCenterAlignLeftPaddingForWidth:(CGFloat)width
{
    CGFloat result = (self.frame.size.width + kLeftPadding - width) / 2 - kLeftPadding;
    return result;
}

- (void)openHostAppButtonClicked
{
    NSString * schema = [TTWidgetTool ssAppScheme];
    if (!isEmptyString(schema)) {
        NSString * str = [NSString stringWithFormat:@"%@open?from=today_extenstion_more", schema];
        [self openCustomURLStr:str];
    }
}

- (void)openCustomURLStr:(NSString *)str
{
    if (str && _deleagte && [_deleagte respondsToSelector:@selector(widgetView:openURL:)]) {
        [_deleagte widgetView:self openURL:str];
    }
}

- (void)actionButtonClicked
{
    if (_emptyView.emptyType == ExploreWidgetEmptyViewTypeError) {
        if (_deleagte && [_deleagte respondsToSelector:@selector(widgetViewClickErrorEmptyButtn:)]) {
            [_deleagte widgetViewClickErrorEmptyButtn:self];
        }
    }
}

- (void)showOpenHostAppButton:(BOOL)show {
    self.openHostAppButton.hidden = !show;
}

- (void)refreshEmptyView:(ExploreWidgetEmptyViewType)type
{
    CGFloat originY = 0;
    if (!_emptyView) {
        self.emptyView = [[ExploreWidgetEmptyView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), [ExploreWidgetEmptyView heightForView])];
        [_emptyView.actionButton addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    [_emptyView refreshType:type];
    [self addSubview:_emptyView];
    originY = [ExploreWidgetEmptyView heightForView];
    [self refreshOpenHostAppButtonOriginY:originY];
}

- (void)refreshOpenHostAppButtonOriginY:(CGFloat)originY
{
    CGRect buttonFrame = _openHostAppButton.frame;
    buttonFrame.origin.y = originY + kOpenHostAppButtonTopPadding;
    _openHostAppButton.frame = buttonFrame;

}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)refreshWithModels:(NSArray *)models widgetDisplayMode:(NCWidgetDisplayMode)mode maxCellCount:(NSInteger)maxCellCount
#pragma clang diagnostic pop
{
    [self removeAllItemViews];
    
    CGFloat originY = 0;
    [_emptyView removeFromSuperview];
    self.emptyView = nil;
    
    switch (mode) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        case NCWidgetDisplayModeExpanded:
#pragma clang diagnostic pop
        {
            CGFloat cellToShow = 0;
            for (ExploreWidgetItemModel * model in models) {
                ExploreWidgetItemView * view = [self dequeItemView];
                CGFloat height = [ExploreWidgetItemView heightForModel:model];
                view.frame = CGRectMake(0, originY, CGRectGetWidth(self.frame), height);
                [view refreshWithModel:model widgetDisplayMode:mode];
                originY += height;
                cellToShow++;
                if (cellToShow >= maxCellCount) {
                    break;
                }
            }
        }
            break;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        case NCWidgetDisplayModeCompact:
#pragma clang diagnostic pop
        {
            ExploreWidgetItemModel *model = nil;
            if ([models count] > 0) {
                model = [models firstObject];
            }
            ExploreWidgetItemView * view = [self dequeItemView];
            CGFloat height = [ExploreWidgetItemView heightForModel:model];
            originY = (CGRectGetHeight(self.frame) - height)/2.0; //缩起模式下居中展示
            view.frame = CGRectMake(0, originY, CGRectGetWidth(self.frame), height);
            [view refreshWithModel:model widgetDisplayMode:mode];
            originY += height;
        }
            break;
    }
    
    [self refreshOpenHostAppButtonOriginY:originY];
}

- (void)removeAllItemViews
{
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[ExploreWidgetItemView class]]) {
            [self reuseItemView:(ExploreWidgetItemView *)view];
        }
    }
}

+ (CGFloat)heightForOpenHostButtonSection
{
    return kOpenHostAppButtonTopPadding + kOpenHostAppButtonBottomPadding + kOPenHostAppButtonHeight;
}

+ (CGFloat)heightForEmptyView
{
    return [ExploreWidgetEmptyView heightForView];
}

+ (CGFloat)preferredInitHeight
{
    return [self heightForOpenHostButtonSection] + [ExploreWidgetItemView preferredInitHeight] * kExploreWidgetMaxItemCount;
}

+ (CGFloat)heightForModels:(NSArray *)array
{
    if ([array count] == 0) {
        return [self heightForEmptyView] + [self heightForOpenHostButtonSection];
    }
    else {
        
        CGFloat height = [self heightForOpenHostButtonSection];
        
        for (ExploreWidgetItemModel * model in array) {
            height += [ExploreWidgetItemView heightForModel:model];
        }
        return height;
    }
}

+ (NSInteger)maxModelCountForHeightLimit:(CGFloat)heightLimit models:(NSArray *)models fixedHeight:(CGFloat *)fixedHeight {
    if ([models count] == 0) {
        return -1;
    }
    else {
        CGFloat height = [self heightForOpenHostButtonSection];
        NSUInteger modelsCount = [models count];
        for (NSInteger i = 0; i < modelsCount; i++) {
            ExploreWidgetItemModel * model = [models objectAtIndex:i];
            CGFloat heightForModel = [ExploreWidgetItemView heightForModel:model];
            if (height + heightForModel > heightLimit) {
                *fixedHeight = height;
                return i;
            }
            height += heightForModel;
        }
        return modelsCount;
    }
}

#pragma mark --

- (ExploreWidgetItemView *)dequeItemView
{
    ExploreWidgetItemView * view = [_reusePool anyObject];
    if (!view) {
        view = [[ExploreWidgetItemView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0)];
        view.delegate = self;
        view.tag = kItemViewTag;
    }
    [self addSubview:view];
    [_reusePool removeObject:view];
    return view;
    
}

- (void)reuseItemView:(ExploreWidgetItemView *)itemView
{
    [_reusePool addObject:itemView];
    [itemView removeFromSuperview];
}

#pragma mark -- ExploreWidgetItemViewDelegate

- (void)itemView:(ExploreWidgetItemView *)itemView urlStr:(NSString *)url
{
    if (!isEmptyString(url)) {
        [self openCustomURLStr:url];
    }
}


@end

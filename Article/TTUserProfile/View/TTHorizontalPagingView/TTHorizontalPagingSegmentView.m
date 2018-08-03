//
//  TTHorizontalPagingSegmentView.m
//  Article
//
//  Created by 王迪 on 2017/3/15.
//
//

#import "TTHorizontalPagingSegmentView.h"
#import "SSThemed.h"

@interface TTHorizontalPagingSegmentView()

@property (nonatomic, strong) SSThemedScrollView *titleScrollView;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, assign) BOOL isShowUnderLine;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) SSThemedView *underLine;
@property (nonatomic, strong) UIColor *underLineColor;
@property (nonatomic, assign) CGFloat underLineH;
@property (nonatomic, assign) BOOL isDelayScroll;
@property (nonatomic, assign) BOOL isUnderLineEqualTitleWidth;  

@property (nonatomic, copy) NSString *selColorKey;
@property (nonatomic, copy) NSString *normalColorKey;
@property (nonatomic, copy) NSString *titleScrollViewColorKey;
@property (nonatomic, copy) NSString *underLineColorKey;
@property (nonatomic, assign) CGFloat lastOffsetX;
@property (nonatomic, assign) NSInteger lastSelectedIndex;
@property (nonatomic, assign) BOOL isTitleClick;

@end

@implementation TTHorizontalPagingSegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - 懒加载
- (SSThemedScrollView *)titleScrollView
{
    if(!_titleScrollView) {
        _titleScrollView = [[SSThemedScrollView alloc] init];
        _titleScrollView.showsVerticalScrollIndicator = NO;
        _titleScrollView.showsHorizontalScrollIndicator = NO;
        _titleScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleScrollView.scrollsToTop = NO;
    }
    return _titleScrollView;
}

- (SSThemedView *)bottomLine
{
    if(!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] init];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        
    }
    return _bottomLine;
}

- (SSThemedView *)underLine
{
    if(!_underLine) {
        _underLine = [[SSThemedView alloc] init];
        [self.titleScrollView addSubview:_underLine];
        _underLine.backgroundColorThemeKey = self.underLineColorKey;
    }
    return _isShowUnderLine ? _underLine : nil;
}

- (NSMutableArray *)titleLabels
{
    if(!_titleLabels) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (void)setupSubview
{
    [self addSubview:self.titleScrollView];
    [self addSubview:self.bottomLine];
}

- (void)setUpTitleEffect:(void(^)(NSString *__autoreleasing *titleScrollViewColorKey,NSString *__autoreleasing *norColorKey,NSString *__autoreleasing *selColorKey,UIFont *__autoreleasing *titleFont))titleEffectBlock;
{
    NSString *titleScrollViewColorKey = nil;
    NSString *norColorKey = nil;
    NSString *selColorKey = nil;
    UIFont *titleFont = nil;
    if(titleEffectBlock) {
        titleEffectBlock(&titleScrollViewColorKey,&norColorKey,&selColorKey,&titleFont);
        if(norColorKey) {
            self.normalColorKey = norColorKey;
        }
        if(selColorKey) {
            self.selColorKey = selColorKey;
        }
        if(titleScrollViewColorKey) {
            _titleScrollViewColorKey = titleScrollViewColorKey;
            _titleScrollView.backgroundColorThemeKey = _titleScrollViewColorKey;
        }
        _titleFont = titleFont;
    }
}

- (void)setUpUnderLineEffect:(void(^)(BOOL *isUnderLineDelayScroll,CGFloat *underLineH,NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth))underLineBlock
{
    _isShowUnderLine = YES;
    NSString *underLineColorKey = nil;
    if (underLineBlock) {
        underLineBlock(&_isDelayScroll,&_underLineH,&underLineColorKey,&_isUnderLineEqualTitleWidth);
        _underLineColorKey = underLineColorKey;
    }
    
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    _titles = titles;
    [self.titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    [self setupAllTitles];
    
}

- (void)setType:(TTPagingSegmentViewHorizontalAlignment)type
{
    _type = type;
    [self setTitles:self.titles];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    if(selectedIndex < 0 || selectedIndex >= self.titleLabels.count) return;
    UILabel *selectedLabel = self.titleLabels[selectedIndex];
    [self titleClick:selectedLabel.gestureRecognizers.firstObject];
    self.lastOffsetX = selectedIndex;
}

- (void)setupAllTitles
{
    for(NSString *title in self.titles) {
        SSThemedLabel *label = [[SSThemedLabel alloc] init];
        label.textColorThemeKey = self.normalColorKey;
        label.font = self.titleFont;
        label.userInteractionEnabled = YES;
        label.textAlignment = NSTextAlignmentCenter;
        [self.titleScrollView addSubview:label];
        label.text = title;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        [self.titleLabels addObject:label];
    }
    
    [self setNeedsLayout];
}

- (void)setupLabelSelected:(SSThemedLabel *)selectedLabel
{
    for(SSThemedLabel *label in self.titleLabels) {
        if(selectedLabel == label) continue;
        label.textColorThemeKey = self.normalColorKey;
    }
    selectedLabel.textColorThemeKey = self.selColorKey;
    _selectedIndex = selectedLabel.tag;
    [self setupLabelTitleCenter:selectedLabel];
    if (self.isShowUnderLine) {
        [self setupUnderLine:selectedLabel];
    }
}

- (void)setupLabelTitleCenter:(SSThemedLabel *)selectedLabel
{
    // 设置标题滚动区域的偏移量
    CGFloat offsetX = selectedLabel.center.x - self.width * 0.5;
    if (offsetX < 0) {
        offsetX = 0;
    }
    // 计算下最大的标题视图滚动区域
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - self.width;
    
    if (maxOffsetX < 0) {
        maxOffsetX = 0;
    }
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    // 滚动区域
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)setupUnderLine:(SSThemedLabel *)selectedLabel
{
    // 获取文字尺寸
    CGRect titleBounds = [selectedLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    CGFloat underLineH = self.underLineH > 0 ? self.underLineH : 2;
    self.underLine.top = selectedLabel.height - underLineH;
    self.underLine.height = underLineH;
    // 最开始不需要动画
    if (self.underLine.left == 0) {
        if (_isUnderLineEqualTitleWidth) {
            self.underLine.width = titleBounds.size.width;
        } else {
            self.underLine.width = selectedLabel.width;
        }
        self.underLine.centerX = selectedLabel.centerX;
        return;
    }
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        if (_isUnderLineEqualTitleWidth) {
            self.underLine.width = titleBounds.size.width;
        } else {
            self.underLine.width = selectedLabel.width;
        }
        self.underLine.centerX = selectedLabel.centerX;
    }];
}

- (void)setUpUnderLineOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.left - leftLabel.left;
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    // 获取移动距离
    CGFloat offsetDelta = offsetX - self.lastOffsetX;
    // 计算当前下划线偏移量
    CGFloat underLineTransformX = offsetDelta * centerDelta / self.width;
    // 宽度递增偏移量
    CGFloat underLineWidth = offsetDelta * widthDelta / self.width;
    self.underLine.width += underLineWidth;
    self.underLine.left += underLineTransformX;
    
}

// 获取两个标题按钮宽度差值
- (CGFloat)widthDeltaWithRightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    CGRect titleBoundsR = [rightLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    CGRect titleBoundsL = [leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    return titleBoundsR.size.width - titleBoundsL.size.width;
}

- (void)titleClick:(UITapGestureRecognizer *)tap
{
    self.isTitleClick = YES;
    SSThemedLabel *label = (SSThemedLabel *)tap.view;
    [self setupLabelSelected:label];
    CGFloat offsetX = label.tag * self.width;
    self.lastOffsetX = offsetX;
    if([self.delegate respondsToSelector:@selector(segmentView:didSelectedItemAtIndex:toIndex:)]) {
        [self.delegate segmentView:self didSelectedItemAtIndex:self.lastSelectedIndex toIndex:label.tag];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isTitleClick = NO;
    });
}

- (void)scrollToOffsetX:(CGFloat)offsetX
{
    if(_isTitleClick || self.titleLabels.count == 0) return;
    // 获取左边角标
    NSInteger leftIndex = offsetX / self.width;
    if(leftIndex < 0 || leftIndex >= self.titleLabels.count) return;
    // 左边按钮
    SSThemedLabel *leftLabel = self.titleLabels[leftIndex];
    // 右边角标
    NSInteger rightIndex = leftIndex + 1;
    // 右边按钮
    SSThemedLabel *rightLabel = nil;
    
    if (rightIndex < self.titleLabels.count) {
        rightLabel = self.titleLabels[rightIndex];
    }
    // 设置下标偏移
    if (!self.isDelayScroll) { // 延迟滚动，不需要移动下标
        
        [self setUpUnderLineOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    }
    // 记录上一次的偏移量
    self.lastOffsetX = offsetX;

}

- (void)scrollToIndex:(NSInteger)toIndex
{
    if(toIndex < 0 || toIndex >= self.titleLabels.count) return;
    [self setupLabelSelected:self.titleLabels[toIndex]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleScrollView.frame = self.bounds;
    CGFloat labelW = 0;
    CGFloat labelH = self.frame.size.height;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    NSInteger count = self.titleLabels.count;
    SSThemedLabel *lastLabel = nil;
    for(int i = 0; i < count;i++) {
        SSThemedLabel *label = self.titleLabels[i];
        label.tag = i;
        if(self.type == TTPagingSegmentViewContentHorizontalAlignmentLeft) {
            CGSize textSize = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil].size;
            labelW = textSize.width + [TTDeviceUIUtils tt_newPadding:30];
        } else {
            labelW = self.width / count;
        }
        labelX = CGRectGetMaxX(lastLabel.frame);
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        if(i == self.selectedIndex) {
            [self titleClick:label.gestureRecognizers.firstObject];
            self.lastSelectedIndex = self.selectedIndex;
        }
        lastLabel = label;
    }
    self.titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame), 0);
    self.bottomLine.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
}

#pragma ThemeChange & surfaceChange

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    if (self.titleLabels.count > self.selectedIndex){
        SSThemedLabel *selectedLabel = self.titleLabels[self.selectedIndex];
        selectedLabel.textColorThemeKey = _selColorKey;
        _underLine.backgroundColorThemeKey = self.underLineColorKey;
    }
}


@end

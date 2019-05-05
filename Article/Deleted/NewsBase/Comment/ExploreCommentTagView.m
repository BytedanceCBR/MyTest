//
//  ExploreCommentTagView.m
//  Article
//
//  Created by 冯靖君 on 15/7/28.
//
//

#import "ExploreCommentTagView.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"

#define TagItemMaxCount 3
#define LeftMargin  5
#define TopMargin   5

@implementation ExploreCommentTagView
{
    UIView *containerView;
    NSMutableArray *buttons;
    NSInteger seletedIndex;
}

- (instancetype)initWithFrame:(CGRect)frame tagItems:(NSArray *)tags
{
    self = [super initWithFrame:frame];
    if (self) {
        _tagItems = tags;
        buttons = [NSMutableArray arrayWithCapacity:MIN(TagItemMaxCount, _tagItems.count)];
        [self buildViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame tagItems:nil];
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    return [self initWithFrame:CGRectZero tagItems:nil];
}

- (void)buildViews
{
    containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    containerView.layer.cornerRadius = self.height/2;
    
    for (int idx = 0; idx < MIN(TagItemMaxCount, _tagItems.count); idx++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = [self frameOfButtonAtIndex:idx];
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:_tagItems[idx] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceHelper isPadDevice] ? 12.f : self.height/2];
        [button addTarget:self action:@selector(tagButton:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
        [containerView addSubview:button];
        
        if (idx != MIN(TagItemMaxCount, _tagItems.count) - 1) {
            UIView *verticalLine = [[UIView alloc] init];
            verticalLine.frame = CGRectMake(button.right, (self.height - 10)/2, [TTDeviceHelper ssOnePixel], [TTDeviceHelper isPadDevice] ? 12.f : 10.f);
            [containerView addSubview:verticalLine];
        }
    }
    [self highlightSelectedButtonAtIndex:0];    //默认
    
    [self addSubview:containerView];
    self.backgroundColor = [UIColor clearColor];
    [self reloadThemeUI];
}

- (void)themeChanged:(NSNotification *)notification
{
    containerView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
    for (UIView * line in containerView.subviews) {
        if (![line isKindOfClass:[UIButton class]]) {
            line.backgroundColor = SSGetThemedColorWithKey(kColorLine1);
        }
    }
    [self highlightSelectedButtonAtIndex:seletedIndex];
}

- (CGRect)frameOfButtonAtIndex:(NSInteger)index
{
    CGFloat singleWidth = ceilf((self.width - 2 * LeftMargin) / MIN(TagItemMaxCount, _tagItems.count));
    return CGRectMake(LeftMargin + singleWidth*index, 0, singleWidth, self.height);
}

- (void)tagButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = [buttons indexOfObject:button];
    [self highlightSelectedButtonAtIndex:index];
    if (_delegate && [_delegate respondsToSelector:@selector(exploreCommentTagView:didSelectTagViewAtIndex:)]) {
        [_delegate exploreCommentTagView:self didSelectTagViewAtIndex:index];
    }
}

- (void)highlightSelectedButtonAtIndex:(NSInteger)index
{
    seletedIndex = index;
    [buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        if (idx == index) {
            [button setTitleColor:SSGetThemedColorWithKey(kColorText3) forState:UIControlStateNormal];
        }
        else {
            [button setTitleColor:SSGetThemedColorWithKey(kColorTextSelectedColor3) forState:UIControlStateNormal];
        }
    }];
}

@end

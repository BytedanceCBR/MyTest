//
//  TTVLabelSegmentedControl.m
//  Article
//
//  Created by pei yun on 2017/3/23.
//
//

#import "TTVLabelSegmentedControl.h"
#import "UIColor+TTThemeExtension.h"

@interface TTVLabelSegmentedControl (Private) <TTVLabelTabbarDelegate>

@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, strong) UIView *indicator;
@property (nonatomic, strong) NSArray *tabs;

@end

@implementation TTVLabelSegmentedControl

@synthesize segmentedControlDelegate;

+ (instancetype)segmentedControlWithTitles:(NSArray *)titles
{
    NSArray *tabs = [self tabsWithTitles:titles];
    TTVLabelSegmentedControl *tabbar = [[TTVLabelSegmentedControl alloc] initWithTabs:tabs];
    tabbar.titles = titles;
    [tabbar layoutTabs];
    return tabbar;
}


- (instancetype)initWithTabs:(NSArray *)tabs
{
    if (self = [super initWithTabs:tabs]) {
        self.delegateCustom = self;
        self.animateDuration = .2f;
    }
    return self;
}

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self setTabs:[TTVLabelSegmentedControl tabsWithTitles:titles]];
}

+ (NSArray *)tabsWithTitles:(NSArray *)titles
{
    NSMutableArray *tabs = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithHexString:@"0xaaaaaa"];
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label.width += 1.5;   // 消除文字加粗厚展示不全
        [tabs addObject:label];
    }];
    return tabs;
}

- (instancetype)init
{
    [NSException raise:NSInvalidArgumentException format:@"call `initWithTabs:` instead"];
    return nil;
}

// forward method from TTVLabelTabbarDelegate to TTVSegmentedControlDelegate
- (void)tabbar:(TTVLabelTabbar *)tabbar didSelectedIndex:(NSInteger)index
{
    if ([self.segmentedControlDelegate conformsToProtocol:@protocol(TTVSegmentedControlDelegate)] &&
        [self.segmentedControlDelegate respondsToSelector:@selector(segmentedControllDidBeginSnapingToIndex:withDuration:)]) {
        [self.segmentedControlDelegate segmentedControllDidBeginSnapingToIndex:index withDuration:self.animateDuration];
    }
}

#pragma mark -- TTVSegmentedControl Protocol

- (void)moveToNormalizedOffset:(CGFloat)offset
{
    [self setTabNormalizedOffset:offset];
}

- (void)moveToIndex:(NSUInteger)index
{
    [self setSelectedIndex:index];
}

@end

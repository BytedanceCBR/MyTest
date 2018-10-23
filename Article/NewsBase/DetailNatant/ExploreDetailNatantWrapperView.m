//
//  ExploreDetailNatantWrapperView.m
//  Article
//
//  Created by 冯靖君 on 15/8/6.
//
//

#import "ExploreDetailNatantWrapperView.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"

@interface ExploreDetailNatantWrapperView ()

@property(nonatomic, strong) NSMutableArray<UIView *> *items;

@end

@implementation ExploreDetailNatantWrapperView

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self reloadThemeUI];
        _items = [NSMutableArray array];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)didAddSubview:(UIView *)subview
{
    if (subview) {
        [_items addObject:subview];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    self.layer.borderColor = [SSGetThemedColorWithKey(kColorLine10) CGColor];
    if (_isWenda) {
        self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    }
    else {
        self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    }
}

- (void)sendShowTrackIfNeededForGroup:(NSString *)groupID withLabel:(NSString *)label{
    if (!self.hasShown) {
        [TTLogManager logEvent:@"show_related" context:nil screenName:kDetailScreen];
    }
    [super sendShowTrackIfNeededForGroup:groupID withLabel:label];
}


- (void)setIsWenda:(BOOL)isWenda
{
    _isWenda = isWenda;
    [self reloadThemeUI];
}

#pragma mark - public

- (CGFloat)heightOfItemInWrapper
{
    //至少包含header和一个相关条目
    if (_items.count < 2) {
        return 0;
    }
    return [_items objectAtIndex:1].bounds.size.height;
}

- (UIView *)itemInWrapperAtIndex:(NSInteger)index
{
    return index < _items.count ? _items[index] : nil;
}

@end

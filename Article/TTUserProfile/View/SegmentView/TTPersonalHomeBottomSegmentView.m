//
//  TTPersonalHomeBottomSegmentView.m
//  Article
//
//  Created by wangdi on 2017/3/27.
//
//

#import "TTPersonalHomeBottomSegmentView.h"

@interface TTPersonalHomeBottomSegmentView ()

@property (nonatomic, weak) SSThemedView *topLine;
@property (nonatomic, strong) NSMutableArray *titlesBtnArray;

@end

@implementation TTPersonalHomeBottomSegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self setupSubview];
        self.backgroundColorThemeKey = kColorBackground4;
    }
    return self;
}

- (void)setupSubview
{
    SSThemedView *topLine = [[SSThemedView alloc] init];
    topLine.backgroundColorThemeKey = kColorLine1;
    [self addSubview:topLine];
    self.topLine = topLine;
}

- (NSMutableArray *)titlesBtnArray
{
    if(!_titlesBtnArray) {

        _titlesBtnArray = [NSMutableArray array];
    }
    return _titlesBtnArray;
}

- (void)setItems:(NSArray<TTPersonalHomeUserInfoDataBottomItemResponseModel *> *)items
{
    _items = items;
    if(items.count == 0) return;
    [self.titlesBtnArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titlesBtnArray removeAllObjects];
    for(int i = 0;i < items.count;i++) {
        TTPersonalHomeUserInfoDataBottomItemResponseModel *item = items[i];
        SSThemedButton *btn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        btn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15]];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        btn.titleColorThemeKey = kColorText1;
        [btn setTitle:item.name forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.titlesBtnArray addObject:btn];
        if(item.children.count > 0) {
            btn.imageName = @"tabbar_options";
        } else {
            btn.imageName = nil;
        }
    }
    
    [self setNeedsLayout];
}

- (void)btnClick:(SSThemedButton *)btn
{
    TTPersonalHomeUserInfoDataBottomItemResponseModel *item = self.items[btn.tag];
    if([self.delegate respondsToSelector:@selector(bottomSegmentView:didSelectedItem: didSelectedPoint: didSelectedIndex:)]) {
        [self.delegate bottomSegmentView:self didSelectedItem:item didSelectedPoint:btn.center didSelectedIndex:btn.tag];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat bottomInset = self.tt_safeAreaInsets.bottom;
    self.topLine.left = 0;
    self.topLine.top = 0;
    self.topLine.width = self.width;
    self.topLine.height = [TTDeviceHelper ssOnePixel];
    
    CGFloat btnW = self.width / self.titlesBtnArray.count;
    for(int i = 0;i < self.titlesBtnArray.count;i++) {
        SSThemedButton *btn = self.titlesBtnArray[i];
        btn.width = btnW;
        btn.left = i * btnW;
        btn.top = 0;
        btn.height = self.height - bottomInset;
        if(self.titlesBtnArray.count > 1 && i != self.titlesBtnArray.count - 1) {
            SSThemedView *line = [[SSThemedView alloc] init];
            line.backgroundColorThemeKey = kColorLine1;
            line.width = [TTDeviceHelper ssOnePixel];
            line.left = btn.width - line.width;
            line.top = 10;
            line.height = btn.height - 2 * line.top;
            [btn addSubview:line];
        }
    }
}
@end

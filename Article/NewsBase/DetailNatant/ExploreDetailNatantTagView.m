//
//  ExploreDetailNatantTagView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//

#import "ExploreDetailNatantTagView.h"
#import "ExploreSearchViewController.h"
#import "NewsDetailLogicManager.h"
#import "TTDeviceHelper.h"

#define kBottomPadding 13

#define kButtonLeftPadding ([TTDeviceHelper isPadDevice] ? 4 : 12)
#define kBottomLineLeftPadding 15
#define kBottomLineRightPadding 15
#define kButtonRightPadding 12
#define kButtonBottomPadding 15

#define kItemButtonFontSize ([TTDeviceHelper isPadDevice] ?18 : 14)

#define kButtonHeight 22
#define kButtonMinWidth 50
#define kNoKeywordHeight 1



@interface ExploreDetailKeyworkModel : NSObject

@property(nonatomic, retain)NSString * name;
@property(nonatomic, retain)NSString * label;
@property(nonatomic, assign)NSUInteger modelIndex;

@end

@implementation ExploreDetailKeyworkModel


@end

@interface ExploreDetailNatantTagView()

@property(nonatomic, retain)NSArray * keywordModels;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ExploreDetailKeyworkItemView : SSViewBase

@property(nonatomic, retain)ExploreDetailKeyworkModel * model;
@property(nonatomic, retain)UIButton * button;


@end

@implementation ExploreDetailKeyworkItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:kItemButtonFontSize]];
        if ([TTDeviceHelper isPadDevice]) {
            _button.backgroundColor = [UIColor clearColor];
        }
        else {
            _button.layer.cornerRadius = kButtonHeight / 2;
            _button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            [_button addTarget:self action:@selector(highlightBorder) forControlEvents:UIControlEventTouchDown];
            [_button addTarget:self action:@selector(unhighlightBorder) forControlEvents:UIControlEventTouchUpInside];
            [_button addTarget:self action:@selector(unhighlightBorder) forControlEvents:UIControlEventTouchUpOutside];
            [_button addTarget:self action:@selector(unhighlightBorder) forControlEvents:UIControlEventTouchCancel];
        }
        [self addSubview:_button];
        
        [self reloadThemeUI];
    }
    return self;
}

-(void)highlightBorder
{
    _button.layer.borderColor = [UIColor colorWithDayColorName:@"2a90d7" nightColorName:@"67778b"].CGColor;
}

- (void)unhighlightBorder
{
    _button.layer.borderColor = [UIColor colorWithDayColorName:@"cacaca" nightColorName:@"363636"].CGColor;
}

- (void)themeChanged:(NSNotification *)notification
{
    if ([TTDeviceHelper isPadDevice]) {
        [_button setTitleColor:[UIColor colorWithDayColorName:@"3c6598" nightColorName:@"3c6598"] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor colorWithDayColorName:@"233f66" nightColorName:@"233f66"] forState:UIControlStateHighlighted];
        [_button setTitleColor:[UIColor colorWithDayColorName:@"233f66" nightColorName:@"233f66"] forState:UIControlStateHighlighted];
    }
    else {
        _button.backgroundColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
        [_button setTitleColor:[UIColor colorWithDayColorName:@"2a90d7" nightColorName:@"67778b"] forState:UIControlStateNormal];
        _button.layer.borderColor = [UIColor colorWithDayColorName:@"cacaca" nightColorName:@"363636"].CGColor;
    }
}

- (void)refreshModel:(ExploreDetailKeyworkModel *)model
{
    self.model = model;
    NSString * str = nil;
    if (!isEmptyString(model.name)) {
        str = [NSString stringWithFormat:@"  %@  ", model.name];
    }
    [_button setTitle:str forState:UIControlStateNormal];
    [_button sizeToFit];
    float buttonWidth = MAX(kButtonMinWidth, _button.width);
    buttonWidth = MIN(320 - kButtonLeftPadding - kButtonRightPadding, buttonWidth); //最大不超过手机的一屏
    _button.frame = CGRectMake(0, 0, buttonWidth, kButtonHeight);
    self.frame = _button.bounds;
}



@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ExploreDetailNatantTagView()
@property(nonatomic, retain)UIView * bottomLineView;
@property(nonatomic, copy)ExploreDetailTagViewClickBlock clickBlock;
@end

@implementation ExploreDetailNatantTagView

- (void)dealloc
{
    self.clickBlock = nil;
}

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomLineView];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _bottomLineView.backgroundColor = [UIColor colorWithDayColorName:@"cacaca" nightColorName:@"363636"];
}

- (void)refreshForJsonArray:(NSArray *)jsons clickBlock:(ExploreDetailTagViewClickBlock)block
{
    self.clickBlock = block;
    if ([jsons count] == 0) {
        self.keywordModels = nil;
    }
    else {
        NSMutableArray * ary = [NSMutableArray arrayWithCapacity:10];
        int index = 0;
        for (NSDictionary * dict in jsons) {
            if ([[dict allKeys] containsObject:@"name"] && [[dict allKeys] containsObject:@"label"]) {
                ExploreDetailKeyworkModel * model = [[ExploreDetailKeyworkModel alloc] init];
                model.name = [dict objectForKey:@"name"];
                model.label = [dict objectForKey:@"label"];
                model.modelIndex = index;
                [ary addObject:model];
                index ++;
            }
        }
        self.keywordModels = [NSArray arrayWithArray:ary];
    }
    
    [self refreshUI];
}

- (void)removeAllKeywordView
{
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[ExploreDetailKeyworkItemView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)refreshUI
{
    
    [self removeAllKeywordView];
    CGRect frame = self.frame;
    if ([_keywordModels count] == 0) {
        
        frame.size.height = kNoKeywordHeight;
    }
    else {
        float originX = kButtonLeftPadding;
        float originY = 0;
        for (ExploreDetailKeyworkModel * model in _keywordModels) {
            ExploreDetailKeyworkItemView * itemView = [[ExploreDetailKeyworkItemView alloc] initWithFrame:CGRectZero];
            [itemView.button addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
            [itemView refreshModel:model];
            if (originX + itemView.width > self.width) {//折行, 此处不能判断等于
                originY += kButtonHeight + kButtonBottomPadding;
                originX = kButtonLeftPadding;
            }
            itemView.origin = CGPointMake(originX, originY);
            originX += itemView.width + kButtonRightPadding;
            [self addSubview:itemView];
        }
        frame.size.height = originY + kButtonHeight + kBottomPadding;
    }
    
    self.frame = frame;
    
    _bottomLineView.frame = CGRectMake(kBottomLineLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kBottomLineLeftPadding - kBottomLineRightPadding, [TTDeviceHelper ssOnePixel]);
}

- (void)refreshWithWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    [self refreshUI];
}

- (void)itemClicked:(id)sender
{
    if ([[sender superview] isKindOfClass:[ExploreDetailKeyworkItemView class]]) {
        ExploreDetailKeyworkModel * model = ((ExploreDetailKeyworkItemView *)[sender superview]).model;
        if (!isEmptyString(model.label) && _clickBlock) {
            _clickBlock(model.modelIndex, model.label);
        }
    }
}

@end

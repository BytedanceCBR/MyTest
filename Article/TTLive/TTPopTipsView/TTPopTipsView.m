//
//  TTPopTipsView.m
//  TTLive
//
//  Created by xuzichao on 16/3/29.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import "TTPopTipsView.h"
#import "NSStringAdditions.h"
#import <Masonry/Masonry.h>
#import "UIButton+TTAdditions.h"
#import "TTAdapterManager.h"

@interface _TTPopTipsViewHitWrapper : UIView
- (instancetype)initWithPopTipsView:(TTPopTipsView *)popTipsView;
@end

@implementation _TTPopTipsViewHitWrapper
{
    __weak TTPopTipsView *_popTipsView;
}

- (instancetype)initWithPopTipsView:(TTPopTipsView *)popTipsView
{
    self = [super init];
    if (self) {
        _popTipsView = popTipsView;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint([_popTipsView.superview convertRect:_popTipsView.frame toView:nil], point)) {
        return nil;
    }
    [_popTipsView dismissAnimate:YES];
    return self;
}

@end


#define TTPopTipTrangleHeight      adapterSpace(10)

@interface TTPopTipsView ()

@property (nonatomic ,strong)UIView *wrapperView;
@property (nonatomic ,strong)SSThemedView *trangleView;
@property (nonatomic ,strong)SSThemedView *contentView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) _TTPopTipsViewHitWrapper *hitWrapper;

@end

@implementation TTPopTipsView
{
    TTPopTipViewType _type;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wrapperView = [[UIView alloc] init];
        self.trangleView = [[SSThemedView alloc] init];
        self.contentView = [[SSThemedView alloc] init];
    }
    
    return self;
}

//增加选项视图
- (void)setPopViewWithItem:(NSArray *)items type:(TTPopTipViewType)type;
{

    self.items = [NSMutableArray arrayWithArray:items];
    _type = type;
    
    //三角形
    UIView *trangleWrapper = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - TTPopTipTrangleHeight*2, 0, TTPopTipTrangleHeight*2*cos(M_PI_4), TTPopTipTrangleHeight*cos(M_PI_4))];
    trangleWrapper.clipsToBounds = YES;
    
    self.trangleView.frame = CGRectMake(0, 0, TTPopTipTrangleHeight, TTPopTipTrangleHeight);
    self.trangleView.transform = CGAffineTransformRotate(self.trangleView.transform, M_PI/4);
    self.trangleView.center = CGPointMake(trangleWrapper.frame.size.width/2, trangleWrapper.frame.size.height);
    [trangleWrapper addSubview:self.trangleView];
    
    
    UIView *contentTemp = nil;
    if (type == TTPopTipsMessage) {
        contentTemp = [self setUpTipMessageView:items];
        [self setBackgroundColorThemeKey:kColorBackground4];
        [self setBorderColorThemeKey:kColorLine2];
        
        self.contentView.frame = CGRectMake(0, trangleWrapper.frame.size.height - 1, self.frame.size.width,contentTemp.frame.size.height);
    }
    else if (type == TTPopTipsAction) {
        contentTemp = [self setUpTipActionView:items];
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.65]];
        [self setBorderColor:[UIColor colorWithWhite:0 alpha:0.32]];
        
        self.contentView.frame = CGRectMake(0, trangleWrapper.frame.size.height, self.frame.size.width,contentTemp.frame.size.height);
    }
    
    //内容部分
    self.contentView.layer.cornerRadius = adapterSpace(5);
    [self.contentView addSubview:contentTemp];
    
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,self.trangleView.frame.size.height+self.contentView.frame.size.height);
    [self setFrame:frame];
    
    self.wrapperView.clipsToBounds = YES;
    self.clipsToBounds = YES;
    
    [self.wrapperView addSubview:self.contentView];
    [self.wrapperView addSubview:trangleWrapper];
    [[self.wrapperView layer] setAnchorPoint:CGPointMake(1, 0)];
    [self addSubview:self.wrapperView];
    [self.wrapperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(-frame.size.height/2);
        make.left.equalTo(self.mas_left).offset(frame.size.width/2);
        make.width.mas_equalTo(self.frame.size.width);
        make.height.mas_equalTo(self.frame.size.height);
    }];
}

- (UIView *)setUpTipMessageView:(NSArray *)items
{
    UIView *view = [[UIView alloc] init];
    view.clipsToBounds = YES;
    for (TTPopTipItem *item in items) {
        if (item.type == TTPopTipsMessage) {
    
            CGSize textSize = [item.tipDesc sizeWithFont:[UIFont systemFontOfSize:adapterFont(12)] constrainedToSize:CGSizeMake(self.frame.size.width - adapterSpace(20), MAXFLOAT) paragraphStyle:nil];
            SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectMake(adapterSpace(10), adapterSpace(10), textSize.width, textSize.height)];
            label.numberOfLines = 0;
            label.text = item.tipDesc;
            label.textColorThemeKey = kColorText1;
            label.font = [UIFont systemFontOfSize:adapterFont(12)];
            
            SSThemedButton *button = [[SSThemedButton alloc] initWithFrame:CGRectMake(self.frame.size.width - adapterSpace(60), adapterSpace(10) + textSize.height + adapterSpace(2), adapterSpace(50), adapterSpace(20))];
            button.titleLabel.font = [UIFont systemFontOfSize:adapterFont(12)];
            button.backgroundColorThemeKey = kColorBackground7;
            button.titleColorThemeKey = kColorText7;
            button.layer.cornerRadius = adapterSpace(2);
            [button setTitle:item.tipBtnTitle forState:UIControlStateNormal];
            
            [button addTarget:self withActionBlock:item.block forControlEvent:UIControlEventTouchUpInside];
            
            view.frame = CGRectMake(0, 0, self.frame.size.width, button.frame.origin.y + button.frame.size.height + adapterSpace(10));
            [view addSubview:label];
            [view addSubview:button];
            
            break;
        }
    }
    
    return view;
}


- (UIView *)setUpTipActionView:(NSArray *)items
{
    UIView *view = [[UIView alloc] init];
    view.clipsToBounds = YES;
    CGFloat contentHeight = 0;
    NSUInteger index = 0;
    for (TTPopTipItem *item in items) {
        if (item.type == TTPopTipsAction) {
            
            UIView *btnWrapper = [[UIView alloc] initWithFrame:CGRectMake(adapterSpace(15),index * adapterSpace(50)+index, self.frame.size.width - adapterSpace(15) * 2 , adapterSpace(50))];
            btnWrapper.clipsToBounds = YES;
            SSThemedButton *button = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, btnWrapper.frame.size.width, btnWrapper.frame.size.height)];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:item.tipBtnTitle forState:UIControlStateNormal];
            [button setImage:item.tipActionImage forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -adapterSpace(16), 0, 0);
            [button addTarget:self withActionBlock:item.block forControlEvent:UIControlEventTouchUpInside];
            [btnWrapper addSubview:button];
            [view addSubview:btnWrapper];
            
            contentHeight += btnWrapper.frame.size.height;
            index++;
            
            //最后一个不加
            if (index != items.count) {
                
                CGRect lineFrame = CGRectMake(0, btnWrapper.frame.size.height - 1, btnWrapper.frame.size.width, 1);
                UIView *line = [[UIView alloc] initWithFrame:lineFrame];
                line.backgroundColor = [UIColor whiteColor];
                line.alpha = 0.1;
                [button addSubview:line];
                
            }
        }
    }
    
    view.frame = CGRectMake(0, 0, self.frame.size.width, contentHeight);
    
    return view;
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey
{
    self.contentView.backgroundColorThemeKey = backgroundColorThemeKey;
    self.trangleView.backgroundColorThemeKey = backgroundColorThemeKey;
}

- (void)setBorderColorThemeKey:(NSString *)borderColorThemeKey
{
    self.contentView.borderColorThemeKey = borderColorThemeKey;
    self.trangleView.borderColorThemeKey = borderColorThemeKey;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.contentView.backgroundColor = backgroundColor;
    self.trangleView.backgroundColor = backgroundColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.contentView.layer.borderColor = [borderColor CGColor];
    self.trangleView.layer.borderColor = [borderColor CGColor];
}

- (void)dismissAnimate:(BOOL)animate
{
    if (animate) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.wrapperView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.wrapperView.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;

            [_hitWrapper removeFromSuperview];
        }];
    }
    else {
        self.hidden = YES;
        self.wrapperView.alpha = 0;
        
        [_hitWrapper removeFromSuperview];
    }
}


- (void)showAnimate:(BOOL)animate
{
    if (_type != TTPopTipsMessage) {
        [self showBackLayerBtn];
    }
    
    self.hidden = NO;
    self.wrapperView.alpha = 0;
    self.wrapperView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    if (animate) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.wrapperView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.wrapperView.alpha = 1;
        } completion:nil];
    }
    else {
        self.wrapperView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.hidden = NO;
        self.wrapperView.alpha = 1;
    }
    
}


- (BOOL)dismiss
{
    return self.hidden;
}


- (void)showBackLayerBtn
{
    if (!_hitWrapper.superview) {
        UIWindow *window = SSGetMainWindow();
        if (!_hitWrapper) {
            _hitWrapper = [[_TTPopTipsViewHitWrapper alloc] initWithPopTipsView:self];
            _hitWrapper.frame = window.bounds;
            _hitWrapper.alpha = 0.2;
        }
        [window addSubview:_hitWrapper];
    }
}


- (void)replaceItemByTitle:(NSString *)title withItem:(TTPopTipItem *)item
{
    NSMutableArray *tempItems = [NSMutableArray arrayWithArray:self.items];
    
    for (TTPopTipItem *oldItem in self.items) {
        if ([oldItem.tipBtnTitle isEqualToString:title]) {
            [tempItems replaceObjectAtIndex:[tempItems indexOfObject:oldItem] withObject:item];
        }
    }
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in self.wrapperView.subviews) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [self setPopViewWithItem:tempItems type:item.type];
    
}

@end


@implementation TTPopTipItem
@end


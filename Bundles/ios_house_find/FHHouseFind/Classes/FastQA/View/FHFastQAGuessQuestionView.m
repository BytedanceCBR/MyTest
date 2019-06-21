//
//  FHFastQAGuessQuestionView.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHFastQAGuessQuestionView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>

#define ITEM_HOR_PADDING 10
#define ITEM_VER_PADDING 10
#define ITEM_TAG_BASE    1000

@interface FHFastQAGuessQuestionView ()

@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) NSMutableArray *buttons;

@end

@implementation FHFastQAGuessQuestionView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"猜你想问";
        _tipLabel.textColor = [UIColor themeGray1];
        [_tipLabel sizeToFit];
        [self addSubview:_tipLabel];
        
        _buttons = [NSMutableArray new];
        self.clipsToBounds = YES;
    }
    return self;
}

-(NSInteger)updateWithItems:(NSArray *)items
{
    [_buttons enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    BOOL newRow = NO;
    CGRect frame = CGRectMake(-ITEM_HOR_PADDING, 27, 0, 0) ;
    NSInteger index = 0;
    
    for (NSString *item in items) {
        UIButton *btn = [self buttonForTitle:item];
        btn.tag = (ITEM_TAG_BASE+index++);
        CGRect f = btn.frame;
        f.size = CGSizeMake(f.size.width+30, 30);
        if (CGRectGetWidth(f) >= self.bounds.size.width) {
            f.size.width = self.bounds.size.width;
        }
        if (CGRectGetMaxX(frame) + ITEM_HOR_PADDING + CGRectGetWidth(f) > CGRectGetWidth(self.bounds)) {
            //new row
            if (newRow) {
                //超过两行
                break;
            }
            f.origin.y = CGRectGetMaxY(frame) + ITEM_VER_PADDING;
            f.origin.x = 0;
            newRow = YES;
        }else{
            f.origin = CGPointMake(CGRectGetMaxX(frame)+ITEM_HOR_PADDING,frame.origin.y);
        }
        btn.frame = f;
        frame = f;
        [self.buttons addObject:btn];
        [self addSubview:btn];
    }
    
    CGRect bounds = self.bounds ;
    bounds.size.height = CGRectGetMaxY(frame);
    self.bounds = bounds;
    return index-1;
}

-(void)selectAtIndex:(NSInteger)index
{
    [self.buttons enumerateObjectsUsingBlock:^(UIButton  * _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == index) {
            btn.backgroundColor = [UIColor themeRed1];
            btn.layer.borderWidth = 0;
        }else{
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.borderWidth = 0.5;
        }
    }];
}

-(UIButton *)buttonForTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont themeFontRegular:14];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [RGB(0x97, 0x97, 0x97) CGColor];
    button.layer.masksToBounds = YES;
    
    [button addTarget:self action:@selector(onItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
        
    return button;
}


-(void)onItemAction:(UIButton *)button
{
    NSInteger index = [self.buttons indexOfObject:button];
    [self selectAtIndex:index];
    if (index < self.buttons.count && [self.delegate respondsToSelector:@selector(selectView:atIndex:)]) {
        [self.delegate selectView:self atIndex:index];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

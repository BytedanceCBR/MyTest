//
//  FHVideoAndImageItemCorrectingView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/14.
//

#import "FHVideoAndImageItemCorrectingView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIButton+TTAdditions.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHVideoAndImageItemCorrectingView ()

@property(nonatomic, strong) NSMutableArray *btnArray;
//每行显示多少个，自动根据宽度计算
@property(nonatomic, assign) NSInteger row;
@property(nonatomic, strong) UIView *bgView;

@end

@implementation FHVideoAndImageItemCorrectingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        //设置默认值
        _btnArray = [NSMutableArray array];
        _itemWidth = 44.0f;
        _itemHeight = 22.0f;
        _itemPadding = 0.0f;
        //有vr时多个视图间距
        _topMargin = 0;
        _leftMargin = 5.0f;
        _bgColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _textColor = [UIColor themeGray1];
        _selectedBgColor = [UIColor colorWithHexStr:@"#ff9629"];
        _selectedTextColor = [UIColor whiteColor];
        _font = [UIFont themeFontRegular:12];
    }
    return self;
}

- (void)calculateRow {
    CGFloat width = self.bounds.size.width;
    NSInteger temp = width/(_itemPadding + _itemWidth);
    if(temp > 0){
        CGFloat diff = width - temp * _itemWidth - (temp - 1) * _itemPadding;
        if(diff < _itemWidth){
            self.row = temp;
        }else{
            self.row = temp + 1;
        }
    }
}

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    
    [self calculateRow];
    if(self.row > 0){
        [self initViews];
    }
}

- (void)setValueArray:(NSArray *)valueArray {
    _valueArray = valueArray;
}

- (void)initViews {
    
    if(self.bgView){
        [self.bgView removeFromSuperview];
        self.bgView = nil;
    }

    for (UIButton *btn in self.btnArray) {
        [btn removeFromSuperview];
    }
    [self.btnArray removeAllObjects];
    
    NSArray *titleArray = self.titleArray.copy;
    
    self.bgView = [[UIView alloc] init];
    self.bgView.layer.cornerRadius = self.itemHeight/2;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.backgroundColor = self.bgColor;
    self.bgView.btd_hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(self.itemWidth * titleArray.count);
        make.height.mas_equalTo(self);
    }];
    
    UIView *lastView = self.bgView;
    for (NSInteger i = 0; i < titleArray.count; i++) {
        UIButton *button = [self buttonWithTitle:titleArray[i]];
        CGFloat left = 0;
        CGFloat right = 0;
        if (i == 0) {
            left = -20;
        }
        if (i == titleArray.count - 1) {
            right = -20;
        }
        button.btd_hitTestEdgeInsets = UIEdgeInsetsMake(-20, left, -20, right);
        [self.bgView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if(i%self.row == 0){
                make.left.equalTo(self.bgView);
            }else{
                make.left.mas_equalTo(lastView.mas_right).offset(self.itemPadding);
            }
            make.centerY.equalTo(self.bgView);
            make.width.mas_equalTo(self.itemWidth);
            make.height.mas_equalTo(self.itemHeight);
        }];
        [self.btnArray addObject:button];
        lastView = button;
    }
    self.viewHeight = CGRectGetMaxY(lastView.frame);
    
    [self layoutIfNeeded];
}

- (UIButton *)buttonWithTitle:(NSString *)title{
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:self.textColor forState:UIControlStateNormal];
    btn.titleLabel.font = self.font;
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = self.itemHeight/2;
    btn.layer.masksToBounds = YES;
    return btn;
}

- (void)btnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtn:btn];
    NSInteger index = 0;
    if ([_titleArray containsObject:btn.titleLabel.text]) {
        index = [_titleArray indexOfObject:btn.titleLabel.text];
    }
    NSString *value = nil;
    if(index < _valueArray.count){
        value = _valueArray[index];
    }
    if(self.selectedBlock){
        self.selectedBlock(index, btn.titleLabel.text, value);
    }
}

- (void)selectBtn:(UIButton *)btn {
    for (UIButton *button in self.btnArray) {
        if(button == btn){
            [button setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
            button.backgroundColor = self.selectedBgColor;
        }else{
            [button setTitleColor:self.textColor forState:UIControlStateNormal];
            button.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)selectedItem:(NSString *)name {
    NSInteger selectedIndex = [_titleArray indexOfObject:name];
    if(selectedIndex < _btnArray.count){
        UIButton *btn =_btnArray[selectedIndex];
        [self selectBtn:btn];
    }
}

- (void)clearAllSelection {
    for (UIButton *button in self.btnArray) {
        [button setTitleColor:self.textColor forState:UIControlStateNormal];
        button.backgroundColor = self.bgColor;
    }
}

@end


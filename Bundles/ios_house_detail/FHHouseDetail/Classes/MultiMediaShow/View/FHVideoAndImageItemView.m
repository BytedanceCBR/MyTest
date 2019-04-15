//
//  FHVideoAndImageItemView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/14.
//

#import "FHVideoAndImageItemView.h"

#import "FHVideoAndImageItemView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>

@interface FHVideoAndImageItemView ()

@property(nonatomic, strong) NSMutableArray *btnArray;
//每行显示多少个，自动根据宽度计算
@property(nonatomic, assign) NSInteger row;

@end

@implementation FHVideoAndImageItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        //设置默认值
        _btnArray = [NSMutableArray array];
        _itemWidth = 44.0f;
        _itemHeight = 20.0f;
        _itemPadding = 10.0f;
        _bgColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        _textColor = [UIColor themeGray1];
        _selectedBgColor = [UIColor themeRed1];
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
    UIView *lastView = self;
    for (NSInteger i = 0; i < _titleArray.count; i++) {
        UIButton *button = [self buttonWithTitle:_titleArray[i] tag:i];
        [self addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if(i%self.row == 0){
                make.left.mas_equalTo(self);
            }else{
                make.left.mas_equalTo(lastView.mas_right).offset(self.itemPadding);
            }
            make.top.mas_equalTo(self).offset(i/self.row * (self.itemHeight + self.itemPadding));
            make.width.mas_equalTo(self.itemWidth);
            make.height.mas_equalTo(self.itemHeight);
        }];
        
        [self.btnArray addObject:button];
        lastView = button;
    }
    [self layoutIfNeeded];
    self.viewHeight = CGRectGetMaxY(lastView.frame);
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = self.bgColor;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:self.textColor forState:UIControlStateNormal];
    btn.titleLabel.font = self.font;
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = self.itemHeight/2;
    btn.layer.masksToBounds = YES;
    btn.tag = tag;
    return btn;
}

- (void)btnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self selectBtn:btn];
    NSInteger tag = btn.tag;
    NSString *value = nil;
    if(tag < _valueArray.count){
        value = _valueArray[tag];
    }
    if(self.selectedBlock){
        self.selectedBlock(tag, btn.titleLabel.text, value);
    }
}

- (void)selectBtn:(UIButton *)btn {
    for (UIButton *button in self.btnArray) {
        if(button == btn){
            [button setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
            button.backgroundColor = self.selectedBgColor;
        }else{
            [button setTitleColor:self.textColor forState:UIControlStateNormal];
            button.backgroundColor = self.bgColor;
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

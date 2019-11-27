//
//  FHVideoAndImageItemCorrectingView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/14.
//

#import "FHVideoAndImageItemCorrectingView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIButton+TTAdditions.h"


@interface FHVideoAndImageItemCorrectingView ()

@property(nonatomic, strong) NSMutableArray *btnArray;
//每行显示多少个，自动根据宽度计算
@property(nonatomic, assign) NSInteger row;
@property(nonatomic, strong) NSMutableArray *itemBacViewArr;
@property(nonatomic, strong) NSArray *titleTypeArr;
@property(nonatomic, strong) UIView *bgView;

@end

@implementation FHVideoAndImageItemCorrectingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        //设置默认值
        _btnArray = [NSMutableArray array];
        _itemWidth = 44.0f;
        _itemHeight = 20.0f;
        _itemPadding = 0.0f;
        //有vr时多个视图间距
        _bgViewPadding = 20.0f;
        _topMargin = 0;
        _leftMargin = 5.0f;
        _bgColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _textColor = [UIColor themeGray1];
        _selectedBgColor = [UIColor colorWithHexStr:@"#ff9629"];
        _itemBacViewArr = [[NSMutableArray alloc]init];
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
    NSMutableArray *otherTypeArr = [_titleArray mutableCopy];
    BOOL hasvr = [_titleArray containsObject:@"VR"];
    if (hasvr) {
        [otherTypeArr removeObject: @"VR"];
        _titleTypeArr = [NSArray arrayWithObjects:@[@"VR"],otherTypeArr, nil];
    }else {
        _titleTypeArr =  [NSArray arrayWithObjects:otherTypeArr, nil];
    }
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
    
    for (UIView  *itemBacView in self.itemBacViewArr) {
        [itemBacView removeFromSuperview];
    }
    [self.itemBacViewArr removeAllObjects];
    for (UIButton *btn in self.btnArray) {
        [btn removeFromSuperview];
    }
    [self.btnArray removeAllObjects];
    
    self.bgView = [[UIView alloc] init];
    _bgView.layer.cornerRadius = self.itemHeight/2;
    _bgView.layer.masksToBounds = YES;
    [self addSubview:_bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.mas_equalTo(self);
        make.width.mas_equalTo(self.itemWidth * self.titleArray.count + (self.titleTypeArr.count-1)* self.bgViewPadding);
        make.height.mas_equalTo(self);
    }];
    
    [_titleTypeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *itemArr = (NSArray *)obj;
        UIView *itemBacView  =[[UIView alloc]init];
        itemBacView.backgroundColor = self.bgColor;
        itemBacView.layer.cornerRadius = self.itemHeight/2;
        itemBacView.layer.masksToBounds = YES;
        [self.bgView addSubview:itemBacView];
        [self.itemBacViewArr addObject:itemBacView];
        [itemBacView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView).offset(idx *(self.itemWidth + self.bgViewPadding));
            make.width.mas_offset(itemArr.count *self.itemWidth);
            make.top.equalTo(self.bgView);
            make.height.mas_equalTo(self.itemHeight);
        }];
        UIView *lastView = self;
        for (NSInteger i = 0; i < itemArr.count; i++) {
            UIButton *button = [self buttonWithTitle:itemArr[i]];
            [itemBacView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                if(i%self.row == 0){
                    make.left.equalTo(itemBacView);
                }else{
                    make.left.mas_equalTo(lastView.mas_right).offset(self.itemPadding);
                }
                make.top.equalTo(self);
                make.width.mas_equalTo(self.itemWidth);
                make.height.mas_equalTo(self.itemHeight);
            }];
            [self.btnArray addObject:button];
            lastView = button;
        }
        self.viewHeight = CGRectGetMaxY(lastView.frame);
    }];
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
    btn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, 0, -10, 0);
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


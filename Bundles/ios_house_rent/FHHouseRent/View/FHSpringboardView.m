//
//  FHSpringboardView.m
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHSpringboardView.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <UIViewAdditions.h>


@implementation FHSpringboardIconItemView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.iconBottomPadding = 0;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithIconBottomPadding:(CGFloat)padding
{
    self = [super init];
    if (self) {
        self.iconBottomPadding = padding;
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.iconView = [[UIImageView alloc] init];
    [self addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(52);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(15);
        make.bottom.mas_equalTo(_iconBottomPadding == 0 ? -42 : _iconBottomPadding);
    }];

    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont themeFontRegular:14];
    _nameLabel.textColor = [UIColor themeBlack];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.iconView.mas_bottom).mas_offset(8);
    }];
}

@end

@interface FHSpringboardView ()
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray<FHSpringboardIconItemView*>* items;
@end

@implementation FHSpringboardView

- (instancetype)init
{
    self = [self initWithRowCount:4];
    if (self) {
        [self addGesture];
    }
    return self;
}

- (instancetype)initWithRowCount:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.count = count;
        [self addGesture];
    }
    return self;
}

-(void)addGesture
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self addGestureRecognizer:gesture];
}

-(void)onTapGesture:(UITapGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateEnded:
        {
            CGPoint location = [gesture locationInView:self];
            NSInteger index = location.x/(self.width/self.count);
            if (index >= self.items.count) {
                return;
            }
            FHSpringboardIconItemView *iconView = self.items[index];
            if (CGRectContainsPoint(iconView.frame, location)) {
                if (self.tapIconBlock) {
                    self.tapIconBlock(index);
                }
            }
            break;
        }
        default:
            break;
    }
}

-(void)addItems:(NSArray<FHSpringboardIconItemView*>*)items {
    NSParameterAssert(items);
    NSAssert([items count] <= _count, @"此控件限制一行只能显示4个icon");
    self.items = items;
    if ([items count] > _count) {
        return;
    }
    [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    __weak typeof(self) weakRef = self;
    [items enumerateObjectsUsingBlock:^(FHSpringboardIconItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakRef addSubview:obj];
    }];
    
    self.currentIconItems = items;

    [self layoutItems:_items];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutItems:_items];
}

-(void)layoutItems:(NSArray<FHSpringboardIconItemView*>*)items {
    CGFloat itemWidth = [[UIScreen mainScreen] bounds].size.width / _count;
    [items enumerateObjectsUsingBlock:^(FHSpringboardIconItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(idx * itemWidth);
            make.width.mas_equalTo(itemWidth);
            make.top.bottom.mas_equalTo(self);
        }];
    }];
//    [items enumerateObjectsUsingBlock:^(FHSpringboardIconItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.frame = CGRectMake(itemWidth * idx, 0, itemWidth, self.frame.size.height);
//    }];
}


@end

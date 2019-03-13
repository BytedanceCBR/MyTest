//
//  FHNavBarView.m
//  Article
//
//  Created by 张元科 on 2018/12/9.
//

#import "FHNavBarView.h"
#import "UIColor+Theme.h"

static const CGFloat kNaviLeftRightMargin = 18.0f;

@interface FHNavBarView ()

@property (nonatomic, strong) UIView    *bgView;
@property (nonatomic, strong) UIView    *rightView;
@property (nonatomic, strong) NSMutableArray *rightViewsArray;
@property (nonatomic, strong) UIView    *seperatorLine;

@end

@implementation FHNavBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _bgView = [[UIView alloc] init];
    _bgView.alpha = 0.5;
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    _leftBtn = [[FHHotAreaButton alloc] init];
    [_leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
    [_leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    [self addSubview:_leftBtn];
    [_leftBtn addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kNaviLeftRightMargin);
        make.width.height.mas_equalTo(24);
        make.bottom.mas_equalTo(-10);
    }];
    
    _rightView = [[UIView alloc] init];
    [self addSubview:_rightView];
    _rightView.backgroundColor = UIColor.clearColor;
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.centerY.mas_equalTo(_leftBtn.mas_centerY);
        make.height.mas_equalTo(44);
        // 设置导航栏右边按钮之后要重新布局width
        make.width.mas_equalTo(kNaviLeftRightMargin);
    }];
    
    _title = [[UILabel alloc] init];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.textColor = [UIColor themeGray1];
    _title.font = [UIFont themeFontMedium:18];
    [self addSubview:_title];
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_leftBtn.mas_centerY);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(28);
        // 设置导航栏右边按钮后title宽度要重新计算
        CGFloat w = UIScreen.mainScreen.bounds.size.width - 2 *(24 + kNaviLeftRightMargin + 10);
        make.width.mas_equalTo(w);
    }];
    
    _seperatorLine = [[UIView alloc] init];
    _seperatorLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_seperatorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.right.bottom.mas_equalTo(self);
    }];
    _rightViewsArray = [[NSMutableArray alloc] init];
    self.backgroundColor = UIColor.whiteColor;
}

// 添加导航栏右边视图，移除之前视图，从右向左排列，默认第一个viewRightOffset：@18.0，NSNumber类型
- (void)addRightViews:(NSArray *)rightViews viewsWidth:(NSArray *)viewsWidth viewsHeight:(NSArray *)viewsHeight viewsRightOffset:(NSArray *)viewsRightOffset {
    [_rightViewsArray enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_rightViewsArray removeAllObjects];
    __block UIView *lastRightView = self;
    __block CGFloat rightViewWidth = 0;
    [rightViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < viewsWidth.count && idx < viewsHeight.count  && idx < viewsRightOffset.count) {
            CGFloat wid = [viewsWidth[idx] floatValue];
            CGFloat hei = [viewsHeight[idx] floatValue];
            CGFloat rightOffset = [viewsRightOffset[idx] floatValue];
            [_rightView addSubview:obj];
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.rightView.mas_centerY);
                if (lastRightView == self) {
                    make.right.mas_equalTo(lastRightView.mas_right).offset(-rightOffset);
                } else {
                    make.right.mas_equalTo(lastRightView.mas_left).offset(-rightOffset);
                }
                make.height.mas_equalTo(hei);
                make.width.mas_equalTo(wid);
            }];
            rightViewWidth += (wid + rightOffset);
            [self.rightViewsArray addObject:obj];
            lastRightView = obj;
        }
    }];
    if (rightViewWidth < kNaviLeftRightMargin) {
        rightViewWidth = kNaviLeftRightMargin;
    }
    
    [_rightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(rightViewWidth);
    }];
    
    CGFloat backButtonWidth = 24 + kNaviLeftRightMargin;
    CGFloat titleW = UIScreen.mainScreen.bounds.size.width - ((rightViewWidth > backButtonWidth ? rightViewWidth : backButtonWidth) + 10) * 2;
    if (titleW > 0) {
        self.title.hidden = NO;
        [_title mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(titleW);
        }];
    } else {
        self.title.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)leftButtonClick:(UIButton *)btn {
    if(_leftButtonBlock){
        _leftButtonBlock();
    }
}

@end

@interface FHHotAreaButton ()

@end

@implementation FHHotAreaButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    CGFloat widthDelta = bounds.size.width;
    CGFloat heightDelta = bounds.size.height;
    bounds = CGRectMake(bounds.origin.x - widthDelta, bounds.origin.y - heightDelta, widthDelta * 2, heightDelta * 2);
    return CGRectContainsPoint(bounds, point);
}

@end

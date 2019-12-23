//
//  FHSpringHangView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/12/23.
//

#import "FHSpringHangView.h"
#import <Masonry.h>
#import "UIButton+TTAdditions.h"
#import <TTRoute.h>

@interface FHSpringHangView ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIButton *closeBtn;

@end

@implementation FHSpringHangView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstaints];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_spring_yunying"]];
    self.bgView.userInteractionEnabled = YES;
    [self addSubview:_bgView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSpring:)];
    [self.bgView addGestureRecognizer:tap];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"fh_spring_yunying_close"] forState:UIControlStateNormal];
    [_closeBtn setImage:[UIImage imageNamed:@"fh_spring_yunying_close"] forState:UIControlStateHighlighted];
    _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
}

- (void)initConstaints {
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(8);
        make.right.mas_equalTo(self).offset(-8);
        make.left.bottom.mas_equalTo(self);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.bgView);
        make.width.height.mas_equalTo(12);
    }];
}

- (void)close {
    [self removeFromSuperview];
}

- (void)goToSpring:(UITapGestureRecognizer *)sender {
    NSString *urlStr = @"sslocal://webview?url=www.baidu.com";
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

@end

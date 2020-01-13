//
//  FHIntroduceItemView.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import "FHIntroduceItemView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import <UIFont+House.h>
#import <Lottie/LOTAnimationView.h>

@interface FHIntroduceItemView ()

@property (nonatomic , strong) FHIntroduceItemModel *model;
@property (nonatomic , strong) UIButton *enterBtn;
@property (nonatomic , strong) UIImageView *imageContentView;
@property (nonatomic , strong) LOTAnimationView *animationView;
@property (nonatomic , strong) UIImageView *bottomBgView;

@end

@implementation FHIntroduceItemView

- (instancetype)initWithFrame:(CGRect)frame model:(FHIntroduceItemModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self initView];
        [self initConstraints];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.model.lottieJsonStr ofType:@"json"];
    self.animationView = [LOTAnimationView animationWithFilePath:path]; 
    _animationView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_animationView];
    
    self.bottomBgView = [[UIImageView alloc] init];
    _bottomBgView.contentMode = UIViewContentModeScaleAspectFill;
    _bottomBgView.image = [UIImage imageNamed:@"fh_introduce_bottom_bg"];
    [self addSubview:_bottomBgView];
    
    self.enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_enterBtn setImage:[UIImage imageNamed:@"fh_introduce_enter"] forState:UIControlStateNormal];
    [_enterBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    _enterBtn.hidden = !self.model.showEnterBtn;
    [self addSubview:_enterBtn];
}

- (void)initConstraints {
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-bottom);
        make.height.mas_equalTo(56);
    }];
    
    [self.enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-14 - bottom);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(260);
        make.height.mas_equalTo(64);
    }];
}

- (void)play {
    if(self.model.played){
        return;
    }
    __weak typeof(self) wself = self;
    [_animationView playWithCompletion:^(BOOL animationFinished) {
        wself.model.played = YES;
    }];
}

- (void)close {
    if(self.delegate && [self.delegate respondsToSelector:@selector(close)]){
        [self.delegate close];
    }
}

@end

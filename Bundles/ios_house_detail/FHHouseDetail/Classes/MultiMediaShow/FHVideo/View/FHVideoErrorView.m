//
//  FHVideoErrorView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/29.
//

#import "FHVideoErrorView.h"
#import "UIImage+TTVHelper.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import "UIFont+House.h"
#import "UIButton+TTAdditions.h"
#import "UIImageView+BDWebImage.h"

@interface FHVideoErrorView ()

@property (nonatomic, strong) UILabel *retryLabel;
@property (nonatomic, assign) BOOL showRetry;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation FHVideoErrorView
@synthesize didClickBack = _didClickBack;
@synthesize didClickRetry = _didClickRetry;

- (instancetype)init {
    self = [super init];
    if (self) {
        _bgImageView = [[UIImageView alloc] init];
        [self addSubview:_bgImageView];
        
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self addSubview:_coverView];
        
        self.showRetry = YES;
        self.hidden = YES;
        _retryLabel = [[UILabel alloc] init];
        _retryLabel.textColor = [UIColor whiteColor];
        _retryLabel.font = [UIFont themeFontRegular:12];
        _retryLabel.text = @"视频加载失败，请检查网络并重试";
        [self addSubview:_retryLabel];

        _retryButton = [[UIButton alloc] init];
        _retryButton.hitTestEdgeInsets = UIEdgeInsetsMake(-80, -60, -48, -60); // 扩大加载失败页面的点击区域
        _retryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
        _retryButton.titleLabel.font = [UIFont themeFontRegular:12];
        [_retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _retryButton.layer.cornerRadius = 13;
        _retryButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        [_retryButton addTarget:self action:@selector(retryClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_retryButton];
        
        self.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleTap];
    }
    return self;
}

#pragma mark -
#pragma mark public methods

- (void)retryClicked:(id)sender {
    if(self.willClickRetry){
        self.willClickRetry();
    }
    
    if (self.didClickRetry) {
        self.hidden = YES;
        self.didClickRetry();
    }
}

- (void)retryBackBtnClicked:(id)sender {
    if (self.didClickBack) {
        self.didClickBack();
    }
}

#pragma mark -
#pragma mark UI

- (void)ttvl_buildConstraints {
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];

    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY).offset(8);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(68);
        make.height.mas_equalTo(26);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = self.superview.bounds;
}

- (void)show {
    self.userInteractionEnabled = YES;
    self.hidden = NO;

    [self.retryLabel sizeToFit];
    self.retryButton.hidden = !self.showRetry;
    [self ttvl_buildConstraints];
    if (self.retryButton.hidden) {
        [self.retryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_centerY);
            make.centerX.equalTo(self);
        }];
    }else{
        [self.retryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_centerY).offset(-8);
            make.centerX.equalTo(self);
        }];
    }
    [self layoutIfNeeded];
}

- (void)dismiss {
    self.hidden = YES;
    [self removeFromSuperview];
}

- (BOOL)isShowed {
    if (self.hidden) {
        return NO;
    }
    if (!self.hidden && !self.superview) {
        return NO;
    }
    return YES;
}

- (void)showRetry:(BOOL)show {
    self.showRetry = show;
    [self setNeedsLayout];
}

- (void)setErrorText:(NSString *)errorText {
//    self.retryLabel.text = errorText;
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    [self.bgImageView bd_setImageWithURL:url placeholder:nil];
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender {
    //什么都不做，就是为了不让下面的view可以点击
}

@end

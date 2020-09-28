//
//  FHVideoCoverView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/25.
//

#import "FHVideoCoverView.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"

@interface FHVideoCoverView ()

@property(nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) UIView *maskView;
@end

@implementation FHVideoCoverView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstaints];
    }
    
    return self;
}

- (void)initViews {
    self.coverView = [[UIImageView alloc] initWithFrame:self.bounds];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.clipsToBounds = YES;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_coverView];
    _maskView = [[UIView alloc] init];
    _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [self.coverView addSubview:self.maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.coverView);
    }];
    
    self.startBtn = [[UIButton alloc] init];
    [_startBtn setImage:[UIImage imageNamed:@"detail_video_start"] forState:UIControlStateNormal];
    [_startBtn setImage:[UIImage imageNamed:@"detail_video_start"] forState:UIControlStateHighlighted];
    [_startBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_startBtn];
}

- (void)initConstaints {
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(70);
        make.center.equalTo(self);
    }];
}

-(void)showWithImageUrl:(NSString *)imageUrl placeHoder:(UIImage *)placeHolder
{
    _imageUrl = imageUrl;
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    if(!placeHolder){
        placeHolder = self.placeHolder;
    }
    [self.coverView bd_setImageWithURL:url placeholder:placeHolder];
}

- (void)setImageUrl:(NSString *)imageUrl {

    [self showWithImageUrl:imageUrl placeHoder:nil];
}

- (void)setLoadingView:(UIView *)loadingView {
    _loadingView = loadingView;
    [_loadingView removeFromSuperview];
    [self addSubview:loadingView];
}

- (void)playVideo {
    if(self.delegate && [self.delegate respondsToSelector:@selector(playVideo)]){
        [self.delegate playVideo];
    }
}

-(UIImage *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

@end

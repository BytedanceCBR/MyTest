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
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.clipsToBounds = YES;
    self.coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.coverView.userInteractionEnabled = YES;
    [self addSubview:self.coverView];
    
    _maskView = [[UIView alloc] init];
    _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [self.coverView addSubview:self.maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.coverView);
    }];
    
    self.startBtn = [[UIImageView alloc] init];
    self.startBtn.image = [UIImage imageNamed:@"detail_video_start"];
    
    UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVideo)];

    [self.startBtn addGestureRecognizer:tapGesturRecognizer];
    
    self.startBtn.userInteractionEnabled = YES;
    [self.coverView addSubview:_startBtn];
}

- (void)initConstaints {
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerView.frame = self.bounds;
}

- (void)setPlayerView:(UIView *)playerView {
    if(!_playerView){
        _playerView = playerView;
        _playerView.frame = self.bounds;
        [self insertSubview:_playerView belowSubview:_coverView];
    }
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

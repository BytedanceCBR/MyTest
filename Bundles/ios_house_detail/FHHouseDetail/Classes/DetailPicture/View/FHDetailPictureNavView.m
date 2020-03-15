//
//  FHDetailPictureNavView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/15.
//

#import "FHDetailPictureNavView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailPictureNavView ()
@property (nonatomic, strong)   UIImage       *backWhiteImage;
@property(nonatomic , strong) UIButton *backBtn;
@property(nonatomic , strong) UIButton *albumBtn;

@end

@implementation FHDetailPictureNavView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateNormal];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.frame = CGRectMake(20, 10, 24, 24);
    [self addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.frame.size.width - 100, 24)];
    _titleLabel.text = @"图片";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont themeFontMedium:18];
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];
    
    // 视频 图片title
    CGFloat videoTitleWidth = 102; //  34 * 3
    CGFloat leftOffset = ([UIScreen mainScreen].bounds.size.width - videoTitleWidth) / 2;
    _videoTitle = [[FHDetailVideoTitle alloc] initWithFrame:CGRectMake(leftOffset, 10, 102, 34)];
    [self addSubview:_videoTitle];
    
    _albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_albumBtn setTitle:@"全部图片" forState:UIControlStateNormal];
    [_albumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_albumBtn setFrame:CGRectMake(self.frame.size.width - 100, 10, 100, 34)];
    [_albumBtn addTarget:self action:@selector(albumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _albumBtn.hidden = YES;
    [self addSubview:_albumBtn];

    // 默认无视频
    self.hasVideo = NO;
}

- (void)setHasVideo:(BOOL)hasVideo {
    _hasVideo = hasVideo;
    _titleLabel.hidden = hasVideo;
    _videoTitle.hidden = !hasVideo;
}

- (void)setShowAlbum:(BOOL)showAlbum
{
    _showAlbum = showAlbum;
    self.albumBtn.hidden = !showAlbum;
}

- (void)albumBtnClick:(UIButton *)sender
{
    if (self.albumActionBlock) {
        self.albumActionBlock();
    }
}

- (void)backAction:(UIButton *)sender
{
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (UIImage *)backWhiteImage
{
    if (!_backWhiteImage) {
        _backWhiteImage = ICON_FONT_IMG(24,@"\U0000e68a",[UIColor whiteColor]);//@"detail_back_white";
    }
    return _backWhiteImage;
}


@end


// FHDetailVideoTitle

@interface FHDetailVideoTitle ()

@property (nonatomic, strong)   UIControl       *videoControl;// 视频
@property (nonatomic, strong)   UIControl       *picControl;// 图片
@property (nonatomic, strong)   UILabel       *videoLabel;// 视频
@property (nonatomic, strong)   UILabel       *picLabel;// 图片
@property (nonatomic, strong)   UIView       *bottomLine;

@end

@implementation FHDetailVideoTitle

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    _videoControl = [[UIControl alloc] initWithFrame:CGRectMake(2, 0, 35, 34)];
    _videoControl.tag = 1;
    [_videoControl addTarget:self action:@selector(controlTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_videoControl];
    
    _videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 35, 24)];
    _videoLabel.text = @"视频";
    _videoLabel.textAlignment = NSTextAlignmentCenter;
    _videoLabel.font = [UIFont themeFontMedium:17];
    _videoLabel.textColor = [UIColor whiteColor];
    [self addSubview:_videoLabel];
    
    _picControl = [[UIControl alloc] initWithFrame:CGRectMake(66, 0, 35, 34)];
    _picControl.tag = 2;
    [_picControl addTarget:self action:@selector(controlTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_picControl];
    
    _picLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 0, 35, 24)];
    _picLabel.text = @"图片";
    _picLabel.textAlignment = NSTextAlignmentCenter;
    _picLabel.font = [UIFont themeFontMedium:17];
    _picLabel.textColor = [UIColor themeGray3];
    [self addSubview:_picLabel];
    
    _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(9, 32, 20, 2)];
    _bottomLine.backgroundColor = [UIColor whiteColor];
    _bottomLine.layer.cornerRadius = 1;
    [self addSubview:_bottomLine];
    
    self.isSelectVideo = YES;
}

- (void)controlTap:(UIControl *)control {
    if (control) {
        if (control.tag == 1) {
            if (self.isSelectVideo) {
                return;
            }
            self.isSelectVideo = YES;
            // 回调业务
            if (self.currentTitleBlock) {
                self.currentTitleBlock(1);
            }
        } else if (control.tag == 2) {
            if (!self.isSelectVideo) {
                return;
            }
            self.isSelectVideo = NO;
            // 回调业务
            if (self.currentTitleBlock) {
                self.currentTitleBlock(2);
            }
        }
    }
}

- (void)setIsSelectVideo:(BOOL)isSelectVideo {
    _isSelectVideo = isSelectVideo;
    CGRect lineFrame = CGRectMake(9, 32, 20, 2);
    if (isSelectVideo) {
        // 视频
        _videoLabel.textColor = [UIColor whiteColor];
        _picLabel.textColor = [UIColor themeGray3];
        lineFrame = CGRectMake(9, 32, 20, 2);
    } else {
        // 图片
        _videoLabel.textColor = [UIColor themeGray3];
        _picLabel.textColor = [UIColor whiteColor];
        lineFrame = CGRectMake(73, 32, 20, 2);
    }
    [UIView animateWithDuration:0.35 animations:^{
        self.bottomLine.frame = lineFrame;
    } completion:^(BOOL finished) {
        
    }];
}

@end

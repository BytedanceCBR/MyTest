//
//  FHMultiMediaVideoCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaVideoCell.h"
#import "FHVideoViewController.h"
#import "FHVideoModel.h"
#import "UIImageView+BDWebImage.h"

@interface FHMultiMediaVideoCell ()

@property(nonatomic, strong) UIImageView *coverView;
@property(nonatomic, strong) UIButton *startBtn;
@property(nonatomic, strong) FHVideoViewController *videoVC;

@end

@implementation FHMultiMediaVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor blackColor];
    self.contentView.clipsToBounds = YES;

    self.videoVC = [[FHVideoViewController alloc] init];
    _videoVC.view.frame = self.bounds;
    [self.contentView addSubview:_videoVC.view];
    
    self.coverView = [[UIImageView alloc] initWithFrame:self.bounds];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_coverView];

    self.startBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 30, self.bounds.size.height/2 - 30, 60, 60)];
    [_startBtn setImage:[UIImage imageNamed:@"detail_video_start"] forState:UIControlStateNormal];
    [_startBtn setImage:[UIImage imageNamed:@"detail_video_start"] forState:UIControlStateHighlighted];
    [_startBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_startBtn];
}

- (void)updateViewModel:(FHMultiMediaItemModel *)model {
    
    FHVideoModel *videoModel = [[FHVideoModel alloc] init];
    videoModel.contentUrl = model.videoUrl;
    videoModel.muted = YES;
    videoModel.useCache = YES;
    videoModel.repeated = YES;
    videoModel.scalingMode = AWEVideoScaleModeAspectFit;
    videoModel.isShowMiniSlider = YES;
    
    [self.videoVC updateData:videoModel];
    
    NSString *imgStr = model.imageUrl;
    NSURL *url = [NSURL URLWithString:imgStr];
    [self.coverView bd_setImageWithURL:url placeholder:self.placeHolder];
}

- (void)playVideo {
    self.coverView.hidden = YES;
    self.startBtn.hidden = YES;
    [self play];
}

- (void)play {
    [self.videoVC play];
}

- (void)pause {
    [self.videoVC pause];
}

@end

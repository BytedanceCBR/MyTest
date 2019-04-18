//
//  FHVideoViewController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHVideoViewController.h"
#import "AWEVideoPlayerController.h"
#import "FHVideoView.h"
#import <Masonry.h>

@interface FHVideoViewController ()

@property(nonatomic, strong) AWEVideoPlayerController *playerController;
@property(nonatomic, strong) FHVideoView *videoView;
@property(nonatomic, strong) FHVideoModel *model;

@end

@implementation FHVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
    [self initConstaints];
}

- (void)initViews {
    self.videoView = [[FHVideoView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_videoView];
}

- (void)initConstaints {
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)updateData:(FHVideoModel *)model {
    self.model = model;
    [self.videoView updateData:model];
}

- (void)play {
    [self.videoView play];
}

@end

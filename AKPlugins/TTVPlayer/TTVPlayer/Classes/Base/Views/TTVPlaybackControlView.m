//
//  TTVPlaybackControlView.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/19.
//

#import "TTVPlaybackControlView.h"
#import "TTVPlayerNavigationBar.h"
#import "TTVPlayerBottomToolBar.h"

@implementation TTVPlaybackControlView

- (instancetype)initWithFrame:(CGRect)frame controlFactroy:(TTVPlayerControlViewFactory *)controlFactroy {
    self = [super initWithFrame:frame];
    if (self) {
        // 沉浸态的 view，默认是隐藏的
        self.immersiveContentView = [[TTVTouchIgoringView alloc] initWithFrame:frame];
        [self addSubview:self.immersiveContentView];
        self.immersiveContentView.hidden = YES;
        
        // 添加 contentView
        self.contentView = [[TTVTouchIgoringView alloc] initWithFrame:frame];
        [self addSubview:self.contentView];
        
        self.topBar = [controlFactroy createTopNavBar];
        [self addSubview:self.topBar];
        
        self.bottomBar = [controlFactroy createBottomToolBar];
        [self addSubview:self.bottomBar];

    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 沉浸态的 view，默认是隐藏的
        self.immersiveContentView = [[TTVTouchIgoringView alloc] initWithFrame:frame];
        [self addSubview:self.immersiveContentView];
        self.immersiveContentView.hidden = YES;
        
        // 添加 contentView
        self.contentView = [[TTVTouchIgoringView alloc] initWithFrame:frame];
        [self addSubview:self.contentView];
        
        self.topBar = [[TTVPlayerControlViewFactory sharedInstance] createTopNavBar];
        [self addSubview:self.topBar];
        
        self.bottomBar = [[TTVPlayerControlViewFactory sharedInstance] createBottomToolBar];
        [self addSubview:self.bottomBar];
    }
    return self;
}

- (void)layoutSubviews {
    self.contentView.frame = self.bounds;
    self.immersiveContentView.frame = self.bounds;
//    self.topBar.width = self.width;
//    self.bottomBar.width = self.width;
}

@end

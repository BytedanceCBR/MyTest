//
//  SSVideoPlayerViewController.m
//  Article
//
//  Created by Zhang Leonardo on 12-12-28.
//
//

#import "SSVideoPlayerViewController.h"
#import "ArticleTitleImageView.h"
#import "SSNavigationBar.h"

#import "SSVideoInnerController.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"

@interface SSVideoPlayerViewController ()<SSVideoPlayerViewDelegate, SSVideoInnerController>
{
    BOOL _hasPrepareToPlay;
}
@property(nonatomic, retain)SSNavigationBar * titleImageView;
@property(nonatomic, retain)SSVideoModel * videoModel;
@property(nonatomic, retain)SSVideoInnerController * playViewController;
@property(nonatomic, retain)UIView * nightModelView;

@end

@implementation SSVideoPlayerViewController

@synthesize playerView = _playerView;
@synthesize videoModel = _videoModel;
@synthesize playViewController = _playViewController;
@synthesize nightModelView = _nightModelView;

- (void)dealloc
{
    self.playViewController = nil;
    
    self.playerView.delegate = nil;
    
    self.playerView = nil;
    
    self.nightModelView = nil;
    self.titleImageView = nil;
    self.videoModel = nil;
}

- (id)initWithModel:(SSVideoModel *)model
{
    self = [super init];
    
    if (self) {
        self.videoModel = model;
        _controlViewPositionType = SSVideoPlayerViewControlViewBottom;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildViews];
	// Do any additional setup after loading the view.
}

- (void)buildViews
{
    self.view.backgroundColor = [UIColor blackColor];
    CGRect titleRect = CGRectMake(0, 0, self.view.width, [ArticleTitleImageView titleBarHeight]);
    
    self.titleImageView = [[SSNavigationBar alloc] initWithFrame:titleRect];
    [_titleImageView setTitle:@"视频"];
    self.titleImageView.leftBarView = [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(goBack:)];

    [self.view addSubview:_titleImageView];
    
    CGRect playViewRect = [self frameForPlayerView];
    self.playerView = [[SSVideoPlayerView alloc] initWithFrame:playViewRect type:VideoPlayerViewTypeHalfscreen];
    _playerView.video = _videoModel;
    _playerView.delegate = self;
    _playerView.controlViewPositionType = _controlViewPositionType;
    _playerView.backgroundColor = [UIColor blackColor];
    
    if ([TTDeviceHelper isPadDevice]) {
        _playerView.controlView.noFullScreenButtonFlag = YES;
    }
    
    playViewRect = [self frameForPlayerView];
    _playerView.frame = playViewRect;
    [self.view addSubview:_playerView];
    [self.view bringSubviewToFront:_titleImageView];
    
    self.nightModelView = [[UIView alloc] initWithFrame:self.view.bounds];
    _nightModelView.userInteractionEnabled = NO;
    _nightModelView.backgroundColor = [UIColor blackColor];
    _nightModelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _nightModelView.alpha = ([[TTThemeManager sharedInstance_tt] currentThemeMode] != TTThemeModeNight) ? 0.f : 0.5f;
    [self.view addSubview:_nightModelView];
    
    
//    [self performSelector:@selector(testPlayStatus) withObject:nil afterDelay:15];
}

//- (void)testPlayStatus
//{
//    if ([_playerView isCurrentPlayFailed]) {
//        [self playEndedAndExist];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_playerView didAppear];
    
    if (!_hasPrepareToPlay) {
        [_playerView prepareToPlay];
        _hasPrepareToPlay = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_playerView willAppear];
    
    [self refreshUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_playerView didDisappear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_playerView willDisappear];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self refreshUI];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([TTDeviceHelper isPadDevice]) {
        return YES;
    }
    else {
        return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (void)refreshUI
{
    _nightModelView.frame = self.view.bounds;
    _playerView.frame = [self frameForPlayerView];
    
    
}

#pragma mark -- titleBarTarget

- (void)goBack:(id)sender
{
    [self playEndedAndExist];
}

- (CGRect)frameForPlayerView
{
    if ([TTDeviceHelper isPadDevice]) {
        
        float externHeight = 0;
        float playerHeight = 0;
        float playerOriginY = 0;
        
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            _playerView.controlViewPositionType = _controlViewPositionType;
            
            if (_playerView.controlViewPositionType == SSVideoPlayerViewControlViewBottom) {
                externHeight += 44.f;
            }
            playerHeight = PlayerViewHalfScreenHeight + externHeight;
            playerOriginY = (CGRectGetHeight(self.view.frame) -  CGRectGetMaxY(_titleImageView.frame) - PlayerViewHalfScreenHeight - externHeight) / 2;
        
            
        }
        else {
            _playerView.controlViewPositionType = SSVideoPlayerViewControlViewInnerBottom;
            playerHeight = self.view.frame.size.height;
            playerOriginY = 0;
        }
        
        CGRect playViewRect = CGRectMake(0, playerOriginY, self.view.frame.size.width, playerHeight);
        return playViewRect;
    }
    
    float externHeight = 0;
    if (_playerView.controlViewPositionType == SSVideoPlayerViewControlViewBottom) {
        externHeight += 44.f;
    }
    
    CGRect playViewRect = CGRectMake(0, (CGRectGetHeight(self.view.frame) -  CGRectGetMaxY(_titleImageView.frame) - PlayerViewHalfScreenHeight - externHeight) / 2, self.view.frame.size.width, PlayerViewHalfScreenHeight + externHeight);

    return playViewRect;
}

- (void)playEndedAndExist
{
    if (_playViewController) {
        [_playViewController dismissViewControllerAnimated:NO completion:nil];
        self.playViewController = nil;
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -- SSVideoPlayerViewDelegate

- (void)videoPlayerViewPlayFailed:(SSVideoPlayerView *)playerView
{
    [self performSelector:@selector(playEndedAndExist) withObject:nil afterDelay:1.f];
}

- (void)videoPlayerView:(SSVideoPlayerView *)playerView didChangeFullscreen:(BOOL)fullscreen
{
    
    if ([TTDeviceHelper isPadDevice]) {
        
        return;
    }
    
    
    
    if (fullscreen) {
        
        _playerView.trackEventName = @"fullscreen_tab";
        _playerView.controlViewPositionType = SSVideoPlayerViewControlViewInnerBottom;
        SSVideoInnerController *control = [[SSVideoInnerController alloc] initWithPlayer:_playerView];
        control.delegate = self;
        self.playViewController = control;
        _playViewController.needDismiss = NO;
//        control.playerView = _playerView;
        
        UIViewController *topViewController = [SSCommonAppExtension topViewControllerFor: self];
        [topViewController.navigationController presentViewController:control animated:NO completion:nil];
        [_playerView resume];

    }
    else {
        [self dismissFullScreenPlayViewController];
    }
}

- (void)dismissFullScreenPlayViewController
{
    if (_playViewController) {
        _playerView.controlViewPositionType = SSVideoPlayerViewControlViewBottom;
        _playViewController.needDismiss = YES;
        [_playViewController dismissViewControllerAnimated:NO completion:nil];
        self.playViewController.delegate = nil;
        self.playViewController = nil;
        
        
        
        
    }
    
    _playerView.frame = [self frameForPlayerView];
    
    if ([_playerView superclass] != self.view) {
        [_playerView removeFromSuperview];
        [self.view addSubview:_playerView];
    }

    [_playerView refreshUI];
    
    [self.view bringSubviewToFront:_titleImageView];
    [self.view bringSubviewToFront:_nightModelView];
}

#pragma mark -- SSVideoInnerController videoPlayControllerBackButtonClicked

- (void)videoPlayControllerBackButtonClicked:(SSVideoInnerController *)controller
{
    if (controller == _playViewController) {
        [self dismissFullScreenPlayViewController];
    }
}

#pragma mark -- notification target

//- (void)themeChanged:(NSNotification*)notification
//{
//}

@end

//
//  TTVVideoDetailMovieBanner.m
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import "TTVVideoDetailMovieBanner.h"
#import "UIButton+SDAdapter.h"

@interface TTVVideoDetailMovieBanner ()

@property (nonatomic, strong) SSThemedButton *bannerButton;

@end

@implementation TTVVideoDetailMovieBanner

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bannerButton];
    }
    return self;
}

- (void)setViewModel:(id<TTVVideoDetailNatantVideoBannerDataProtocol>)viewModel
{
    if (_viewModel != viewModel) {
        _viewModel = viewModel;
        NSURL *url = [NSURL URLWithString:viewModel.iosOpenURL];
        _viewModel.appName = url.scheme;
        [self loadImage];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bannerButton.frame = self.bounds;
}

- (void)sendShowEvent
{
    TTVVideoDetailBannerType type = [self.viewModel getTTVideoBannerType];
    switch (type) {
        case TTVVideoDetailBannerTypeWebDetail:
        {
            if (self.viewModel.appName && self.groupID) {
                [TTTrackerWrapper eventV3:@"video_banner_player_show_h5page" params:@{@"app" : self.viewModel.appName, @"group_id": self.groupID}];
            }
        }
            break;
        case TTVVideoDetailBannerTypeOpenApp:
        {
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"player_show_jump", self.groupID, nil, @{@"app" : self.viewModel.appName});
            }
        }
            break;
        case TTVVideoDetailBannerTypeDownloadApp:
        {
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"player_show_download", self.groupID, nil, @{@"app" : self.viewModel.appName});
            }
        }
            break;
        default:
            break;
    }
}

- (void)bannerClicked
{
    TTVVideoDetailBannerType type = [self.viewModel getTTVideoBannerType];
    
    switch (type) {
        case TTVVideoDetailBannerTypeWebDetail:
        {
            [self.viewModel jumpToWebViewWithView:self];
            
            if (self.viewModel.appName && self.groupID) {
                [TTTrackerWrapper eventV3:@"video_banner_player_click_h5page" params:@{@"app" : self.viewModel.appName, @"group_id": self.groupID}];
            }
        }
            break;
        case TTVVideoDetailBannerTypeOpenApp:
        {
            [self.viewModel jumpToOtherApp];
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"player_click_jump", self.groupID, nil, @{@"app" : self.viewModel.appName});
            }
        }
            break;
        case TTVVideoDetailBannerTypeDownloadApp:
        {
            [self.viewModel jumpToAppstore];
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"player_click_download", self.groupID, nil, @{@"app" : self.viewModel.appName});
            }
        }
            break;
        default:
            break;
    }
}

- (void)loadImage
{
    NSString *url = nil;
    TTVVideoDetailBannerType type = [self.viewModel getTTVideoBannerType];
    if (TTVVideoDetailBannerTypeWebDetail == type || TTVVideoDetailBannerTypeOpenApp == type) {
        url = self.viewModel.inBannerOpenImgURL;
    } else {
        url = self.viewModel.inBannerDownloadImgURL;
    }
    
    __weak typeof(self) wself = self;
    [self.bannerButton sda_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong typeof(wself) self = wself;
        if (image) {
            CGFloat scale;
            if (image.size.width ==0 || image.size.height == 0) {
                scale = 1;
            } else {
                scale = image.size.width / image.size.height;
            }
            self.height = floor(self.width / scale);
            if (self.delegate && [self.delegate respondsToSelector:@selector(didLoadImage:)]) {
                [self.delegate didLoadImage:self];
            }
        }
    }];
}

- (SSThemedButton *)bannerButton
{
    if (!_bannerButton) {
        _bannerButton = [[SSThemedButton alloc] init];
        _bannerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _bannerButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [_bannerButton addTarget:self action:@selector(bannerClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bannerButton;
}

@end

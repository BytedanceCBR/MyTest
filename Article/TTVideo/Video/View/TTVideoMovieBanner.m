//
//  TTVideoMovieBanner.m
//  Article
//
//  Created by 刘廷勇 on 16/4/20.
//
//

#import "TTVideoMovieBanner.h"
#import "SSThemed.h"
#import "UIButton+SDAdapter.h"


@interface TTVideoMovieBanner ()

@property (nonatomic, strong) SSThemedButton *bannerButton;

@end

@implementation TTVideoMovieBanner

- (nullable id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bannerButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bannerButton.frame = self.bounds;
}

- (void)sendShowEvent
{
    TTVideoBannerType type = [self.viewModel getTTVideoBannerType];
    switch (type) {
        case TTVideoBannerTypeWebDetail:
        {
            if (self.viewModel.appName && self.groupID) {
                [TTTrackerWrapper eventV3:@"video_banner_player_show_h5page" params:@{@"app" : self.viewModel.appName, @"group_id": self.groupID}];
            }
        }
            break;
        case TTVideoBannerTypeOpenApp:
        {
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"player_show_jump", self.groupID, nil, @{@"app" : self.viewModel.appName});
            }
        }
            break;
        case TTVideoBannerTypeDownloadApp:
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
    TTVideoBannerType type = [self.viewModel getTTVideoBannerType];
    
    switch (type) {
        case TTVideoBannerTypeWebDetail:
        {
            [self.viewModel jumpToWebViewWithView:self];
            
            if (self.viewModel.appName && self.groupID) {
                [TTTrackerWrapper eventV3:@"video_banner_player_click_h5page" params:@{@"app" : self.viewModel.appName, @"group_id": self.groupID}];
            }
        }
            break;
        case TTVideoBannerTypeOpenApp:
        {
            [self.viewModel jumpToOtherApp];
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"player_click_jump", self.groupID, nil, @{@"app" : self.viewModel.appName});
            }
        }
            break;
        case TTVideoBannerTypeDownloadApp:
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
    TTVideoBannerType type = [self.viewModel getTTVideoBannerType];
    if (TTVideoBannerTypeWebDetail == type || TTVideoBannerTypeOpenApp == type) {
        url = self.viewModel.inOpenImgURL;
    } else {
        url = self.viewModel.inDownloadImgURL;
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

- (void)setViewModel:(TTVideoBannerModel *)viewModel
{
    if (_viewModel != viewModel) {
        _viewModel = viewModel;
        NSURL *url = [NSURL URLWithString:viewModel.openURL];
        _viewModel.appName = url.scheme;
        [self loadImage];
    }
}

@end

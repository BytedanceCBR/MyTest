//
//  TTDetailNatantVideoBanner.m
//  Article
//
//  Created by 刘廷勇 on 16/4/20.
//
//

#import "TTDetailNatantVideoBanner.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+SDAdapter.h"
#import "TTTrackerWrapper.h"


@interface TTDetailNatantVideoBanner ()

@property (nonatomic, strong, nullable) TTAlphaThemedButton *bannerButton;

@end

@implementation TTDetailNatantVideoBanner

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bannerButton];
    }
    return self;
}

- (void)bannerClicked
{
    TTVideoBannerType type = [self.viewModel getTTVideoBannerType];
    
    switch (type) {
        case TTVideoBannerTypeWebDetail:
        {
            [self.viewModel jumpToWebViewWithView:self];
            
            if (self.viewModel.appName && self.groupID) {
                [TTTrackerWrapper eventV3:@"video_banner_subscribe_click_h5page" params:@{@"app" : self.viewModel.appName, @"group_id": self.groupID}];
            }
        }
            break;
        case TTVideoBannerTypeOpenApp:
        {
            [self.viewModel jumpToOtherApp];
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"subscribe_click_jump", self.groupID, nil, @{@"app" : self.viewModel.appName});
            }
        }
            break;
        case TTVideoBannerTypeDownloadApp:
        {
            [self.viewModel jumpToAppstore];
            if (self.viewModel.appName) {
                wrapperTrackEventWithCustomKeys(@"video_banner", @"subscribe_click_download", self.groupID, nil, @{@"app" : self.viewModel.appName});
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
        url = self.viewModel.belowOpenImgURL;
    } else {
        url = self.viewModel.belowDownloadImgURL;
    }
    
    __weak typeof(self) wself = self;
    [self.bannerButton sda_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong typeof(wself) self = wself;
        if (image) {
            CGFloat scale;
            if (image.size.width == 0 || image.size.height == 0) {
                scale = 1;
            } else {
                scale = image.size.width / image.size.height;
            }
            CGFloat horizontalInset = self.edgeInsets.left + self.edgeInsets.right;
            CGFloat verticalInset = self.edgeInsets.top + self.edgeInsets.bottom;
            
            self.bannerButton.left = self.edgeInsets.left;
            self.bannerButton.top = self.edgeInsets.top;
            self.bannerButton.width = self.width - horizontalInset;
            self.bannerButton.height = floor(self.bannerButton.width / scale);
            
            self.height = self.bannerButton.height + verticalInset;
            if (self.relayOutBlock) {
                self.relayOutBlock(YES);
            }
        }
    }];
}

- (TTAlphaThemedButton *)bannerButton
{
    if (!_bannerButton) {
        _bannerButton = [[TTAlphaThemedButton alloc] init];
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

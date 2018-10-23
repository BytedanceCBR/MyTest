//
//  TTVVideoDetailNatantVideoBanner.m
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import "TTVVideoDetailNatantVideoBanner.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+SDAdapter.h"

@interface TTVVideoDetailNatantVideoBanner ()

@property (nonatomic, strong, nullable) TTAlphaThemedButton *bannerButton;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation TTVVideoDetailNatantVideoBanner

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _edgeInsets = UIEdgeInsetsMake(9, 0, 12, 0);
        _bannerButton = [[TTAlphaThemedButton alloc] init];
        _bannerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _bannerButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [_bannerButton addTarget:self action:@selector(bannerClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bannerButton];
    }
    return self;
}

- (void)setViewModel:(id<TTVVideoDetailNatantVideoBannerDataProtocol> )viewModel
{
    if (_viewModel != viewModel) {
        _viewModel = viewModel;
        NSURL *url = [NSURL URLWithString:viewModel.iosOpenURL];
        _viewModel.appName = url.scheme;
        [self loadImage];
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
        url = self.viewModel.belowBannerOpenImgURL;
    } else {
        url = self.viewModel.belowBannerDownloadImgURL;
    }
    @weakify(self);
    [self.bannerButton sda_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
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
            [self setNeedsLayout];
        }
    }];
}

@end

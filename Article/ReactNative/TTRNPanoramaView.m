//
//  TTRNPanoramaView.m
//  Article
//
//  Created by yin on 2017/1/22.
//
//

#import "RCTConvert.h"
#import "SSSimpleCache.h"
#import "TTImageView.h"
#import "TTMotionView.h"
#import "TTRNPanoramaView.h"
#import "UIImage+MultiFormat.h"
#import "TTAdCanvasManager.h"

@interface TTRNPanoramaView ()<TTMotionViewDelegate>

@property (nonatomic, strong) TTMotionView * motionView;
@property (nonatomic, assign) BOOL hasTrack;

@end

@implementation TTRNPanoramaView

- (instancetype)init
{
    if ((self = [super init])) {
        super.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.hasTrack = NO;
        self.motionView = [[TTMotionView alloc] init];
        self.enable = NO;
        self.motionView.delegate = self;
        [self.motionView setMotionEnabled:NO];
        [self.motionView setScrollBounceEnabled:NO];
        [self addSubview:self.motionView];
    }
    return self;
}

- (void)setEnable:(BOOL)enable
{
    if (_enable != enable) {
        _enable = enable;
        if (_enable == YES) {
            [self.motionView setMotionEnabled:YES];
            _hasTrack = NO;
        }
        else
        {
            [self.motionView setMotionEnabled:NO];
        }
    }
}

- (void)setSource:(NSDictionary *)source
{
    if (![_source isEqualToDictionary:source]) {
        _source = [source copy];
        
        NSDictionary *source = _source;
        NSString *url = [RCTConvert NSString:source[@"uri"]];
        NSString *tagUri = [RCTConvert NSString:source[@"tag"]];
        
        UIImage *cachedImage = nil;
        if (!isEmptyString(tagUri) && [[SSSimpleCache sharedCache] isCacheExist:tagUri]) {
            cachedImage = [UIImage sd_imageWithData:[[SSSimpleCache sharedCache] dataForUrl:tagUri]];
        } else if ([[SSSimpleCache sharedCache] isCacheExist:url]) {
            cachedImage = [UIImage sd_imageWithData:[[SSSimpleCache sharedCache] dataForUrl:url]];
        }
        
        if (cachedImage) {
            [self.motionView setImage:cachedImage];
        } else {
            if ([url hasPrefix:@"http://"]) {
                NSString *placeholder = [RCTConvert NSString:source[@"default_uri"]];
                TTImageView *imageView = [[TTImageView alloc] init];
                [imageView setImageWithURLString:url placeholderImage:[UIImage imageNamed:placeholder] options:0 success:^(UIImage *image, BOOL cached) {
                    [self.motionView setImage:image];
                } failure:^(NSError *error) {}];
            } else {
                [self.motionView setImage:[UIImage imageNamed:url]];
            }
        }
    }
}

- (void)motionViewScrollViewDidScrollToOffset:(CGPoint)offset
{
    if (_enable == YES) {
        if (_hasTrack == NO) {
            [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"slide_scene" dict:nil];
            _hasTrack = YES;
        }
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.motionView.frame = self.bounds;
    
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
}

- (void)dealloc
{
    self.motionView.delegate = nil;
    [self.motionView.displayLink invalidate];
    self.motionView.displayLink = nil;
    self.motionView = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

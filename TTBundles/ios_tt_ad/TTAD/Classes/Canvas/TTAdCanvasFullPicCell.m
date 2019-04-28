//
//  TTAdCanvasFullPicView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "TTAdCanvasFullPicCell.h"
#import "UIImage+MultiFormat.h"
#import "TTMotionView.h"
#import "SSSimpleCache.h"
#import "TTImageView.h"
#import "TTAdManager.h"

@interface TTAdCanvasFullPicCell ()<TTMotionViewDelegate>

@property (nonatomic, strong) TTMotionView * motionView;
@property (nonatomic, assign) BOOL hasTrack;

@end

@implementation TTAdCanvasFullPicCell

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.hasTrack = NO;
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    self.motionView = [[TTMotionView alloc] init];
    self.motionView.delegate = self;
    [self.motionView setMotionEnabled:NO];
    [self.motionView setScrollBounceEnabled:NO];
    [self addSubview:self.motionView];
}


- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithURL:model.data.imgsrc];
    if (!isEmptyString(model.data.imgsrc)&&[[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel]) {
        UIImage* image = [UIImage sd_imageWithData:[[SSSimpleCache sharedCache] dataForImageInfosModel:imageModel]];
        [self.motionView setImage:image];
    }
    else{
        if ([model.data.imgsrc hasPrefix:@"http://"]) {
            TTImageView *imageView = [[TTImageView alloc] init];
            [imageView setImageWithURLString:model.data.imgsrc placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
                [self.motionView setImage:image];
            } failure:^(NSError *error) {}];
        } else {
            [self.motionView setImage:[UIImage imageNamed:model.data.imgsrc]];
        }
    }
}

- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    switch (showStatus) {
        case TTAdCanvasItemShowStatus_WillDisplay:
        {
            [self trackShow];
        }
            break;
        case TTAdCanvasItemShowStatus_DidEndDisplay:
        {
            [self.motionView setMotionEnabled:NO];
            [self.motionView resetContentOffset];
            self.hasTrack = NO;
        }
            break;
        default:
            break;
    }
}


- (void)cellAnimateToTop
{
    [self.motionView setMotionEnabled:YES];
}

- (void)motionViewScrollViewDidScrollToOffset:(CGPoint)offset
{
    if (self.hasTrack == NO && self.motionView.motionEnabled == YES) {
        [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"slide_scene" dict:nil];
        self.hasTrack = YES;
    }
}

- (void)trackShow
{
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_fullview" dict:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.motionView.frame = self.bounds;
    
}

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)width
{
    return [UIScreen mainScreen].bounds.size.height;
}

- (void)dealloc
{
    self.motionView.delegate = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

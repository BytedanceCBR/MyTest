//
//  TTAdCanvasLoopPicView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "TTAdCanvasLoopPicCell.h"
#import "TTImageView.h"
#import "SSSimpleCache.h"
#import "UIImage+MultiFormat.h"
#import "TTAdCanvasManager.h"

@interface TTAdCanvasLoopPicCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) NSMutableArray* imageArray;

@end

@implementation TTAdCanvasLoopPicCell


- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.imageArray = [NSMutableArray array];
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:self.pageControl];
}

- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    NSArray* imageArray = model.data.imgs;
    if (SSIsEmptyArray(imageArray)) {
        return;
    }
    
    self.pageControl.numberOfPages = imageArray.count;
    self.pageControl.currentPage = 0;
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* imageUrl = (NSString*)obj;
        if (!isEmptyString(imageUrl)) {
            TTImageView* imageView = [[TTImageView alloc] init];
            
            [self.scrollView addSubview:imageView];
            [self.imageArray addObject:imageView];
            
            TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithURL:imageUrl];
            if ([[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel]) {
                imageView.image = [UIImage sd_imageWithData:[[SSSimpleCache sharedCache]dataForImageInfosModel:imageModel]];
            }
            else{
                if ([imageUrl hasPrefix:@"http://"]) {
                    [imageView setImageWithURLString:imageUrl];
                } else {
                    [imageView setImage:[UIImage imageNamed:imageUrl]];
                }
            }
        }
    }];
}


- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    switch (showStatus) {
        case TTAdCanvasItemShowStatus_WillDisplay:
            [self trackShow];
            break;
        
        default:
            break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.pageControl.currentPage != self.scrollView.contentOffset.x/self.width) {
        self.pageControl.currentPage = self.scrollView.contentOffset.x/self.width;
        [self trackSwitch];
    }
}

- (void)trackShow
{
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_pics" dict:nil];
}

- (void)trackSwitch
{
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"switch_pics" dict:nil];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.width * self.imageArray.count, self.height);
    self.pageControl.center = CGPointMake(self.scrollView.center.x, self.scrollView.frame.size.height - tt(15));
    [self.imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTImageView* imageView = (TTImageView*)obj;
        if (imageView && [imageView isKindOfClass:[TTImageView class]]) {
            imageView.frame = CGRectMake(idx * self.width, 0, self.width, self.height);
        }
    }];
}

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)constraintWidth
{
    return [super heightForModel:model inWidth:constraintWidth];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

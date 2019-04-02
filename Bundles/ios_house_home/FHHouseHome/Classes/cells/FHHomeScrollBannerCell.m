//
//  FHHomeScrollBannerCell.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/4/2.
//

#import "FHHomeScrollBannerCell.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIImageView+BDWebImage.h"
#import "FHUtils.h"

static CGFloat kFHScrollBannerTopMargin = 10;
static CGFloat kFHScrollBannerHeight = 58.0; // 轮播图的高度

@interface FHHomeScrollBannerCell ()

@property (nonatomic, strong)   FHHomeScrollBannerView       *bannerView;

@end

@implementation FHHomeScrollBannerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [FHHomeScrollBannerCell cellHeight];
        [self setupUI];
    }
    return self;
}

+ (CGFloat)cellHeight {
    kFHScrollBannerHeight = 58.0;
    kFHScrollBannerHeight = ([UIScreen mainScreen].bounds.size.width - 40) / 335.0f * kFHScrollBannerHeight;
    return kFHScrollBannerHeight + kFHScrollBannerTopMargin * 2;
}

- (void)setupUI {
    _bannerView = [[FHHomeScrollBannerView alloc] init];
    _bannerView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_bannerView];
    [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.contentView);// 下面的降价房cell之前布局有问题
        make.height.mas_equalTo(kFHScrollBannerHeight);
    }];
}

@end


// FHHomeScrollBannerView
@interface FHHomeScrollBannerView ()<UIScrollViewDelegate>

@property (nonatomic, strong)   FHBannerScrollView       *bannerScrollView;
@property (nonatomic, assign)   NSInteger       currentIndex;
@property (nonatomic, assign)   NSInteger       totalCount;
@property (nonatomic, strong)   NSMutableArray       *imageURLs;
@property (nonatomic, assign)   CGFloat       imageWidth;
@property (nonatomic, assign)   CGFloat       imageHeight;
@property (nonatomic, assign)   NSTimeInterval       timeDuration;
@property (nonatomic, strong)   NSTimer       *timer;
@property (nonatomic, assign)   BOOL       enableTimer;
@property (nonatomic, weak)     id<FHBannerViewIndexProtocol>      delegate;
@property (nonatomic, strong)   FHBannerIndexView       *indexView;
@property (nonatomic, assign)   CGFloat       indexViewSize;
@property (nonatomic, strong)   UITapGestureRecognizer       *tapGes;

@end

@implementation FHHomeScrollBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _currentIndex = 0;
        _totalCount = 0;
        _imageURLs = [NSMutableArray new];
        _imageWidth = [UIScreen mainScreen].bounds.size.width - 40;
        _imageHeight = kFHScrollBannerHeight;
        _enableTimer = YES;
        _timeDuration = 3.0;
        _indexViewSize = 5;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _bannerScrollView = [[FHBannerScrollView alloc] init];
    [self addSubview:_bannerScrollView];
    _bannerScrollView.delegate = self;
    _indexView = [[FHBannerIndexView alloc] init];
    [self addSubview:_indexView];
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];;
    [self addGestureRecognizer:_tapGes];
}

- (void)setTimeDuration:(NSTimeInterval)timeDuration {
    _timeDuration = timeDuration;
}

// 必须调用的方法
- (void)setContent:(CGFloat)wid height:(CGFloat)hei {
    self.imageWidth = wid;
    self.imageHeight = hei;
    self.bannerScrollView.frame = CGRectMake(0, 0, wid, hei);
    [self.bannerScrollView setContent:wid height:hei];
    [self updateIndexViewFrame];
}

// 设置图片
- (void)setURLs:(NSArray *)urls {
    if (urls.count > 0) {
        self.currentIndex = 0;
        self.totalCount = urls.count;
        [self.imageURLs removeAllObjects];
        [self.imageURLs addObjectsFromArray:urls];
        [self.indexView setIndexCount:self.totalCount size:self.indexViewSize];
        [self updateIndexViewFrame];
        if (self.totalCount == 1) {
            [self.bannerScrollView setLeftImage:self.imageURLs[0]];
            self.bannerScrollView.scrollEnabled = NO;
            self.indexView.hidden = YES;
        } else {
            self.indexView.hidden = NO;
            self.bannerScrollView.scrollEnabled = YES;
            [self changeCurrentImageToMid];
            [self addTimer];
        }
    }
}

// 调整当前显示的图片位置为中间位置
- (void)changeCurrentImageToMid {
    [self adjustCurrentIndex];
    if (self.currentIndex < 0 || self.currentIndex >= self.totalCount) {
        return;
    }
    if (self.totalCount <= 0) {
        return;
    }
    if (self.totalCount != self.imageURLs.count) {
        return;
    }
    // 计算各个imageView应该展示的图片
    NSInteger leftIndex = self.currentIndex > 0 ? self.currentIndex - 1 : self.totalCount-1;
    NSInteger midIndex = self.currentIndex;
    NSInteger rightIndex = self.currentIndex + 1 >= self.totalCount ? 0 : self.currentIndex + 1;
    // 交换位置
    [self.bannerScrollView setMidImage:self.imageURLs[midIndex]];
    [self.bannerScrollView setContentOffset:CGPointMake(self.bannerScrollView.frame.size.width, 0) animated:NO];
    [self.bannerScrollView setLeftImage: self.imageURLs[leftIndex]];
    [self.bannerScrollView setRightImage: self.imageURLs[rightIndex]];
    if (self.delegate != nil) {
        [self.delegate currentIndexChanged:self.currentIndex];
    }
    [self.indexView setCurrentIndex:self.currentIndex];
}

// 调整当前的索引
- (void)adjustCurrentIndex {
    if (self.totalCount <= 0) {
        return;
    }
    if (self.currentIndex < 0) {
        self.currentIndex = self.totalCount - 1;
    }
    if (self.currentIndex >= self.totalCount) {
        self.currentIndex = 0;
    }
    self.currentIndex = self.currentIndex % self.totalCount;
}

- (void)scrollViewEnd:(UIScrollView *)scrollView {
    NSInteger tempIndex = scrollView.contentOffset.x / self.imageWidth;
    if (tempIndex != 1) {
        if (tempIndex == 0) {
            self.currentIndex -= 1;
        }
        if (tempIndex == 2) {
            self.currentIndex += 1;
        }
        [self changeCurrentImageToMid];
    }
}

- (void)updateIndexViewFrame {
    CGFloat wid = self.totalCount * (self.indexViewSize + 7) - 7 + 1;
    CGFloat hei = 6 + self.indexViewSize;
    self.indexView.frame = CGRectMake((self.imageWidth - wid) / 2, self.imageHeight - hei, wid, hei);
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    if (self.delegate != nil) {
        if (self.currentIndex >= 0 && self.currentIndex < self.totalCount) {
            [self.delegate clickBannerWithIndex:self.currentIndex];
        }
    }
}

- (void)timerRun {
     [self.bannerScrollView setContentOffset:CGPointMake(self.bannerScrollView.frame.size.width * 2, 0) animated:YES];
}

- (void)addTimer {
    if (!self.enableTimer) {
        return;
    }
    if (self.timer != nil) {
        return;
    }
    self.timer = [NSTimer timerWithTimeInterval:self.timeDuration target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dealloc
{
    [self removeGestureRecognizer:_tapGes];
}
// scrollViewWillBeginDragging
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewEnd:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewEnd:scrollView];
}

@end

// FHBannerScrollView

@interface FHBannerScrollView ()

@property (nonatomic, strong)   UIImageView       *imageViewLeft;
@property (nonatomic, strong)   UIImageView       *imageViewMid;
@property (nonatomic, strong)   UIImageView       *imageViewRight;
@property (nonatomic, assign)   CGFloat       imageWidth;
@property (nonatomic, assign)   CGFloat       imageHight;
@property (nonatomic, strong)   UIImage       *placeholderImage;

@end

@implementation FHBannerScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageWidth = [UIScreen mainScreen].bounds.size.width;
        _imageHight = [UIScreen mainScreen].bounds.size.height;
        _imageViewLeft = [UIImageView new];
        _imageViewMid = [UIImageView new];
        _imageViewRight = [UIImageView new];
        self.backgroundColor = [UIColor whiteColor];
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        UIColor *color = [UIColor themeGray6];
        self.placeholderImage = [FHUtils createImageWithColor:color];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:_imageViewLeft];
    [self addSubview:_imageViewMid];
    [self addSubview:_imageViewRight];
    [self needsUpdateConstraints];
}

- (void)setLeftImage:(NSString *)url {
    if (url.length > 0) {
         [self.imageViewLeft bd_setImageWithURL:[NSURL URLWithString:url] placeholder:self.placeholderImage];
    }
}

- (void)setMidImage:(NSString *)url {
    if (url.length > 0) {
        [self.imageViewMid bd_setImageWithURL:[NSURL URLWithString:url] placeholder:self.placeholderImage];
    }
}

- (void)setRightImage:(NSString *)url {
    if (url.length > 0) {
        [self.imageViewRight bd_setImageWithURL:[NSURL URLWithString:url] placeholder:self.placeholderImage];
    }
}

- (void)setContent:(CGFloat)wid height:(CGFloat)hei {
    self.imageWidth = wid;
    self.imageHight = hei;
    self.imageViewLeft.frame = CGRectMake(0, 0, _imageWidth, _imageHight);
    self.imageViewMid.frame = CGRectMake(_imageWidth, 0, _imageWidth, _imageHight);
    self.imageViewRight.frame = CGRectMake(_imageWidth * 2, 0, _imageWidth, _imageHight);
    self.contentSize = CGSizeMake(_imageWidth * 3, _imageHight);
    [self needsUpdateConstraints];
}

@end

// FHBannerIndexView
// 高度11=5+6，间距=7
@interface FHBannerIndexView ()

@property (nonatomic, assign)   CGFloat       indexSize;
@property (nonatomic, assign)   NSInteger       indexCount;
@property (nonatomic, strong)   NSMutableArray       *viewArrays;
@property (nonatomic, weak)     UIView       *lastView;

@end

@implementation FHBannerIndexView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _indexSize = 5.0;
        _indexCount = 0;
        _viewArrays = [NSMutableArray new];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// size = 5.0
- (void)setIndexCount:(NSInteger)count size:(CGFloat)size {
    self.indexCount = count;
    self.indexSize = size;
    if (self.viewArrays.count > 0) {
        for (UIView *v in _viewArrays) {
            [v removeFromSuperview];
        }
        [_viewArrays removeAllObjects];
    }
    CGFloat tempOffset = 0;
    for (int i = 0; i < _indexCount; i++) {
        UIView *tempV = [[UIView alloc] initWithFrame:CGRectMake(tempOffset, 0, _indexSize, _indexSize)];
        tempV.layer.cornerRadius = _indexSize / 2;
        tempV.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.6];
        [self addSubview:tempV];
        [self.viewArrays addObject:tempV];
        tempOffset += (_indexSize + 7);
    }
}

- (void)setViewSelect:(UIView *)v {
    if (v) {
        v.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.0];
    }
}

- (void)setViewUnSelect:(UIView *)v {
    if (v) {
        v.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.6];
    }
}

- (void)setCurrentIndex:(NSInteger)index {
    if (index >= 0 && index < self.viewArrays.count) {
        [self setViewUnSelect:_lastView];
        [self setViewSelect:self.viewArrays[index]];
        _lastView = self.viewArrays[index];
    }
}

@end

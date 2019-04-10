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
#import "FHUserTracker.h"
#import "TTRoute.h"
#import "FHHomeCellHelper.h"

static CGFloat kFHScrollBannerTopMargin = 10;
static CGFloat kFHScrollBannerHeight = 58.0; // 轮播图的高度

@interface FHHomeScrollBannerCell ()<FHBannerViewIndexProtocol>

@property (nonatomic, strong)   FHConfigDataMainPageBannerOpDataModel       *model;
@property (nonatomic, strong)   NSMutableDictionary       *tracerDic;

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
    _tracerDic = [NSMutableDictionary new];
    _bannerView = [[FHHomeScrollBannerView alloc] init];
    _bannerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_bannerView];
    [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.contentView);// 下面的降价房cell之前布局有问题
        make.height.mas_equalTo(kFHScrollBannerHeight);
    }];
    _bannerView.delegate = self;
    [_bannerView setContent:[UIScreen mainScreen].bounds.size.width - 40 height:kFHScrollBannerHeight];
}

// 注意cell的刷新频率问题
-(void)updateWithModel:(FHConfigDataMainPageBannerOpDataModel *)model {
    if ([FHHomeCellHelper sharedInstance].fhLastHomeScrollBannerCell) {
        // 移除之前banner的定时器
        [[FHHomeCellHelper sharedInstance].fhLastHomeScrollBannerCell.bannerView removeTimer];
    }
    [FHHomeCellHelper sharedInstance].fhLastHomeScrollBannerCell = self;
    _model = model;
    // 获取图片数据数组
    NSMutableArray *opDatas = [[NSMutableArray alloc] init];
    NSMutableArray *imageUrls = [NSMutableArray new];
    for (int i = 0; i < model.items.count; i++) {
        FHConfigDataRentOpDataItemsModel *opData = model.items[i];
        if (opData.image.count > 0) {
            FHConfigDataRentOpDataItemsImageModel *opImage = opData.image[0];
            if (opImage.url.length > 0) {
                [imageUrls addObject:opImage.url];
                [opDatas addObject:opData];
            }
        }
    }
    [_bannerView setURLs:imageUrls];
    [self.tracerDic removeAllObjects];
}

- (void)addTracerShow:(FHConfigDataRentOpDataItemsModel *)opData index:(NSInteger)index {
    NSString *opId = opData.id;
    if (opId.length > 0) {
        if (self.tracerDic[opId]) {
            return;
        }
        self.tracerDic[opId] = @(1);
    } else {
        opId = @"be_null";
    }
    // 添加埋点
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"page_type"] = @"maintab";
    params[@"enter_from"] = @"maintab_ad";
    params[@"rank"] = @(index);
    params[@"item_id"] = opId;
    params[@"item_title"] = opData.title.length > 0 ? opData.title : @"be_null";
    params[@"description"] = opData.descriptionStr.length > 0 ? opData.descriptionStr : @"be_null";
    NSString *origin_from = @"be_null";
    if (opData.logPb && [opData.logPb isKindOfClass:[NSDictionary class]]) {
        origin_from = opData.logPb[@"origin_from"];
    }
    params[@"origin_from"] = origin_from;
  
    [FHUserTracker writeEvent:@"banner_show" params:params];
}

- (void)clickBanner:(FHConfigDataRentOpDataItemsModel *)opData index:(NSInteger)index  {
    NSString *opId = opData.id;
    if (opId.length > 0) {
    } else {
        opId = @"be_null";
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"page_type"] = @"maintab";
    params[@"enter_from"] = @"maintab_ad";
    params[@"rank"] = @(index);
    params[@"item_id"] = opId;
    params[@"item_title"] = opData.title.length > 0 ? opData.title : @"be_null";
    params[@"description"] = opData.descriptionStr.length > 0 ? opData.descriptionStr : @"be_null";
    NSString *origin_from = @"be_null";
    if (opData.logPb && [opData.logPb isKindOfClass:[NSDictionary class]]) {
        origin_from = opData.logPb[@"origin_from"];
    }
    params[@"origin_from"] = origin_from;
    
    [FHUserTracker writeEvent:@"banner_click" params:params];
    
    // 页面跳转，origin_from：服务端下方，如果进入到房源相关页面需要透传
    if (opData.openUrl.length > 0) {
        NSMutableDictionary *trace_params = [NSMutableDictionary new];
        trace_params[@"origin_from"] = origin_from;
        trace_params[@"enter_from"] = @"maintab_ad";
        
        NSDictionary *infoDict = @{@"tracer":trace_params};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        NSMutableString *openUrl = [[NSMutableString alloc] initWithString:opData.openUrl];
        NSURL *url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

#pragma mark - FHBannerViewIndexProtocol

- (void)currentIndexChanged:(NSInteger)currentIndex {
    if (currentIndex >= 0 && currentIndex < self.model.items.count) {
        FHConfigDataRentOpDataItemsModel *opData = self.model.items[currentIndex];
        [self addTracerShow:opData index:currentIndex];
    }
}
- (void)clickBannerWithIndex:(NSInteger)currentIndex {
    if (currentIndex >= 0 && currentIndex < self.model.items.count) {
        FHConfigDataRentOpDataItemsModel *opData = self.model.items[currentIndex];
        [self clickBanner:opData index:currentIndex];
    }
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
@property (nonatomic, assign)   BOOL       hasPausedTimer;
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
        _hasPausedTimer = NO;
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
    self.hasPausedTimer = NO;
    [self removeTimer];
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
            if (self.delegate != nil) {
                [self.delegate currentIndexChanged:self.currentIndex];
            }
        } else {
            self.indexView.hidden = NO;
            self.bannerScrollView.scrollEnabled = YES;
            [self changeCurrentImageToMid];
            [self addTimer];
        }
    } else {
        self.bannerScrollView.scrollEnabled = NO;
        self.indexView.hidden = YES;
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
    if (self.totalCount <= 1) {
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

// 重启定时器
- (void)resetTimer {
    if (!self.enableTimer) {
        return;
    }
    if (self.timer == nil) {
        return;
    }
    if (self.totalCount <= 1) {
        return;
    }
    // 是暂停了定时器
    if (self.hasPausedTimer) {
        [self.timer setFireDate:[NSDate distantPast]];
        self.hasPausedTimer = NO;
    }
}

// 暂停定时器
- (void)pauseTimer {
    if (!self.enableTimer) {
        return;
    }
    if (self.timer != nil) {
        [self.timer setFireDate:[NSDate distantFuture]];
        self.hasPausedTimer = YES;
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
        // _imageViewLeft.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewMid = [UIImageView new];
        // _imageViewMid.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewRight = [UIImageView new];
        // _imageViewRight.contentMode = UIViewContentModeScaleAspectFill;
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

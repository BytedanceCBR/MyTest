//
//  FHHomeScrollBannerCell.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/4/2.
//

#import "FHHomeScrollBannerCell.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"

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
@interface FHHomeScrollBannerView ()

@end

@implementation FHHomeScrollBannerView



@end

// FHBannerScrollView

@interface FHBannerScrollView ()

@property (nonatomic, strong)   UIImageView       *imageViewLeft;
@property (nonatomic, strong)   UIImageView       *imageViewMid;
@property (nonatomic, strong)   UIImageView       *imageViewRight;
@property (nonatomic, assign)   CGFloat       imageWidth;
@property (nonatomic, assign)   CGFloat       imageHight;

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

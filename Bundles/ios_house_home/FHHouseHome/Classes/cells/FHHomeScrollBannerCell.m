//
//  FHHomeScrollBannerCell.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/4/2.
//

#import "FHHomeScrollBannerCell.h"

static CGFloat kFHScrollBannerTopMargin = 10.5;
static CGFloat kFHScrollBannerHeight = 57.0; // 轮播图的高度

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
    kFHScrollBannerHeight = 57.0;
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

@implementation FHHomeScrollBannerView


@end

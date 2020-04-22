//
//  FHMainRentTopView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHMainRentTopView.h"
#import "FHMainRentTopCell.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <FHHouseBase/FHConfigModel.h>
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHBaseCollectionView.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <FHHouseBase/FHHomeEntranceItemView.h>
#import "FHListEntrancesView.h"
#import <FHHouseBase/FHEnvContext.h>
#import "Masonry.h"
#import <FHCommonUI/FHFakeInputNavbar.h>

@interface FHMainRentTopView ()

@property(nonatomic , strong) NSArray<FHConfigDataRentOpDataItemsModel *> *items;
@property(nonatomic , strong)  FHConfigDataModel *configModel;

@property(nonatomic , strong) FHListEntrancesView *bottomContainerView;

@property(nonatomic , strong) UIImageView *bannerView;
@end

#define kCellId @"cell_id"
#define ITEM_WIDTH  56
#define TOP_PADDING    15
#define BOTTOM_PADDING 6

#define BANNER_HEIGHT  (102-BOTTOM_PADDING)
#define BANNER_HOR_MARGIN 14
#define kFHMainRentEntranceCountPerRow 5


@implementation FHMainRentTopView

+(CGFloat)bannerHeight:(FHConfigDataRentBannerModel *)rentBannerModel
{
    if (rentBannerModel.items.count > 0) {
        FHConfigDataRentBannerItemsModel *item = [rentBannerModel.items firstObject];
        if (item.image.count > 0) {
            FHConfigDataRentBannerItemsImageModel *img = [item.image firstObject];
            CGFloat bannerHeight = BANNER_HEIGHT;
            CGFloat imgWidth = img.width.floatValue;
            CGFloat imgHeight = img.height.floatValue;
            if (imgWidth > 0 && imgHeight > 0) {
                bannerHeight = (SCREEN_WIDTH - BANNER_HOR_MARGIN*2)*imgHeight/imgWidth - BOTTOM_PADDING;
            }
            return ceil(bannerHeight);
        }
    }
    return 0;
}

+(UIImage *)cacheImageForRentBanner:(FHConfigDataRentBannerModel *)rentBannerModel
{
    if (rentBannerModel.items.count == 0) {
        return nil;
    }
    FHConfigDataRentBannerItemsModel *model = [rentBannerModel.items firstObject];
    FHConfigDataRentBannerItemsImageModel *img = [model.image firstObject];
    if (!img) {
        return nil;
    }
    return  [[BDWebImageManager sharedManager].imageCache imageForKey:img.url];
}

-(instancetype)initWithFrame:(CGRect)frame banner:(FHConfigDataRentBannerModel *)rentBanner
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor themeGray8];
        [self setupUI];
        [self initConstraints];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.bottomContainerView];
    [self addSubview:self.bannerView];
}

- (void)initConstraints
{
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo([FHFakeInputNavbar perferredHeight]);
        make.height.mas_equalTo([FHMainRentTopView entranceHeight]);
    }];
}

+ (CGFloat)entranceHeight
{
    if ([self showEntrance]) {
        return [FHListEntrancesView rowHeight] + 20;
    }
    return 0;
}

+ (CGFloat)totalHeight
{
    return [FHFakeInputNavbar perferredHeight] + [self entranceHeight];
}

+ (BOOL)showEntrance
{
    return ([[FHEnvContext sharedInstance] getConfigFromCache].rentOpData.items.count > 0);
}

- (void)updateWithConfigData:(FHConfigDataModel *)configModel
{
    _configModel = configModel;
    NSArray *items = configModel.rentOpData.items;
    if (items.count > 5) {
        _items = [items subarrayWithRange:NSMakeRange(0, 5 )];
    }else{
        _items = items;
    }
    [self.bottomContainerView updateWithItems:_items];
    
    __weak typeof(self)wself = self;
    self.bottomContainerView.clickBlock = ^(NSInteger clickIndex , FHConfigDataOpDataItemsModel *itemModel){
        if ([wself.delegate respondsToSelector:@selector(selecteRentItem:)]) {
            FHConfigDataRentOpDataItemsModel *model = wself.items[clickIndex];
            [wself.delegate selecteRentItem:model];
        }
    };
}

-(void)setBannerUrl:(NSString *)bannerUrl
{
    _bannerUrl = bannerUrl;
    [_bannerView bd_setImageWithURL:[NSURL URLWithString:bannerUrl]];
}

-(void)bannerClickAction
{
    if ([self.delegate respondsToSelector:@selector(tapRentBanner)]) {
        [self.delegate tapRentBanner];
    }
}

- (FHListEntrancesView *)bottomContainerView
{
    if (!_bottomContainerView) {
        _bottomContainerView = [[FHListEntrancesView alloc]init];
        _bottomContainerView.backgroundColor = [UIColor themeGray8];
        _bottomContainerView.countPerRow = kFHMainRentEntranceCountPerRow;
    }
    return _bottomContainerView;
}

@end

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
#import <Masonry.h>
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

//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        layout.headerReferenceSize = CGSizeMake(HOR_MARGIN, 1);
//        layout.footerReferenceSize = CGSizeMake(HOR_MARGIN, 1);
//
//        CGRect f = self.bounds;
//
//        CGFloat bannerHeight = [self.class bannerHeight:rentBanner];
//        BOOL needShowBanner = rentBanner && rentBanner.items.count > 0 ;
//        FHConfigDataRentBannerItemsModel *model = [rentBanner.items firstObject];
//        FHConfigDataRentBannerItemsImageModel *img = [model.image firstObject];
//        UIImage *image  = [[BDWebImageManager sharedManager].imageCache imageForKey:img.url];
//
//        if (bannerHeight == 0) {
//            needShowBanner = NO;
//        }
//
//        f.size.height -= BOTTOM_PADDING;
//        if (needShowBanner && image) {
//            f.size.height -= bannerHeight;
//        }
//        //CGRectMake(0, 15, frame.size.width, frame.size.height - BOTTOM_PADDING - 15)
//        _collectionView = [[FHBaseCollectionView alloc]initWithFrame:f collectionViewLayout:layout];
//        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
//
//
//        [_collectionView registerClass:[FHMainRentTopCell class] forCellWithReuseIdentifier:kCellId];
//
//        _layout = layout;
//
//        [self addSubview:_collectionView];
//        if (needShowBanner) {
//            _bannerView = [[UIImageView alloc]initWithFrame:CGRectMake(BANNER_HOR_MARGIN, CGRectGetMaxY(_collectionView.frame), f.size.width - 2*BANNER_HOR_MARGIN, bannerHeight+BOTTOM_PADDING)];
//            [self addSubview:_bannerView];
//
//            if (image) {
//                _bannerView.image = image;
//            }else{
//
//                __weak typeof(self) wself = self;
//                [_bannerView bd_setImageWithURL:[NSURL URLWithString:img.url] placeholder:nil options:BDImageRequestHighPriority completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
//                    if (!wself) {
//                        return ;
//                    }
//                    if ([wself.delegate respondsToSelector:@selector(rentBannerLoaded:)]) {
//                        [wself.delegate rentBannerLoaded:wself.bannerView];
//                    }
//                }];
//            }
//
//            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerClickAction)];
//            [_bannerView addGestureRecognizer:tapGesture];
//            _bannerView.userInteractionEnabled = YES;
//
//            self.backgroundColor = [UIColor whiteColor];
//        }else{
//            self.backgroundColor = [UIColor themeGray7];
//        }
//
//
//        _collectionView.backgroundColor = [UIColor whiteColor];
//        _bannerView.backgroundColor = [UIColor whiteColor];
        
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
    return [FHListEntrancesView rowHeight] + 20;
}

+ (CGFloat)totalHeight
{
    return [FHFakeInputNavbar perferredHeight] + [self entranceHeight];
}

- (void)updateWithConfigData:(FHConfigDataModel *)configModel
{
    // todo zjing data
    _configModel = configModel;
    NSArray *items = configModel.houseOpData2.items;
    if (items.count > 5) {
        _items = [items subarrayWithRange:NSMakeRange(0, 5 )];
    }else{
        _items = items;
    }
    [self.bottomContainerView updateWithItems:_items];
    
    __weak typeof(self)wself = self;
    self.bottomContainerView.clickBlock = ^(NSInteger clickIndex , FHConfigDataOpDataItemsModel *itemModel){
        if ([self.delegate respondsToSelector:@selector(selecteRentItem:)]) {
            FHConfigDataRentOpDataItemsModel *model = _items[clickIndex];
            [self.delegate selecteRentItem:model];
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

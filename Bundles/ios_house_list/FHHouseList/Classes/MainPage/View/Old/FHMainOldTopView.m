//
//  FHMainOldTopView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHMainOldTopView.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHMainOldTopCell.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import <FHHouseBase/FHHomeScrollBannerView.h>
#import <FHHouseBase/FHHomeEntranceItemView.h>
#import <Masonry.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <FHHouseBase/FHConfigModel.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "FHListEntrancesView.h"
#import "FHMainTopViewHelper.h"
#import <FHHouseBase/FHEnvContext.h>
#import <TTRoute.h>

#define kCellId @"cell_id"
#define ITEM_HOR_MARGIN  10
#define TOP_PADDING      14
#define BOTTOM_PADDING   4
#define kFHMainEntranceCountPerRow 5

@interface FHMainOldTopView ()<FHBannerViewIndexProtocol>

@property(nonatomic , strong) NSArray<FHConfigDataOpDataItemsModel *> *items;

@property(nonatomic , strong) UIView *topBgView;//64 + 140 + 10

@property(nonatomic , strong) FHHomeScrollBannerView *bannerView;
@property(nonatomic , strong) UIView *bottomBgView;
@property(nonatomic , strong) FHListEntrancesView *bottomContainerView;
@property(nonatomic , strong)  FHConfigDataModel *configModel;
@property (nonatomic, strong) FHConfigDataMainPageBannerOpDataModel *bannerOpData ;

@end





@implementation FHMainOldTopView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
        [self initConstraints];
    }
    return self;
}

+ (CGFloat)bannerHeight
{
    // todo zjing
    if([FHMainOldTopView showBanner]) {
        return ceil(([UIScreen mainScreen].bounds.size.width - kFHScrollBannerLeftRightMargin * 2) / 335.0f * 140);
    }else {
        return 0;
    }
}

+ (CGFloat)entranceHeight
{
    return [FHListEntrancesView rowHeight] + 20;
}

+ (CGFloat)totalHeight
{
    CGFloat bannerHeight = [FHMainOldTopView showBanner] ? [FHMainOldTopView bannerHeight] + 10 : 0;
    return [FHFakeInputNavbar perferredHeight] + bannerHeight + [FHMainOldTopView entranceHeight];
}

+ (BOOL)showBanner
{
    return ([[FHEnvContext sharedInstance] getConfigFromCache].houseListBanner.items.count > 0);
}

- (void)setupUI
{
    [self addSubview:self.topBgView];
    [self addSubview:self.bottomBgView];
    [self addSubview:self.bannerView];
    [self addSubview:self.bottomContainerView];
    self.bannerView.delegate = self;
    [self.bannerView setContent:[UIScreen mainScreen].bounds.size.width - kFHScrollBannerLeftRightMargin * 2 height:[FHMainOldTopView bannerHeight]];
    
    // todo zjing
    self.topBgView.backgroundColor = [UIColor colorWithHexString:@"#c5b8aej" alpha:1];
    self.bannerView.backgroundColor = [UIColor redColor];
    self.bottomBgView.hidden = [FHMainOldTopView showBanner] ? NO : YES;
    
    self.bottomContainerView.backgroundColor = [UIColor themeBlue1];

}

- (void)initConstraints
{
    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo([FHMainOldTopView bannerHeight] + 10 + [FHFakeInputNavbar perferredHeight]);
    }];
    CGFloat bannerMargin = [FHMainOldTopView bannerHeight] > 0 ? 10 : 0;
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo([FHFakeInputNavbar perferredHeight] + bannerMargin);
        make.height.mas_equalTo([FHMainOldTopView bannerHeight]);
    }];
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.bannerView.mas_bottom);
        make.height.mas_equalTo([FHMainOldTopView entranceHeight]);
    }];
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.bannerView.mas_bottom).mas_offset(-40);
        make.bottom.mas_equalTo(self.bottomContainerView);// todo zjing height
    }];
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
    _bannerOpData = configModel.houseListBanner;
    [self updateBannerWithModel:self.bannerOpData];
    
    __weak typeof(self)wself = self;
    self.bottomContainerView.clickBlock = ^(NSInteger clickIndex , FHConfigDataOpDataItemsModel *itemModel){
        if ([wself.delegate respondsToSelector:@selector(selecteOldItem:)]) {
            FHConfigDataOpDataItemsModel *model = wself.items[clickIndex];
            [wself.delegate selecteOldItem:model];
        }
    };
}

// 注意cell的刷新频率问题
- (void)updateBannerWithModel:(FHConfigDataMainPageBannerOpDataModel *)model
{
    [self.bannerView removeTimer];
    // 获取图片数据数组
    NSMutableArray *opDatas = [[NSMutableArray alloc] init];
    NSMutableArray *imageUrls = [NSMutableArray new];
    for (int i = 0; i < model.items.count; i++) {
        FHConfigDataRentOpDataItemsModel *opData = model.items[i];
        if ([FHMainOldTopView isValidModel:opData]) {
            if (opData.image.count > 0) {
                FHConfigDataRentOpDataItemsImageModel *opImage = opData.image[0];
                if (opImage.url.length > 0) {
                    [imageUrls addObject:opImage.url];
                    [opDatas addObject:opData];
                }
            }
        }
    }
//    [self.tracerDic removeAllObjects];
    [self.bannerView setURLs:imageUrls];
}

+ (BOOL)isValidModel:(FHConfigDataRentOpDataItemsModel *)tModel {
    if (tModel == nil) {
        return NO;
    }
    BOOL retFlag = NO;
    if (tModel.openUrl.length > 0 && tModel.image.count > 0 && tModel.id.length > 0) {
        NSURL *tUrl = [NSURL URLWithString:tModel.openUrl];
        // 是否有效的openUrl
        if ([[TTRoute sharedRoute] canOpenURL:tUrl]) {
            FHConfigDataRentOpDataItemsImageModel *imageModel = tModel.image[0];
            if (imageModel.url.length > 0) {
                // 有图片url
                retFlag = YES;
            }
        }
    }
    return retFlag;
}

#pragma mark - FHBannerViewIndexProtocol

- (void)currentIndexChanged:(NSInteger)currentIndex
{
//    if (currentIndex >= 0 && currentIndex < self.model.items.count) {
//        FHConfigDataRentOpDataItemsModel *opData = self.model.items[currentIndex];
//        [self addTracerShow:opData index:currentIndex];
//    }
}
- (void)clickBannerWithIndex:(NSInteger)currentIndex
{
    if (currentIndex >= 0 && currentIndex < self.bannerOpData.items.count) {
        FHConfigDataRentOpDataItemsModel *opData = self.bannerOpData.items[currentIndex];
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickBannerItem:withIndex:)]) {
            [self.delegate clickBannerItem:opData withIndex:currentIndex];
        }
    }
}

#pragma mark - UI

- (UIView *)topBgView
{
    if (!_topBgView) {
        _topBgView = [[UIView alloc]init];
    }
    return _topBgView;
}

- (FHHomeScrollBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [[FHHomeScrollBannerView alloc] init];
        _bannerView.backgroundColor = [UIColor themeHomeColor];
        _bannerView.layer.masksToBounds = YES;
        _bannerView.layer.cornerRadius = 12;
    }
    return _bannerView;
}

- (UIView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]init];
        _bottomBgView.backgroundColor = [UIColor themeGray8];
        _bottomBgView.layer.masksToBounds = YES;
        _bottomBgView.layer.cornerRadius = 10;
    }
    return _bottomBgView;
}

- (FHListEntrancesView *)bottomContainerView
{
    if (!_bottomContainerView) {
        _bottomContainerView = [[FHListEntrancesView alloc]init];
        _bottomContainerView.backgroundColor = [UIColor themeGray8];
        _bottomContainerView.countPerRow = kFHMainEntranceCountPerRow;
    }
    return _bottomContainerView;
}


- (void)dealloc
{
    NSLog(@"zjing");
}
@end

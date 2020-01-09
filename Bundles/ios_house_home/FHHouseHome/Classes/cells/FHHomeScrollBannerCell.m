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
#import <FHShadowView.h>
#import <FHHouseBase/FHHomeScrollBannerView.h>


@interface FHHomeScrollBannerCell ()<FHBannerViewIndexProtocol>

@property (nonatomic, strong)   FHConfigDataMainPageBannerOpDataModel       *model;
@property (nonatomic, strong)   NSMutableDictionary       *tracerDic;
@property (nonatomic, strong)   FHShadowView       *shadowView;

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
    kFHScrollBannerHeight = 80;
    kFHScrollBannerHeight = ceil(([UIScreen mainScreen].bounds.size.width - kFHScrollBannerLeftRightMargin * 2) / 335.0f * kFHScrollBannerHeight);
    return kFHScrollBannerHeight + kFHScrollBannerTopMargin * 2;
}

- (void)setupUI {
    _tracerDic = [NSMutableDictionary new];
    _bannerView = [[FHHomeScrollBannerView alloc] init];
    _bannerView.backgroundColor = [UIColor themeHomeColor];
    _bannerView.layer.masksToBounds = YES;
    _bannerView.layer.cornerRadius = 8;

    _shadowView = [[FHShadowView alloc] initWithFrame:CGRectMake(15, 14, [UIScreen mainScreen].bounds.size.width -  kFHScrollBannerLeftRightMargin * 2, kFHScrollBannerHeight)];
    [_shadowView setCornerRadius:10];
    [_shadowView setShadowColor:[UIColor colorWithRed:110.f/255.f green:110.f/255.f blue:110.f/255.f alpha:1]];
    [_shadowView setShadowOffset:CGSizeMake(0, 2)];
    [self.contentView addSubview:_shadowView];
    [self.contentView addSubview:_bannerView];
    
    [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kFHScrollBannerLeftRightMargin);
        make.right.mas_equalTo(-kFHScrollBannerLeftRightMargin);
        make.bottom.mas_equalTo(self.contentView).offset(-16);// 下面的降价房cell之前布局有问题
        make.height.mas_equalTo(kFHScrollBannerHeight);
    }];
    _bannerView.delegate = self;
    [_bannerView setContent:[UIScreen mainScreen].bounds.size.width - kFHScrollBannerLeftRightMargin * 2 height:kFHScrollBannerHeight];
    
    [self.contentView setBackgroundColor:[UIColor themeHomeColor]];
}

+ (BOOL)hasValidModel:(FHConfigDataMainPageBannerOpDataModel *)mainPageOpData {
    if (mainPageOpData && [mainPageOpData isKindOfClass:[FHConfigDataMainPageBannerOpDataModel class]]) {
        for (int i = 0; i < mainPageOpData.items.count; i++) {
            FHConfigDataRentOpDataItemsModel *tModel = mainPageOpData.items[i];
            if ([self isValidModel:tModel]) {
                return YES;
            }
        }
    }
    return NO;
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
        if ([FHHomeScrollBannerCell isValidModel:opData]) {
            if (opData.image.count > 0) {
                FHConfigDataRentOpDataItemsImageModel *opImage = opData.image[0];
                if (opImage.url.length > 0) {
                    [imageUrls addObject:opImage.url];
                    [opDatas addObject:opData];
                }
            }
        }
    }
    [self.tracerDic removeAllObjects];
    [_bannerView setURLs:imageUrls];
}

- (void)addTracerShow:(FHConfigDataRentOpDataItemsModel *)opData index:(NSInteger)index {
    // banner show 唯一性判断(地址)
    NSString *tracerKey = [NSString stringWithFormat:@"_%p_",opData];
    if (tracerKey.length > 0) {
        if (self.tracerDic[tracerKey]) {
            return;
        }
        self.tracerDic[tracerKey] = @(1);
    }
    NSString *opId = opData.id;
    if (opId.length > 0) {
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



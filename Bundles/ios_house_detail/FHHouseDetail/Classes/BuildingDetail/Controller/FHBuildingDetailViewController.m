//
//  FHBuildingDetailViewController.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailViewController.h"
#import "FHBuildingDetailViewModel.h"
#import "FHBuildingDetailCollectionViewFlowLayout.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import "UIViewController+Track.h"
#import "FHLoadingButton.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHBuildingDetailFloorCollectionViewCell.h"
#import "FHBuildingDetailInfoCollectionViewCell.h"
#import "FHBuildingDetailEmptyFloorCollectionViewCell.h"
#import "FHBuildingDetailTopImageCollectionViewCell.h"
#import "FHDetailBaseModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHBuildingDetailModel.h"
#import "FHBuildingDetailUtils.h"
#import "NSDictionary+BTDAdditions.h"

@interface FHBuildingDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, copy) NSString *originId;
@property (nonatomic, strong) FHBuildingDetailViewModel *viewModel;

@property (nonatomic, strong) FHBuildingDetailCollectionViewFlowLayout *layout;
@property (nonatomic, weak) FHBaseCollectionView *collectionView;
@property (nonatomic, strong)   UIButton       *onlineBtn;
@property (nonatomic, strong)   FHLoadingButton       *contactBtn;

@property(nonatomic, strong) UIView *bottomBar;

@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;

@property (nonatomic) BOOL shouldReloadAnimated;
@property (nonatomic, strong) NSMutableArray *showHouseCache;

@property (nonatomic, strong) NSMutableDictionary *currentDict;
@property (nonatomic, weak) FHBuildingDetailTopImageCollectionViewCell *topImageView;
@property (nonatomic, weak) FHBuildingDetailInfoCollectionViewCell *infoCollectionView;
@end

@implementation FHBuildingDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        self.ttTrackStayEnable = YES;
        if (paramObj.allParams[@"house_id"]) {
            self.houseId = paramObj.allParams[@"house_id"];
        }
        if (paramObj.allParams[@"origin_id"]) {
            self.originId = paramObj.allParams[@"origin_id"];
        }

        self.contactViewModel = [[FHHouseDetailContactViewModel alloc] initWithNavBar:nil bottomBar:nil houseType:FHHouseTypeNewHouse houseId:self.houseId];
        self.contactViewModel.tracerDict = self.tracerDict.mutableCopy;
        if (paramObj.allParams[@"contactViewModel"]) {
            FHHouseDetailContactViewModel *contactViewModel = paramObj.allParams[@"contactViewModel"];
            FHDetailContactModel *contactPhone = contactViewModel.contactPhone;
            contactPhone.isInstantData = YES;
            self.contactViewModel.contactPhone = contactPhone;
            self.contactViewModel.showenOnline = contactViewModel.showenOnline;
            self.contactViewModel.phoneCallName = contactViewModel.phoneCallName;
            self.contactViewModel.onLineName = contactViewModel.onLineName;
            self.contactViewModel.toast = contactViewModel.toast;
        }
        self.currentDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (UIButton *)onlineBtn {
    if (!_onlineBtn) {
        _onlineBtn = [[UIButton alloc] init];
        _onlineBtn.layer.cornerRadius = 20;
        _onlineBtn.layer.masksToBounds = YES;
        _onlineBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _onlineBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
        [_onlineBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateNormal];
        [_onlineBtn setTitle:@"在线联系" forState:UIControlStateHighlighted];
        [_onlineBtn addTarget:self action:@selector(onlineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _onlineBtn.layer.shadowColor = [UIColor colorWithRed:255/255.0 green:143/255.0 blue:0 alpha:0.3].CGColor;
        _onlineBtn.layer.shadowOffset = CGSizeMake(4, 10);
    }
    return _onlineBtn;
}

- (FHLoadingButton *)contactBtn {
    if (!_contactBtn) {
        _contactBtn = [[FHLoadingButton alloc]init];
        _contactBtn.layer.cornerRadius = 20;
        _contactBtn.layer.masksToBounds = YES;
        _contactBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _contactBtn.backgroundColor = [UIColor colorWithHexStr:@"#fe5500"];
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateHighlighted];
        [_contactBtn addTarget:self action:@selector(contactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _contactBtn.layer.shadowColor = [UIColor colorWithRed:254/255.0 green:85/255.0 blue:0 alpha:0.3].CGColor;
        _contactBtn.layer.shadowOffset = CGSizeMake(4, 10);
    }
    return _contactBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor themeGray7];
    self.topImageView = nil;
    [self setupNavbar];
    [self setupUI];
    
    [self addDefaultEmptyViewFullScreen];
    
    self.viewModel = [[FHBuildingDetailViewModel alloc] initWithController:self];
    self.viewModel.houseId = self.houseId;
    self.viewModel.originId = self.originId;
    [self.viewModel startLoadData];
    [self addGoDetailLog];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self addStayPageLog];
    [self tt_resetStayTime];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    if (self.bottomBar) {
        [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(64 + bottomInset);
        }];
        contentInset.bottom = 20 + bottomInset + 64;
    } else {
        contentInset.bottom = 20 + bottomInset;
    }
    self.collectionView.contentInset = contentInset;
}

- (void)setupNavbar {
    [self setupDefaultNavBar:NO];
//    [self.customNavBarView setNaviBarTransparent:YES];
    self.customNavBarView.title.text = @"楼栋信息";
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateHighlighted];
}

- (void)setupUI {
    self.layout = [[FHBuildingDetailCollectionViewFlowLayout alloc] init];
    FHBaseCollectionView *collectionView = [[FHBaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    collectionView.backgroundColor = [UIColor themeGray7];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    [self.collectionView registerClass:[FHBuildingDetailTopImageCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailTopImageCollectionViewCell class])];
    [self.collectionView registerClass:[FHBuildingDetailInfoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailInfoCollectionViewCell class])];
    [self.collectionView registerClass:[FHBuildingDetailFloorCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailFloorCollectionViewCell class])];
    [self.collectionView registerClass:[FHBuildingDetailEmptyFloorCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailEmptyFloorCollectionViewCell class])];
    [self.collectionView registerClass:[FHDetailSectionTitleCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FHDetailSectionTitleCollectionView class])];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
}

- (void)refreshBottomBar {
    // lead_show 埋点
    [self addLeadShowLog:self.contactViewModel.contactPhone baseParams:self.tracerDict];

    if (!self.contactViewModel) {
        if (self.bottomBar) {
            [self.bottomBar removeFromSuperview];
            self.bottomBar = nil;
        }
        return;
    }
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 64, CGRectGetWidth(self.view.bounds), 64)];
    self.bottomBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomBar];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(64);
        make.bottom.mas_equalTo(0);
    }];
    
    BOOL showenOnline = self.contactViewModel.showenOnline;
    CGFloat itemWidth = CGRectGetWidth(self.view.bounds) - 30;
    if (showenOnline) {
        itemWidth = (itemWidth - 13) / 2.0;
        // 在线联系
        NSString *title = @"在线联系";
        if (self.contactViewModel.onLineName.length > 0) {
            title = self.contactViewModel.onLineName;
        }
        NSMutableAttributedString *buttonTitle = [[NSMutableAttributedString alloc] initWithString:title?:@"" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:16], NSForegroundColorAttributeName : [UIColor whiteColor]}];
        //            [buttonTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n线上联系更方便" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
        self.onlineBtn.titleLabel.numberOfLines = 0;
        [self.onlineBtn setAttributedTitle:buttonTitle.copy forState:UIControlStateNormal];
        
        [self.bottomBar addSubview:self.onlineBtn];
        [self.onlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(12);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(40);
        }];
        
        // 电话咨询
        NSString *photoTitle = @"电话咨询";
        if (self.contactViewModel.phoneCallName.length > 0) {
            photoTitle = self.contactViewModel.phoneCallName;
        }
        NSMutableAttributedString *buttonPhoneTitle = [[NSMutableAttributedString alloc] initWithString:photoTitle?:@"" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:16], NSForegroundColorAttributeName : [UIColor whiteColor]}];
        //            [buttonPhoneTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n隐私保护更安全" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
        self.contactBtn.titleLabel.numberOfLines = 0;
        [self.contactBtn setAttributedTitle:buttonPhoneTitle.copy forState:UIControlStateNormal];
        [self.bottomBar addSubview:self.contactBtn];
        [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-16);
            make.top.mas_equalTo(self.onlineBtn.mas_top);
            make.width.mas_equalTo(self.onlineBtn.mas_width);
            make.height.mas_equalTo(self.onlineBtn.mas_height);
        }];
    } else {
        // 电话咨询
        NSString *photoTitle = @"电话咨询";
        if (self.contactViewModel.phoneCallName.length > 0) {
            photoTitle = self.contactViewModel.phoneCallName;
        }
        NSMutableAttributedString *buttonPhoneTitle = [[NSMutableAttributedString alloc] initWithString:photoTitle?:@"" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:16], NSForegroundColorAttributeName : [UIColor whiteColor]}];
        //            [buttonPhoneTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n隐私保护更安全" attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
        self.contactBtn.titleLabel.numberOfLines = 0;
        [self.contactBtn setAttributedTitle:buttonPhoneTitle.copy forState:UIControlStateNormal];
        self.contactBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
        [self.bottomBar addSubview:self.contactBtn];
        [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(12);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(40);
        }];
    }
}

- (void)startLoading {
    [super startLoading];
}

- (void)endLoading {
    [super endLoading];
}

- (void)retryLoadData {
    // 重新加载数据
    [self.viewModel startLoadData];
}

- (void)reloadData {
    FHDetailContactModel *contactPhone = nil;
    
    if (self.viewModel.buildingDetailModel.data.highlightedRealtor) {
        contactPhone = self.viewModel.buildingDetailModel.data.highlightedRealtor;
        contactPhone.isInstantData = YES;
    }
//    else {
//        contactPhone = model.data.contact;
//    }

    contactPhone.isFormReport = !contactPhone.enablePhone;
    self.contactViewModel.contactPhone = contactPhone;
    
    [self refreshBottomBar];
    
    NSMutableArray <FHBuildingSectionModel *>*items = [NSMutableArray array];
    
    if (self.viewModel.locationModel.buildingImage.url.length > 0) {
        FHBuildingSectionModel *imageSection = [[FHBuildingSectionModel alloc] init];
        imageSection.sectionType = FHBuildingSectionTypeImage;
        [items addObject:imageSection];
        self.layout.existTopImageView = YES;
    }
    
    if (self.viewModel.locationModel.saleStatusList.count <= self.currentIndex.saleStatus) {
        return;
    }
    
    FHBuildingSaleStatusModel *statusModel = self.viewModel.locationModel.saleStatusList[self.currentIndex.saleStatus];
    if (statusModel.buildingList.count > self.currentIndex.buildingIndex) {
        
        FHBuildingSectionModel *infoSection = [[FHBuildingSectionModel alloc] init];
        infoSection.sectionType = FHBuildingSectionTypeInfo;
        [items addObject:infoSection];

        FHBuildingDetailDataItemModel *model = statusModel.buildingList[self.currentIndex.buildingIndex];

        FHBuildingSectionModel *section = [[FHBuildingSectionModel alloc] init];
        if (model.relatedFloorplanList.list.count) {
            section.sectionType = FHBuildingSectionTypeFloor;
            section.sectionTitle = model.relatedFloorplanList.title;
        } else {
            section.sectionType = FHBuildingSectionTypeEmpty;
            section.sectionTitle = nil;
        }
        [items addObject:section];
        
        self.layout.model = model;
        self.viewModel.items = items.copy;
        [self.collectionView reloadData];
    }
}

- (void)responseCenterWithOperat:(FHBuildingDetailOperatType)type withIndexModel:(FHBuildingIndexModel *)indexModel {
    switch (type) {
        case FHBuildingDetailOperatTypeSaleStatus:
            indexModel.buildingIndex = [self.currentDict btd_integerValueForKey:@(indexModel.saleStatus)];
            self.currentIndex = indexModel;
            [self addClickOptions:type withIndexModel:indexModel];
            [self reloadFloorCollectionViewData];
            break;
        case FHBuildingDetailOperatTypeInfoCell:
            self.currentIndex = indexModel;
            [self.currentDict btd_setObject:@(indexModel.buildingIndex) forKey:@(indexModel.saleStatus)];
            break;
        case FHBuildingDetailOperatTypeButton:
            self.currentIndex = indexModel;
            [self.currentDict btd_setObject:@(indexModel.buildingIndex) forKey:@(indexModel.saleStatus)];
            [self addClickOptions:type withIndexModel:indexModel];
            [self.infoCollectionView manualSetContentOffset:indexModel.buildingIndex];
            break;
        case FHBuildingDetailOperatTypeFromNew:    //不可能出现
            self.currentIndex = indexModel;
            [self.currentDict btd_setObject:@(indexModel.buildingIndex) forKey:@(indexModel.saleStatus)];
            break;
        default:
            break;
    }
    [self.topImageView updateWithIndexModel:indexModel];
    [self reloadRelatedFloorpanData];
}

- (void)reloadFloorCollectionViewData {
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.viewModel.items.count - 2]];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    ;
}

- (void)reloadRelatedFloorpanData {
    FHBuildingSectionModel *section = self.viewModel.items.lastObject;
    FHBuildingSaleStatusModel *saleModel = self.viewModel.locationModel.saleStatusList[self.currentIndex.saleStatus];
    FHBuildingDetailDataItemModel *model = saleModel.buildingList[self.currentIndex.buildingIndex];
    if (model.relatedFloorplanList.list.count) {
        section.sectionType = FHBuildingSectionTypeFloor;
        section.sectionTitle = model.relatedFloorplanList.title;
    } else {
        section.sectionType = FHBuildingSectionTypeEmpty;
        section.sectionTitle = nil;
    }
    self.layout.model = model;
    self.shouldReloadAnimated = YES;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.viewModel.items.count - 1]];
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.viewModel.items.count - 1]];
//    } completion:^(BOOL finished) {
//        // do something on completion
//        self.shouldReloadAnimated = NO;
//    }];
}

#pragma mark - Action
// 电话咨询点击
- (void)contactButtonClick:(UIButton *)btn {
    if (self.contactViewModel) {

        NSMutableDictionary *extraDic = @{
            @"realtor_position":@"detail_button",
            @"position":@"report_button",
            @"element_from":@"building"
        }.mutableCopy;
        [extraDic addEntriesFromDictionary:self.tracerDict];
//        extraDic[@"event_tracking_id"] = @"70832";
//        extraDic[@"from"] = @"app_newhouse_property_picture";
//        if (cluePage) {
//            extraDic[kFHCluePage] = cluePage;
//        }
        NSDictionary *associateInfoDict = nil;
        FHDetailContactModel *contactPhone = self.contactViewModel.contactPhone;
        if (contactPhone.enablePhone) {
            associateInfoDict = self.viewModel.buildingDetailModel.data.associateInfo.phoneInfo;
        }else {
            associateInfoDict = self.viewModel.buildingDetailModel.data.associateInfo.reportFormInfo;
        }
        extraDic[kFHAssociateInfo] = associateInfoDict;
        [self.contactViewModel contactActionWithExtraDict:extraDic];
    }
}

// 在线联系点击
- (void)onlineButtonClick:(UIButton *)btn {
    if (self.contactViewModel) {
        NSMutableDictionary *extraDic = @{}.mutableCopy;
        [extraDic addEntriesFromDictionary:self.tracerDict];
        extraDic[@"realtor_position"] = @"detail_button";
//        extraDic[@"position"] = @"online";
        extraDic[@"element_from"] = @"building";
        extraDic[@"from"] = @"app_newhouse_property_picture";
        extraDic[@"event_tracking_id"] = @"70831";
        // 头图im入口线索透传
        if(self.viewModel.buildingDetailModel.data.associateInfo) {
            extraDic[kFHAssociateInfo] = self.viewModel.buildingDetailModel.data.associateInfo;
        }
        [self.contactViewModel onlineActionWithExtraDict:extraDic];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.viewModel.items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    FHBuildingSectionModel *sectionModel = self.viewModel.items[section];
    switch (sectionModel.sectionType) {
        case FHBuildingSectionTypeFloor: {
            FHBuildingSaleStatusModel *saleModel = self.viewModel.locationModel.saleStatusList[self.currentIndex.saleStatus];
            FHBuildingDetailDataItemModel *model = saleModel.buildingList[self.currentIndex.buildingIndex];
            if (model.relatedFloorplanList.list.count > 0) {
                return model.relatedFloorplanList.list.count;
            }
            return 1;
            break;
        }
        default:
            return 1;
            break;
    }
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHBuildingSectionModel *sectionModel = self.viewModel.items[indexPath.section];
    FHDetailBaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:sectionModel.className forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    switch (sectionModel.sectionType) {
        case FHBuildingSectionTypeImage: {
            [((FHBuildingDetailTopImageCollectionViewCell *)cell) setIndexDidSelect:^(FHBuildingDetailOperatType type, FHBuildingIndexModel * _Nonnull index) {
                [weakSelf responseCenterWithOperat:type withIndexModel:index];
            }];
            self.topImageView = (FHBuildingDetailTopImageCollectionViewCell *)cell;
            [cell refreshWithData:self.viewModel.locationModel];
            [((FHBuildingDetailTopImageCollectionViewCell *)cell) updateWithIndexModel:self.currentIndex];
            break;
        }
        case FHBuildingSectionTypeInfo: {
            //切换调用
            FHBuildingSaleStatusModel *saleModel = self.viewModel.locationModel.saleStatusList[self.currentIndex.saleStatus];
            
            ((FHBuildingDetailInfoCollectionViewCell *)cell).currentIndexPath = [NSIndexPath indexPathForItem:self.currentIndex.buildingIndex inSection:0];
            [cell refreshWithData:saleModel];
            self.infoCollectionView = (FHBuildingDetailInfoCollectionViewCell *)cell;
            
            [(FHBuildingDetailInfoCollectionViewCell *)cell setInfoIndexDidSelect:^(FHBuildingDetailOperatType type, FHBuildingIndexModel * _Nonnull index) {
                [weakSelf responseCenterWithOperat:type withIndexModel:index];
            }];
            
            break;
        }
        case FHBuildingSectionTypeFloor: {
            //动态调整
            FHBuildingSaleStatusModel *saleModel = self.viewModel.locationModel.saleStatusList[self.currentIndex.saleStatus];
            FHBuildingDetailDataItemModel *model = saleModel.buildingList[self.currentIndex.buildingIndex];
            [cell refreshWithData:model.relatedFloorplanList.list[indexPath.row]];
            UIView *bottomLine = [(FHBuildingDetailFloorCollectionViewCell *)cell bottomLine];
            if (indexPath.row == model.relatedFloorplanList.list.count - 1) {
                // hidden line
                bottomLine.hidden = YES;
            } else {
                bottomLine.hidden = NO;
            }
//            if (self.shouldReloadAnimated) {
//                cell.alpha = 0;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    CGPoint center = cell.center;
//                    cell.center = CGPointMake(cell.center.x, cell.center.y - 10);
//                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.15]];
//                    [UIView animateWithDuration:0.5 animations:^{
//                        cell.alpha = 1;
//                        //                    cell.center = center;
//                    }];
//                    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
//                        cell.center = center;
//                    } completion:^(BOOL finished) {
//                        ;
//                    }];
//                });
//            }

            break;
        }
        default:
            break;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        FHBuildingSectionModel *sectionModel = self.viewModel.items[indexPath.section];
        if (sectionModel.sectionTitle.length) {
            FHDetailSectionTitleCollectionView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([FHDetailSectionTitleCollectionView class]) forIndexPath:indexPath];
            titleView.titleLabel.font = [UIFont themeFontMedium:20];
            titleView.titleLabel.textColor = [UIColor themeGray1];
            titleView.titleLabel.text = sectionModel.sectionTitle;
            return titleView;
        }
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHBuildingSectionModel *sectionModel = self.viewModel.items[indexPath.section];
    CGFloat width = CGRectGetWidth(collectionView.frame);
    switch (sectionModel.sectionType) {
        case FHBuildingSectionTypeImage: {
            return [FHBuildingDetailUtils getTopImageViewSize];
            break;
        }
        case FHBuildingSectionTypeInfo: {
            //切换调用
            return CGSizeMake(width , 172 + 20 * 2);
            break;
        }
        case FHBuildingSectionTypeFloor: {
            //动态调整
            return CGSizeMake(width - 15 * 2, 106);
            break;
        }
        case FHBuildingSectionTypeEmpty:
            return CGSizeMake(width, 115 + 40 + 40);
            break;
        default:
            break;
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    FHBuildingSectionModel *sectionModel = self.viewModel.items[section];
    switch (sectionModel.sectionType) {
        case FHBuildingSectionTypeFloor:
            return UIEdgeInsetsMake(20, 15, 20, 15);
            break;
        case FHBuildingSectionTypeInfo:
            if (self.viewModel.locationModel.buildingImage.url.length) {
                return UIEdgeInsetsMake(-41, 0, 0, 0);
            } else {
                return UIEdgeInsetsZero;
            }
            
            break;
        default:
            break;
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    FHBuildingSectionModel *sectionModel = self.viewModel.items[section];
    if (sectionModel.sectionTitle.length) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 23 + 5 * 2);
    }
    return CGSizeZero;
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[FHBuildingDetailFloorCollectionViewCell class]]) {
        // 上报埋点
        FHBuildingSaleStatusModel *saleModel = self.viewModel.locationModel.saleStatusList[self.currentIndex.saleStatus];
        FHBuildingDetailDataItemModel *model = saleModel.buildingList[self.currentIndex.buildingIndex];
        FHBuildingDetailRelatedFloorpanModel *floorpan = model.relatedFloorplanList.list[indexPath.row];
        [self addHouseShow:floorpan.id];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FHBuildingSectionModel *sectionModel = self.viewModel.items[indexPath.section];
    if (sectionModel.sectionType == FHBuildingSectionTypeFloor) {
        FHBuildingSaleStatusModel *saleModel = self.viewModel.locationModel.saleStatusList[self.currentIndex.saleStatus];
        FHBuildingDetailDataItemModel *model = saleModel.buildingList[self.currentIndex.buildingIndex];
        FHBuildingDetailRelatedFloorpanModel *floorModel = model.relatedFloorplanList.list[indexPath.row];
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        [traceParam addEntriesFromDictionary:self.tracerDict];
        traceParam[@"enter_from"] = @"building_detail";
        traceParam[@"log_pb"] = floorModel.logPb?:self.tracerDict[@"log_pb"];
//            traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
//        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(indexPath.row);
//            traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
//        traceParam[@"element_from"] = @"be_null";
        //                    traceParam[@"log_pb"] = model.logPb;
//        NSDictionary *dict = @{@"house_type":@(1),
//                               @"tracer": traceParam
//        };
        
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        [infoDict setValue:floorModel.id forKey:@"floor_plan_id"];
//        [infoDict addEntriesFromDictionary:subPageParams];
        infoDict[@"house_type"] = @(1);
        infoDict[@"tracer"] = traceParam;
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
//    [self.coreInfoListViewModel addStayPageLog:self.ttTrackStayTime];
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - 埋点
- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:self.tracerDict];
//    params[kFHClueExtraInfo] = self.extraInfo;
    if (self.houseId.length) {
        params[@"group_id"] = self.houseId;
    }
    params[@"event_tracking_id"] = @"70950";
    [FHUserTracker writeEvent:@"go_detail" params:params];
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone baseParams:(NSDictionary *)dic
{
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDic = dic.mutableCopy;
        tracerDic[@"is_im"] = contactPhone.imOpenUrl.length ? @"1" : @"0";
        tracerDic[@"is_call"] = contactPhone.enablePhone ? @"1" : @"0";
        tracerDic[@"is_report"] = contactPhone.enablePhone ? @"0" : @"1";
        tracerDic[@"is_online"] = contactPhone.unregistered ? @"1" : @"0";
        tracerDic[@"element_from"] = @"building";
        tracerDic[@"event_tracking_id"] = @"70952";
        TRACK_EVENT(@"lead_show", tracerDic);
    }
}

- (NSMutableArray *)showHouseCache {
    if (!_showHouseCache) {
        _showHouseCache = [NSMutableArray array];
    }
    return _showHouseCache;
}

- (void)addHouseShow:(NSString *)group_id {
    if (!group_id) {
        return;
    }
    if ([self.showHouseCache containsObject:group_id]) {
        return;
    }
    [self.showHouseCache addObject:group_id];
    NSMutableDictionary *tracerDic = self.tracerDict.mutableCopy;
    tracerDic[@"house_type"] = @"house_model";
    tracerDic[@"event_tracking_id"] = @"70955";
    tracerDic[@"group_id"] = group_id?:@"";
    TRACK_EVENT(@"house_show", tracerDic);
}

- (void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:self.tracerDict];
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    //    params[kFHClueExtraInfo] = self.extraInfo;
    //    if(self.houseType == FHHouseTypeSecondHandHouse){
    //        params[@"biz_trace"] = self.houseInfoOriginBizTrace;
    //    }
    [FHUserTracker writeEvent:@"stay_page" params:params];
}

- (void)addClickOptions:(FHBuildingDetailOperatType)type withIndexModel:(FHBuildingIndexModel *)indexModel {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:self.tracerDict];
    params[@"element_type"] = @"building";
    if (self.houseId.length) {
        params[@"group_id"] = self.houseId;
    }
    NSString *clickPosition = @"null";
    switch (type) {
        case FHBuildingDetailOperatTypeSaleStatus:
            clickPosition = self.viewModel.locationModel.saleStatusContents[indexModel.saleStatus];
            break;
        case FHBuildingDetailOperatTypeButton:
            clickPosition = @"图片tag";
            break;
        default:
            break;
    }
    params[@"click_position"] = clickPosition;
    [FHUserTracker writeEvent:@"click_options" params:params];
}

@end

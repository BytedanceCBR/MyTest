//
//  FHHouseFindHelpViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindHelpViewModel.h"
#import "FHHouseFindHelpBottomView.h"
#import "FHHouseFindHeaderView.h"
#import "FHHouseFindHelpRegionCell.h"
#import "FHHouseFindPriceCell.h"
#import "FHHouseFindTextItemCell.h"
#import <FHHouseBase/FHEnvContext.h>
#import "FHHouseFindSelectModel.h"
#import <FHHouseBase/FHHouseType.h>

#define HELP_HEADER_ID @"header_id"
#define HELP_ITEM_HOR_MARGIN 20
#define HELP_MAIN_CELL_ID @"main_cell_id"
#define HELP_REGION_CELL_ID @"region_cell_id"
#define HELP_PRICE_CELL_ID @"price_cell_id"
#define HELP_NORMAL_CELL_ID @"normal_cell_id"

@interface FHHouseFindHelpViewModel ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) FHHouseFindHelpBottomView *bottomView;
@property (nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *secondFilter;
@property (nonatomic , strong) RACDisposable *configDisposable;
@property (nonatomic , assign) BOOL available;
@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) NSMutableDictionary *selectMap; // housetype : FHHouseFindSelectModel

@end

@implementation FHHouseFindHelpViewModel

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView bottomView:(FHHouseFindHelpBottomView *)bottomView
{
    self = [super init];
    if (self) {
        _houseType = FHHouseTypeSecondHandHouse;
        _collectionView = collectionView;
        _bottomView = bottomView;
        [self registerCell:collectionView];
        collectionView.delegate = self;
        collectionView.dataSource = self;
//        collectionView.allowsSelection = NO;
        
        __weak typeof(self)wself = self;
        _bottomView.resetBlock = ^{
            [wself resetBtnDidClick];
        };
        _bottomView.confirmBlock = ^{
            [wself confirmBtnDidClick];
        };
        [self setupHouseContent:nil];
        
//        RACDisposable *disposable = [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(FHConfigDataModel * _Nullable x) {
//            if (x) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [wself setupHouseContent:x];
//                });
//            }
//        }];
//        self.configDisposable = disposable;
    }
    return self;
}

- (void)resetBtnDidClick
{
    
}

- (void)confirmBtnDidClick
{
    
}

-(void)setupHouseContent:(FHConfigDataModel *)configData
{
    if (!configData) {
        configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    }
    
    self.secondFilter = nil;
    
    if (!configData) {
        //show no data
        if (self.showNoDataBlock) {
            self.showNoDataBlock(YES,NO);
        }
    }else{
        
        BOOL avaiable = configData.cityAvailability.enable.boolValue;
        if (self.showNoDataBlock) {
            self.showNoDataBlock(NO,avaiable);
        }
        self.available = avaiable;
        
        if (!avaiable) {
            return;
        }
        self.secondFilter = configData.searchTabFilter;
        
        [self.collectionView reloadData];
    }
}

- (NSArray<FHSearchFilterConfigItem *> *)filterOfHouseType:(FHHouseType) ht
{
    switch (ht) {
        case FHHouseTypeSecondHandHouse:
            return _secondFilter;
        default:
            break;
    }
    return nil;
}

- (FHHouseFindSelectModel *)selectModelWithType:(FHHouseType)ht
{
    FHHouseFindSelectModel *model = self.selectMap[@(ht)];
    if (!model) {
        model = [[FHHouseFindSelectModel alloc] init];
        self.selectMap[@(ht)] = model;
    }
    return model;
}

#pragma mark - UICollectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *filter = [self filterOfHouseType:_houseType];
    if (filter.count > section) {
        FHSearchFilterConfigItem *item = filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
            return 1;
        }
        FHSearchFilterConfigOption *options = [item.options firstObject];
        return options.options.count;
    }
    return 10;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    FHHouseType ht = _houseType;
    NSArray *filter = [self filterOfHouseType:ht];
    // add by zjing for test
    FHHouseFindHelpRegionCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_REGION_CELL_ID forIndexPath:indexPath];
    return pcell;

    if (filter.count > section) {

        FHHouseFindSelectModel *model = [self selectModelWithType:ht];
        FHSearchFilterConfigItem *item = filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {

            FHHouseFindPriceCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_PRICE_CELL_ID forIndexPath:indexPath];
            pcell.tag = ht;
            pcell.delegate = self;

            FHHouseFindSelectItemModel *priceItem = [model selectItemWithTabId:FHSearchTabIdTypePrice];
            if (!priceItem) {
                priceItem = [model makeItemWithTabId:FHSearchTabIdTypePrice];
                priceItem.rate = item.rate;
                priceItem.configOption = [item.options firstObject];
            }else{
                priceItem.rate = item.rate;
                priceItem.configOption = [item.options firstObject];
            }
            if (priceItem) {
                [pcell updateWithLowerPrice:priceItem.lowerPrice higherPrice:priceItem.higherPrice];
            }

            return pcell;

        }else{

            FHHouseFindTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:HELP_NORMAL_CELL_ID forIndexPath:indexPath];
            NSString *text = nil;

            FHSearchFilterConfigOption *options = [item.options firstObject];
            if (options.options.count > indexPath.item) {
                FHSearchFilterConfigOption *option = options.options[indexPath.item];
                text = option.text;
            }else{
                text = options.text;
            }

            BOOL selected = NO;

            if (model) {
                FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
                selected = [model selecteItem:selectItem containIndex:indexPath.item];
            }

            [tcell updateWithTitle:text highlighted:selected];

            return tcell;
        }

    }
    return [[UICollectionViewCell alloc] init];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HELP_HEADER_ID forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [headerView updateTitle:@"您的购房预算是多少？" showDelete:NO];
    }else if (indexPath.section == 1) {
        
        [headerView updateTitle:@"您想买的户型是？" showDelete:NO];
//        NSInteger section = indexPath.section;
//        if (histories.count > 0) {
//            section -= 1;
//        }
//        NSArray *filter = [self filterOfHouseType:ht];
//        if (filter.count > section) {
//            FHSearchFilterConfigItem *item =  filter[section];
//            [headerView updateTitle:item.text showDelete:NO];
//        }else{
//            return nil;
//        }
    }else if (indexPath.section == 2) {
        
        [headerView updateTitle:@"您想买的区域是？" showDelete:NO];

    }else if (indexPath.section == 3) {
        
        [headerView updateTitle:@"您的联系方式？" showDelete:NO];
    }
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // add by zjing for test
    return CGSizeMake(collectionView.frame.size.width, 36);

    FHHouseType ht = _houseType;
    NSInteger section = indexPath.section;
    NSArray *filter = [self filterOfHouseType:ht];
    if (filter.count > section) {
        FHSearchFilterConfigItem *item =  filter[section];
        if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
            return CGSizeMake(collectionView.frame.size.width - 2*HELP_ITEM_HOR_MARGIN, 36);
        }else{
            return CGSizeMake(74, 30);
        }
    }
    return CGSizeMake(collectionView.frame.size.width, 60);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    FHHouseType ht = collectionView.tag;
//    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
//
//    NSArray *filter = [self filterOfHouseType:ht];
//    NSArray *histories = self.historyMap[@(ht)];
//
//    NSInteger section = indexPath.section;
//    if (histories.count > 0) {
//        section -= 1;
//    }
//
//    if (filter.count > section) {
//
//        FHSearchFilterConfigItem *item = filter[section];
//
//        FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
//        if (!selectItem) {
//            selectItem = [model makeItemWithTabId:item.tabId.integerValue];
//        }
//        if (!selectItem.configOption) {
//            selectItem.configOption = [item.options firstObject];
//        }
//
//        if([model selecteItem:selectItem containIndex:indexPath.item]){
//            //反选
//            [model delSelecteItem:selectItem withIndex:indexPath.item];
//        }else{
//            //添加选择
//            FHSearchFilterConfigOption *option = nil;
//            if (item.options.count > 0) {
//                option = [item.options firstObject];
//            }
//            if ([option.supportMulti boolValue]) {
//                [model addSelecteItem:selectItem withIndex:indexPath.item];
//            }else{
//                [model clearAddSelecteItem:selectItem withIndex:indexPath.item];
//            }
//        }
//
//        [CATransaction begin ];
//        [CATransaction setDisableActions:YES];
//        //        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
//        [CATransaction commit];
//    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return UIEdgeInsetsZero;
    }
    //    FHHouseType ht = collectionView.tag;
    //    NSArray *histories = self.historyMap[@(ht)];
    //
    //    if (section == 0 && histories.count > 0) {
    //        return UIEdgeInsetsZero;
    //    }
    
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 13;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height = 68;
    if (section == 0) {
        height -= 10;
    }
    
    return CGSizeMake(collectionView.frame.size.width - 2*HELP_ITEM_HOR_MARGIN, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.collectionView endEditing:YES];
}

- (void)registerCell:(UICollectionView *)collectionview
{
    [collectionview registerClass:[FHHouseFindHelpRegionCell class] forCellWithReuseIdentifier:HELP_REGION_CELL_ID];
    [collectionview registerClass:[FHHouseFindPriceCell class] forCellWithReuseIdentifier:HELP_PRICE_CELL_ID];
    [collectionview registerClass:[FHHouseFindTextItemCell class] forCellWithReuseIdentifier:HELP_NORMAL_CELL_ID];
    
    [collectionview registerClass:[FHHouseFindHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HELP_HEADER_ID];
}

-(void)dealloc
{
    [self.configDisposable dispose];
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

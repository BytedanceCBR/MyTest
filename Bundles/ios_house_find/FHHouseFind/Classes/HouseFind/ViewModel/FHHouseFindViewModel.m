//
//  FHHouseFindViewModel.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindViewModel.h"
#import <FHHouseBase/FHEnvContext.h>
#import <FHCommonUI/HMSegmentedControl.h>
#import <FHHouseBase/FHHouseType.h>
#import "FHHouseFindMainCell.h"
#import "FHHouseFindHeaderView.h"
#import "FHHouseFindHistoryCell.h"
#import "FHHouseFindPriceCell.h"
#import "FHHouseFindTextItemCell.h"
#import "FHHouseFindSelectModel.h"
#import <FHHouseList/FHHouseListAPI.h>
#import "FHMainApi+HouseFind.h"
#import <TTRoute/TTRoute.h>
#import <FHHouseBase/FHEnvContext.h>
#import <TTReachability/TTReachability.h>
#import <FHCommonUI/ToastManager.h>
#import <FHHouseBase/FHUserTracker.h>

#define MAIN_CELL_ID @"main_cell_id"
#define HEADER_ID @"header_id"
#define HISTORY_CELL_ID @"history_cell_id"
#define PRICE_CELL_ID @"price_cell_id"
#define NORMAL_CELL_ID @"normal_cell_id"

#define ITEM_HOR_MARGIN 20

@interface FHHouseFindViewModel()<UICollectionViewDataSource,UICollectionViewDelegate,
                            FHHouseFindPriceCellDelegate,FHHouseFindHistoryCellDelegate,
                            FHHouseFindMainCellDelegate>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) HMSegmentedControl *segmentControl;

@property (nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *secondFilter;
@property (nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *rentFilter;
@property (nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *courtFilter;
@property (nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *neighborhoodFilter;
@property (nonatomic , strong) NSArray *houseTypes;
@property (nonatomic , strong) NSMutableDictionary *selectMap; // housetype : FHHouseFindSelectModel
@property (nonatomic , strong) NSMutableDictionary *historyMap;// housetype : [history]
@property (nonatomic , strong) NSMutableDictionary *historyTracerMap; // housetype : [history record]
@property (nonatomic , strong) RACDisposable *configDisposable;
@property (nonatomic , assign) BOOL networkConnected;
@property (nonatomic , assign) BOOL available ;
@property (nonatomic , assign) BOOL showNotworkConnected;

@end

@implementation FHHouseFindViewModel

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView segmentControl:(HMSegmentedControl *)segmentControl
{
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _segmentControl = segmentControl;
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.allowsSelection = NO;
     
        [collectionView registerClass:[FHHouseFindMainCell class] forCellWithReuseIdentifier:MAIN_CELL_ID];
        
        _selectMap = [NSMutableDictionary new];
        _historyMap = [NSMutableDictionary new];
        _historyTracerMap = [NSMutableDictionary new];
        
        __weak typeof(self) wself = self;
        _segmentControl.indexChangeBlock = ^(NSInteger index) {
            [wself.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        };
        
//        __block BOOL isFirstChange = YES;
        RACDisposable *disposable = [[[FHEnvContext sharedInstance].configDataReplay skip:1] subscribeNext:^(FHConfigDataModel * _Nullable x) {
            //过滤多余刷新
//            if ([[FHEnvContext sharedInstance] getConfigFromCache] && !isFirstChange) {
//                return;
//            }
            //城市更新 重新刷新
            if (x) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself setupHouseContent:x];
                });
            }
//            isFirstChange = NO;
            
        }];
        self.configDisposable = disposable;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
        
        _networkConnected = [TTReachability isNetworkConnected];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        tapGesture.cancelsTouchesInView = NO;
        [collectionView addGestureRecognizer:tapGesture];
        
        self.available = YES;
        _showNotworkConnected = !_networkConnected;
        
    }
    return self;
}

-(void)dealloc
{
    [self.configDisposable dispose];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)onTap
{
    [self.collectionView endEditing:YES];
}

-(void)showSearchHouse
{
    FHHouseType ht = [self currentHouseType];
    FHHouseFindSelectModel *selectModel = [self selectModelWithType:ht];
    NSMutableString *query = [NSMutableString new];
    if (selectModel.items.count > 0) {
        for (FHHouseFindSelectItemModel *item in selectModel.items ) {
            NSString *q = [item selectQuery];
            if (!q) {
#if DEBUG
                NSLog(@"WARNING select query is nil for item : %@",item);
#endif
                continue;
            }
            if (query.length > 0) {
                [query appendString:@"&"];
            }
            [query appendString:q];
        }
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://house_list?house_type=%d&%@",ht,query];
    
    NSDictionary *tracerParam =
        @{
          @"origin_from":@"findtab_find",
          @"enter_from":@"findtab",
          @"element_from":@"findtab_find",
          @"enter_type":@"click",
          @"page_type":[self pageType:ht]
          };
    NSDictionary *houseSearchParam =
        @{
          @"page_type":[self pageType:ht],
          @"query_type":@"filter",
          @"enter_query":@"be_null",
          @"search_query":@"be_null",
          };
    
    NSDictionary *userInfoDict = @{@"tracer":tracerParam,@"houseSearch":houseSearchParam};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
}

-(void)viewWillAppear
{
    if (self.houseTypes.count > self.segmentControl.selectedSegmentIndex ) {
        FHHouseType ht =  [self.houseTypes[self.segmentControl.selectedSegmentIndex] integerValue];
        [self requestHistory:ht];
    }
    [self startTrack];
    if (!_networkConnected) {
        self.searchButton.hidden = YES;
    }
}

-(void)viewWillDisappear
{
    [self endTrack];
    [self addStayCategoryLog];
}

-(void)setupHouseContent:(FHConfigDataModel *)configData
{
    if (!configData) {
        configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    }
        
    [self.historyMap removeAllObjects];
    [self.selectMap removeAllObjects];
    self.houseTypes = nil;
    self.secondFilter = nil;
    self.courtFilter = nil;
    self.rentFilter = nil;
    self.neighborhoodFilter = nil;
    
    if (!configData) {
        //show no data
        if (self.showNoDataBlock) {
            self.showNoDataBlock(YES,NO);
        }
    }else{
        
        BOOL avaiable = configData.cityAvailability.enable.boolValue;
        
        NSMutableArray *titles = [NSMutableArray new];
        NSMutableArray *houseTypes = [NSMutableArray new];
        if (configData.searchTabFilter) {
            [titles addObject:@"二手房"];
            [houseTypes addObject:@(FHHouseTypeSecondHandHouse)];
        }
        if (configData.searchTabRentFilter) {
            [titles addObject:@"租房"];
            [houseTypes addObject:@(FHHouseTypeRentHouse)];
        }
        if (configData.searchTabCourtFilter) {
            [titles addObject:@"新房"];
            [houseTypes addObject:@(FHHouseTypeNewHouse)];
        }
        if (configData.searchTabNeighborhoodFilter) {
            [titles addObject:@"小区"];
            [houseTypes addObject:@(FHHouseTypeNeighborhood)];
        }
        
        if (avaiable && titles.count == 0) {
            avaiable = NO;
        }
        
        if (self.showNoDataBlock) {
            self.showNoDataBlock(NO,avaiable);
        }
        self.available = avaiable;
        
        if (!avaiable) {
            return;
        }
        
        if (!_networkConnected) {
            self.searchButton.hidden = YES;
        }
        
        self.secondFilter = configData.searchTabFilter;
        self.rentFilter = configData.searchTabRentFilter;
        self.courtFilter = configData.searchTabCourtFilter;
        self.neighborhoodFilter = configData.searchTabNeighborhoodFilter;
        
        self.segmentControl.sectionTitles = titles;
        if (titles.count > 0) {
            [self.segmentControl setSelectedSegmentIndex:0];
        }
        self.houseTypes = houseTypes;
        
        [self.collectionView reloadData];
        
        if (houseTypes.count > 0) {
            if (self.collectionView.contentOffset.x >= self.collectionView.frame.size.width/2) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            }
        }
        
        if (self.updateSegmentWidthBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.updateSegmentWidthBlock();
            });
        }
        
    }
}

-(FHHouseType)currentHouseType
{
    return [_houseTypes[_segmentControl.selectedSegmentIndex] integerValue];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.collectionView) {
        return 1;
    }else{
        FHHouseType ht = collectionView.tag;
        NSArray *filter = [self filterOfHouseType:ht];
        NSArray *histories = self.historyMap[@(ht)];
        return filter.count + (histories.count>0?1:0);
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return _houseTypes.count;
    }else{
        FHHouseType ht = collectionView.tag;
        NSArray *histories = self.historyMap[@(ht)];
        if (section == 0 && histories.count > 0) {
            return 1;
        }
        if (histories.count > 0) {
            section -= 1;
        }
        NSArray *filter = [self filterOfHouseType:ht];
        if (filter.count > section) {
            FHSearchFilterConfigItem *item = filter[section];
            if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
                return 1;
            }
            FHSearchFilterConfigOption *options = [item.options firstObject];
            return options.options.count;
        }
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        
        FHHouseFindMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MAIN_CELL_ID forIndexPath:indexPath];
        cell.collectionView.tag = [self.houseTypes[indexPath.item] integerValue];
        if (!cell.delegate) {
            cell.delegate = self;
        }
        
        [cell showErrorView:_showNotworkConnected];
        
        return cell;
        
    }else{
      
        FHHouseType ht = collectionView.tag;
        NSArray *histories = self.historyMap[@(ht)];
        
        if (indexPath.section == 0 && histories.count > 0) {
            //history
            FHHouseFindHistoryCell *hcell = [collectionView dequeueReusableCellWithReuseIdentifier:HISTORY_CELL_ID forIndexPath:indexPath];
            hcell.delegate = self;
            hcell.tag = ht;
            [hcell updateWithItems:histories];
            return hcell;
        }
        NSInteger section = indexPath.section;
        if (histories.count > 0) {
            section -= 1;
        }
        
        NSArray *filter = [self filterOfHouseType:ht];
        if (filter.count > section) {
            
            FHHouseFindSelectModel *model = [self selectModelWithType:ht];            
            FHSearchFilterConfigItem *item = filter[section];
            if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
                
                FHHouseFindPriceCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:PRICE_CELL_ID forIndexPath:indexPath];
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
                
                FHHouseFindTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:NORMAL_CELL_ID forIndexPath:indexPath];
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
        
    }
    return [[UICollectionViewCell alloc] init];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        return nil;
    }else if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        FHHouseFindHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
        FHHouseType ht = collectionView.tag;
        headerView.tag = ht;
        if (!headerView.deleteBlock) {
            __weak typeof(self) wself = self;
            headerView.deleteBlock = ^(FHHouseFindHeaderView * _Nonnull headerView) {
                [wself clearHistoryOfHouseType:headerView.tag];
            };
        }
        NSArray *histories = self.historyMap[@(ht)];
        if (indexPath.section == 0 && histories.count > 0) {
            [headerView updateTitle:@"搜索历史" showDelete:YES];
        }else{
            NSInteger section = indexPath.section;
            if (histories.count > 0) {
                section -= 1;
            }
            NSArray *filter = [self filterOfHouseType:ht];
            if (filter.count > section) {
                FHSearchFilterConfigItem *item =  filter[section];
                [headerView updateTitle:item.text showDelete:NO];
            }else{
                return nil;
            }                        
        }
        
        return headerView;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        FHHouseFindMainCell *fcell = (FHHouseFindMainCell *)cell;
        if (!fcell.collectionView.dataSource) {
            fcell.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 130, 0);
            [self registerCell:fcell.collectionView];
            fcell.collectionView.delegate = self;
            fcell.collectionView.dataSource = self;
            fcell.collectionView.clipsToBounds = YES;
        }
        
        FHHouseType ht = [self.houseTypes[indexPath.item] integerValue];
        NSArray *histories = self.historyMap[@(ht)];
        if (histories.count == 0) {
            //因为cell 可能会复用，每次请求时再次判断一下
            [self requestHistory:ht];
        }
        
        [fcell.collectionView reloadData];
        //切换时滑动到顶部
        fcell.collectionView.contentOffset = CGPointZero;
        self.splitLine.hidden = YES;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        return self.collectionView.frame.size;
    }else{
        FHHouseType ht = collectionView.tag;
        NSArray *histories = self.historyMap[@(ht)];
        
        if (indexPath.section == 0 && histories.count > 0) {
            //history
            return CGSizeMake(collectionView.frame.size.width - 2*ITEM_HOR_MARGIN, 60);
        }
        
        NSInteger section = indexPath.section;
        if (histories.count > 0) {
            section -= 1;
        }
        NSArray *filter = [self filterOfHouseType:ht];
        if (filter.count > section) {
            FHSearchFilterConfigItem *item =  filter[section];
            if ([item.tabId integerValue] == FHSearchTabIdTypePrice) {
                return CGSizeMake(collectionView.frame.size.width - 2*ITEM_HOR_MARGIN, 36);
            }else{
                return CGSizeMake(74, 30);
            }
        }
        
    }
    return CGSizeMake(collectionView.frame.size.width, 60);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionView) {
        return;
    }
    
    FHHouseType ht = collectionView.tag;
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    
    NSArray *filter = [self filterOfHouseType:ht];
    NSArray *histories = self.historyMap[@(ht)];
    
    NSInteger section = indexPath.section;
    if (histories.count > 0) {
        section -= 1;
    }
    
    if (filter.count > section) {
        
        FHSearchFilterConfigItem *item = filter[section];

        FHHouseFindSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue]];
        if (!selectItem) {
            selectItem = [model makeItemWithTabId:item.tabId.integerValue];
        }
        if (!selectItem.configOption) {
            selectItem.configOption = [item.options firstObject];
        }
        
        if([model selecteItem:selectItem containIndex:indexPath.item]){
            //反选
            [model delSelecteItem:selectItem withIndex:indexPath.item];
        }else{
            //添加选择
            FHSearchFilterConfigOption *option = nil;
            if (item.options.count > 0) {
                option = [item.options firstObject];
            }
            if (option.supportMulti) {
                [model addSelecteItem:selectItem withIndex:indexPath.item];
            }else{
                [model clearAddSelecteItem:selectItem withIndex:indexPath.item];
            }
        }
        
        [CATransaction begin ];
        [CATransaction setDisableActions:YES];
//        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        [CATransaction commit];
    }
    
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
    if (collectionView == self.collectionView) {
        return 0;
    }
    return 13;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (collectionView == self.collectionView) {
        return CGSizeZero;
    }
    CGFloat height = 68;
    if (section == 0) {
        height -= 10;
    }
    
    return CGSizeMake(collectionView.frame.size.width - 2*ITEM_HOR_MARGIN, height);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.collectionView endEditing:YES];
    if (self.collectionView != scrollView) {
        [self checkNeedShowSplitLine:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        NSInteger index = (scrollView.contentOffset.x + scrollView.frame.size.width*0.4) / scrollView.frame.size.width;
        if (self.segmentControl.selectedSegmentIndex != index) {
            [self.segmentControl setSelectedSegmentIndex:index animated:YES];
        }
        FHHouseFindMainCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [self checkNeedShowSplitLine:cell.collectionView];
    }
}

-(void)checkNeedShowSplitLine:(UIScrollView *)scrollView
{
    self.splitLine.hidden = ( scrollView.contentOffset.y < 10);
}


-(void)registerCell:(UICollectionView *)collectionview
{
    [collectionview registerClass:[FHHouseFindHistoryCell class] forCellWithReuseIdentifier:HISTORY_CELL_ID];
    [collectionview registerClass:[FHHouseFindPriceCell class] forCellWithReuseIdentifier:PRICE_CELL_ID];
    [collectionview registerClass:[FHHouseFindTextItemCell class] forCellWithReuseIdentifier:NORMAL_CELL_ID];
    
    [collectionview registerClass:[FHHouseFindHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
}

#pragma mark - price cell delegate
-(void)updateLowerPrice:(NSNumber *)price inCell:(FHHouseFindPriceCell *)cell
{
    FHHouseType ht = cell.tag;
    FHHouseFindSelectItemModel *priceItem = [self priceItemWithHouseType:ht];
    
    priceItem.lowerPrice = price;
}

-(void)updateHigherPrice:(NSNumber *)price inCell:(FHHouseFindPriceCell *)cell
{
    FHHouseType ht = cell.tag;
    FHHouseFindSelectItemModel *priceItem = [self priceItemWithHouseType:ht];
    
    priceItem.higherPrice = price;
}

-(FHHouseFindSelectItemModel *)priceItemWithHouseType:(FHHouseType)ht
{
    FHHouseFindSelectModel *model = [self selectModelWithType:ht];
    
    FHHouseFindSelectItemModel *priceItem = [model selectItemWithTabId:FHSearchTabIdTypePrice];
    if (!priceItem) {
        priceItem = [model makeItemWithTabId:FHSearchTabIdTypePrice];
        
    }
    return priceItem;
}

-(FHHouseFindSelectModel *)selectModelWithType:(FHHouseType)ht
{
    FHHouseFindSelectModel *model = self.selectMap[@(ht)];
    if (!model) {
        model = [[FHHouseFindSelectModel alloc] init];
        self.selectMap[@(ht)] = model;
    }
    return model;
}

-(FHHouseFindSelectModel *)selectModelWithHouseType:(FHHouseType)ht
{
    FHHouseFindSelectModel *model = self.selectMap[@(ht)];
    if (!model) {
        model = [[FHHouseFindSelectModel alloc] init];
        self.selectMap[@(ht)] = model;
    }
    return model;
}

-(void)showSugPage
{
    FHHouseType ht = [self currentHouseType];
    
    NSDictionary *tracerParam =
        @{
          @"origin_from":@"findtab_search",
          @"enter_type":@"click",
          @"element_from":@"findtab_search",
          @"enter_from":@"findtab",
//          @"log_pb":@"be_null",
          @"origin_from":@"findtab_search"
          };
    NSDictionary *param =
        @{
          @"house_type":[@(ht) description],
          @"tracer":tracerParam,
          @"from_home":@"2"
          };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:param];
    NSURL *url = [NSURL URLWithString:@"sslocal://sug_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

#pragma mark - history delegate
-(void)selectHistory:(FHHFHistoryDataDataModel *)model
{
    if(model.openUrl.length == 0 ){
        return;
    }
    
    NSMutableString *openUrl = [[NSMutableString alloc] initWithString:model.openUrl];
    NSString *placeholder = [model.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (placeholder.length > 0) {
        [openUrl appendFormat:@"&placeholder=%@",placeholder];
    }
    
    FHHouseType ht = [self.houseTypes[self.segmentControl.selectedSegmentIndex] integerValue];
    
    NSDictionary *houseSearchParam =
        @{@"page_type":[self pageType:ht],
          @"query_type":@"history",
          @"enter_query":model.text?:@"",
          @"search_query":model.text?:@""
          };
    NSDictionary *tracerParam =
        @{
          @"origin_from":@"findtab_search",
          @"enter_from":@"findtab",
          @"element_from":@"findtab_search",
          @"enter_type":@"click"
          };
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"tracer"] = tracerParam;
    params[@"houseSearch"] = houseSearchParam;
    if (model.extinfo) {
        params[@"suggestion"] = model.extinfo;
    }
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:params];
    NSURL *url = [NSURL URLWithString:openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)willShowHistory:(FHHFHistoryDataDataModel *)model rank:(NSInteger)rank houseType:(FHHouseType)houseType
{
    NSMutableSet *records = _historyTracerMap[@(houseType)];
    if (!records) {
        records = [NSMutableSet new];
        _historyTracerMap[@(houseType)] = records;
    }
    
    if ([records containsObject:@(rank)]) {
        return;
    }
    
    [records addObject:@(rank)];
    
    
    NSDictionary *param =
        @{
          @"history_id":model.historyId?:@"",
          @"rank" : @(rank),
          @"show_type":@"slide",
          @"word":model.text?:@""
          };
    
    [FHUserTracker writeEvent:@"search_history_show" params:param];
    
}

-(NSArray<FHSearchFilterConfigItem *> *)filterOfHouseType:(FHHouseType) ht
{
    switch (ht) {
        case FHHouseTypeSecondHandHouse:
            return _secondFilter;
        case FHHouseTypeNewHouse:
            return _courtFilter;
        case FHHouseTypeRentHouse:
            return _rentFilter;
        case FHHouseTypeNeighborhood:
            return _neighborhoodFilter;
        default:
            break;
    }
    return nil;
}

-(NSString *)pageType:(FHHouseType)ht
{
    switch (ht) {
        case FHHouseTypeNewHouse:
            return @"findtab_new";
        case FHHouseTypeNeighborhood:
            return @"findtab_neighborhood";
        case FHHouseTypeRentHouse:
            return @"findtab_rent";
        case FHHouseTypeSecondHandHouse:
        default:
            return @"findtab_old";
            break;
    }
}

#pragma mark - network
-(void)connectionChanged:(NSNotification *)notification
{
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
//    if ((status != NotReachable) != _networkConnected) {
//        //网络发生变化
//        _networkConnected = !_networkConnected;
//        [self.collectionView reloadData];
//    }
//    self.searchButton.hidden = !_networkConnected;
    _networkConnected = (status != NotReachable);
    if (status != NotReachable && _houseTypes.count > 0) {
        self.showNotworkConnected = NO;
        [self.collectionView reloadData];
        self.searchButton.hidden = NO;
        
    }

}

-(void)refreshInErrorView:(FHHouseFindMainCell *)cell
{
    if (![TTReachability isNetworkConnected]) {
        return;
    }
    _networkConnected = YES;
    [self.collectionView reloadData];
}

#pragma mark - request
-(void)requestHistory:(FHHouseType)housetype
{    
    __weak typeof(self) wself = self;
    [FHMainApi requestHFHistoryByHouseType:[@(housetype) description] completion:^(FHHFHistoryModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (!wself) {
            return ;
        }
        
        wself.historyTracerMap[@(housetype)] = nil;
        
        __strong typeof(self) sself = wself;
        
        if (model) {
            sself.historyMap[@(housetype)] = model.data.data;
//            if ([sself currentHouseType] == housetype ) {
                //加载的当前是一种类型
                [sself reloadContentOfHouseType:housetype];
                
//                [sself.collectionView reloadData];
//            }
        }
#if DEBUG
        else if (error){
            NSLog(@"get history error : %@",error);
        }
#endif
        
        
    }];
}

-(void)clearHistoryOfHouseType:(FHHouseType)ht
{
    if (![TTReachability isNetworkConnected]) {
        
        SHOW_TOAST(@"网络异常");
        return;
    }
    
    __weak typeof(self) wself = self;
    [FHMainApi clearHFHistoryByHouseType:[@(ht) description] completion:^(FHFHClearHistoryModel * _Nonnull model, NSError * _Nonnull error) {
        if (!wself) {
            return ;
        }
        if (!error) {
            wself.historyMap[@(ht)] = nil;
            if ([wself currentHouseType] == ht ) {
                //加载的当前是一种类型
                [wself.collectionView reloadData];
            }
        }else{
            SHOW_TOAST(@"历史记录删除失败");
        }
    }];
    
}

-(void)reloadContentOfHouseType:(FHHouseType)ht
{
    NSInteger index = [self.houseTypes indexOfObject:@(ht)];
    if (index >= 0) {
        FHHouseFindMainCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (cell) {
            [cell.collectionView reloadData];
            [cell.collectionView setContentOffset:CGPointZero animated:YES];
        }
    }
}

#pragma mark - user track
- (void)addStayCategoryLog
{
    NSInteger duration = (NSInteger)(self.trackStayTime * 1000.0);
    if (duration <= 0) {//当前页面没有在展示过
        return;
    }

    NSDictionary *tracerDict =
        @{
          @"stay_time":@(duration),
          @"tab_name":@"find",
          @"enter_type":@"click_tab",
          @"with_tips":@"0"
          };
    [FHUserTracker writeEvent:@"stay_tab" params:tracerDict];
}

- (void)resetStayTime
{
    self.trackStayTime = 0;
}

- (void)startTrack
{
    self.trackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)endTrack
{
    self.trackStayTime += [[NSDate date] timeIntervalSince1970] - self.trackStartTime;
}

@end

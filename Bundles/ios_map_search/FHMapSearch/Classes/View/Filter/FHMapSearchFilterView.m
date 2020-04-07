//
//  FHMapSearchFilterView.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHMapSearchFilterView.h"
#import "FHMapSearchPriceCell.h"
#import "FHMapSearchTextItemCell.h"
#import "FHMapSearchFilterHeaderView.h"
#import <Masonry/Masonry.h>

#import "FHSearchConfigModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIViewAdditions.h"
#import <FHHouseBase/FHBaseCollectionView.h>

#define PRICE_CELL_ID  @"price_cell_id"
#define NORMAL_CELL_ID @"normal_cell_id"
#define HEADER_ID      @"header_id"

#define PRICE_TYPE @"price"


#define CONTAINER_WIDTH      271
#define BOTTOM_BAR_HEIGHT    60
#define BOTTOM_BUTTON_WIDTH  115
#define BOTTOM_BUTTON_HEIGHT 40
#define BOTTOM_BUTTON_HOR_MARGIN 15
#define ITEM_HOR_MARGIN          15

@interface FHMapSearchFilterView ()<UICollectionViewDelegate,UICollectionViewDataSource,FHMapSearchPriceCellDelegate>

@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) UIControl *leftControl;
@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) UIView *bottomBar;
@property(nonatomic , strong) UIButton *resetButton;
@property(nonatomic , strong) UIButton *confirmButton;
@property(nonatomic , strong) NSArray<FHSearchFilterConfigOption *> *filter;
@property(nonatomic , strong) NSArray<FHSearchFilterConfigItem *> *originFilter;
@property(nonatomic , strong) FHSearchFilterConfigItem *filterPriceItem;
@property(nonatomic , assign) NSInteger filterPriceSection;
@property(nonatomic , strong) FHMapSearchPriceCell *priceCell ;

@end

@implementation FHMapSearchFilterView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        
        _leftControl = [[UIControl alloc] init];
        _leftControl.backgroundColor = [UIColor clearColor];
        [_leftControl addTarget:self action:@selector(onTouchBlank) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftControl];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - CONTAINER_WIDTH, 0, CONTAINER_WIDTH, CGRectGetHeight(frame))];
        _containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_containerView];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[FHBaseCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, BOTTOM_BAR_HEIGHT+10, 0);
        
        [self registerCell:_collectionView];
        
        [self.containerView addSubview:_collectionView];
        
        [self initBottomBar];
        
        self.selectionModel = [[FHMapSearchSelectModel alloc]init];
        
        [self initConstraints];
    }
    return self;
}

-(void)initBottomBar
{
    _resetButton = [self buttonWithTitle:@"不限条件" titleColor:[UIColor themeGray1] font: [UIFont themeFontRegular:16] bgColor:[UIColor themeGray7] action:@selector(onResetAction)];
    
    _confirmButton = [self buttonWithTitle:@"确定" titleColor:[UIColor whiteColor] font:[UIFont themeFontMedium:16] bgColor:[UIColor themeOrange4] action:@selector(onConfirmAction)];
    
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CONTAINER_WIDTH, BOTTOM_BAR_HEIGHT)];
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_bottomBar.bounds), 0.5)];
    topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topLine.backgroundColor = [UIColor themeGray6];
    
    [_bottomBar addSubview:topLine];
    _bottomBar.backgroundColor = [UIColor whiteColor];
    
    [_bottomBar addSubview:_resetButton];
    [_bottomBar addSubview:_confirmButton];
    
    [_containerView addSubview:_bottomBar];
    
}

-(void)registerCell:(UICollectionView *)collectionview
{
    [collectionview registerClass:[FHMapSearchPriceCell class] forCellWithReuseIdentifier:PRICE_CELL_ID];
    [collectionview registerClass:[FHMapSearchTextItemCell class] forCellWithReuseIdentifier:NORMAL_CELL_ID];
    
    [collectionview registerClass:[FHMapSearchFilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
}

-(void)initConstraints
{
    UIEdgeInsets safeArea = UIEdgeInsetsZero;
    if (@available(iOS 11.0 , *)) {
        safeArea = [UIApplication sharedApplication].delegate.window.safeAreaInsets;
    }
    
    [_leftControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(self.containerView.mas_left);
    }];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(self);
        make.width.mas_equalTo(CONTAINER_WIDTH);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(safeArea.top>0?safeArea.top:20);
        make.bottom.mas_equalTo(-safeArea.bottom);
        make.left.and.right.mas_equalTo(0);
    }];
    
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-safeArea.bottom);
        make.height.mas_equalTo(BOTTOM_BAR_HEIGHT);
    }];
    
    [_resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(BOTTOM_BUTTON_HOR_MARGIN);
        make.size.mas_equalTo(CGSizeMake(BOTTOM_BUTTON_WIDTH, BOTTOM_BUTTON_HEIGHT));
        make.centerY.mas_equalTo(self.bottomBar);
    }];
    
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-BOTTOM_BUTTON_HOR_MARGIN);
        make.size.mas_equalTo(CGSizeMake(BOTTOM_BUTTON_WIDTH, BOTTOM_BUTTON_HEIGHT));
        make.centerY.mas_equalTo(self.bottomBar);
    }];
    
    
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if(self.superview){
        [self.collectionView reloadData];
    }
}

-(UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font bgColor:(UIColor *)bgColor action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    button.backgroundColor = bgColor;
    button.layer.cornerRadius = BOTTOM_BUTTON_HEIGHT/2.0; //4;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

-(void)onTouchBlank
{
    if ([self.priceCell isInEditing]) {
        [self endEditing:YES];
        return;
    }
    [self dismiss:NO];
}

-(void)onResetAction
{
    [self.selectionModel clearAllSection];
    [self.collectionView reloadData];
    if (self.resetBlock) {
        self.resetBlock();
    }
}

-(void)onConfirmAction
{
    NSString *query = [self.selectionModel selectedQuery];
    if (self.confirmWithQueryBlock) {
        self.confirmWithQueryBlock(query);
    }
    [self dismiss:NO];
}

-(void)showInView:(UIView *)view animated:(BOOL)animated
{
    [view addSubview:self];
    if(animated){
        
        CGRect frame = _containerView.frame;
        frame.origin.x = self.width;
        _containerView.frame = frame;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect nframe = frame;
            nframe.origin.x = self.width - CONTAINER_WIDTH;
            self.containerView.frame = nframe;
        } completion:^(BOOL finished) {
            //刷新数据
            [self.collectionView performBatchUpdates:^{
                [self.collectionView reloadData];
                [self.collectionView scrollRectToVisible:CGRectZero animated:YES];
//                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            } completion:nil];
            
        }];
        
    }
}

-(void)dismiss:(BOOL)animated
{
    [self removeFromSuperview];
}

-(void)updateWithFilters:(NSArray *)filters
{
    self.filter = filters;
    [self.collectionView reloadData];
}

-(void)updateWithOldFilter:(NSArray<FHSearchFilterConfigItem> *)filter
{
    NSMutableArray *showFilters = [NSMutableArray new];
    for (FHSearchFilterConfigItem *item in filter) {
        if (item.tabId.integerValue != FHMapSearchTabIdTypeRegion) {
            //把区域排除
            if (item.tabId.integerValue == FHMapSearchTabIdTypePrice) {
                self.filterPriceItem = [item copy];
                for (NSInteger i = 0 ; i < self.filterPriceItem.options.count; i++) {
                    FHSearchFilterConfigOption *option = self.filterPriceItem.options[i];
                    if ([option.type.lowercaseString isEqualToString:PRICE_TYPE]) {
                        self.filterPriceSection = showFilters.count+i;
                        NSMutableArray *priceOptions = [option.options mutableCopy];
                        FHSearchFilterConfigOption *firstOp = [priceOptions firstObject];
                        if([firstOp.type isEqualToString:@"empty"]){
                            [priceOptions removeObjectAtIndex:0];
                            option.options = (NSArray<FHSearchFilterConfigOption> *) priceOptions;
                        }
                    }
                }
                [showFilters addObjectsFromArray:self.filterPriceItem.options];
            }else{
                [showFilters addObjectsFromArray:item.options];
            }
        }
    }
    self.filter = showFilters;
    self.originFilter = filter;
    [self.collectionView reloadData];
}

-(void)updateWithRentFilter:(NSArray<FHSearchFilterConfigItem> *)filter
{
    [self updateWithOldFilter:filter];
    //    NSMutableArray *showFilters = [NSMutableArray new];
    //    for (FHSearchFilterConfigItem *item in filter) {
    //        if (item.tabId.integerValue != FHMapSearchTabIdTypeRegion) {
    //            //把区域排除
    //            if (item.tabId.integerValue == FHMapSearchTabIdTypePrice) {
    //                for (NSInteger i = 0 ; i < item.options.count; i++) {
    //                    FHSearchFilterConfigOption *option = item.options[i];
    //                    if ([option.type.lowercaseString isEqualToString:@"price"]) {
    //                        self.filterPriceSection = showFilters.count+i;
    //                    }
    //                }
    //                self.filterPriceItem = item;
    //            }
    //            [showFilters addObjectsFromArray:item.options];
    //        }
    //    }
    //    self.filter = showFilters;
    //    self.originFilter = filter;
    //    [self.collectionView reloadData];
}

-(void)selectedWithOpenUrl:(NSString *)openUrl
{
    if (self.filter.count == 0) {
        return;
    }
    
    NSMutableArray *noneFilterItems = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:openUrl];
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    for (NSURLQueryItem *qitem in components.queryItems) {
        NSInteger index = 0 ;
        for (; index < self.filter.count ; index++) {
            FHSearchFilterConfigOption *option = self.filter[index];
            if ([option.type isEqualToString:qitem.name] || [[NSString stringWithFormat:@"%@[]",option.type] isEqualToString:qitem.name]) {
                //find
                NSInteger itemIndex = 0;
                for ( ; itemIndex < option.options.count ; itemIndex++) {
                    FHSearchFilterConfigOption *op = option.options[itemIndex];
                    if ([op.value isEqualToString:qitem.value]) {
                        //find
                        break;
                    }
                }
                if(itemIndex < option.options.count){
                    if([option.type.lowercaseString isEqualToString:PRICE_TYPE]){
                        itemIndex++;
                    }
                    [self handleSelectForIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:index] byUser:NO];
                    break;
                }else if ([option.type.lowercaseString isEqualToString:PRICE_TYPE] && qitem.value.length > 0){
                    //价格
                    NSString *value = [qitem.value stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if ([value hasPrefix:@"["] && [value hasSuffix:@"]"]) {
                        value = [value substringWithRange:NSMakeRange(1, value.length -2)];
                        NSArray *prices = [value componentsSeparatedByString:@","];
                        if (prices.count == 2) {
                            NSString *lowPrice = [prices firstObject];
                            NSString *highPrice = [prices lastObject];
                            
                            NSInteger lowValue = [lowPrice integerValue];
                            NSInteger highValue = [highPrice integerValue];
                            if (self.filterPriceItem.rate.integerValue > 0) {
                                lowValue /= self.filterPriceItem.rate.integerValue;
                                highValue /= self.filterPriceItem.rate.integerValue;
                            }
                            
                            FHMapSearchSelectItemModel *selectItem = [self selectItemForSection:index];
                            selectItem.lowerPrice = [NSString stringWithFormat:@"%ld",lowValue];
                            selectItem.higherPrice = [NSString stringWithFormat:@"%ld",highValue];
                            
                        }
                    }
                    break;
                }
            }
        }
        
        if (index >= self.filter.count) {
            [noneFilterItems addObject:qitem];
        }
    }
    
    __weak typeof(self) wself = self;
    [self.collectionView performBatchUpdates:^{
        [wself.collectionView reloadData];
    } completion:^(BOOL finished) {
        
    }];
    
    
    self.noneFilterQuery = nil;
    if (noneFilterItems.count > 0) {
        NSMutableString *nquery = [NSMutableString new];
        for (NSURLQueryItem *qitem in noneFilterItems) {
            if (nquery.length > 0) {
                [nquery appendString:@"&"];
            }
            [nquery appendFormat:@"%@=%@",qitem.name,[qitem.value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        self.noneFilterQuery = nquery;
    }
    
}

-(FHSearchFilterConfigItem *)configItemForOptions:(FHSearchFilterConfigOption *)option
{
    for (FHSearchFilterConfigItem *item in self.originFilter) {
        if (item.tabId.integerValue != FHMapSearchTabIdTypeRegion) {
            //把区域排除
            if ([item.options containsObject:option]) {
                return item;
            }
            if([self.filterPriceItem.options containsObject:option]){
                return self.filterPriceItem;
            }
        }
    }
    return nil;
}

-(FHMapSearchSelectItemModel *)selectItemForSection:(NSInteger)section
{
    if (section >= self.filter.count) {
        return nil;
    }
    FHSearchFilterConfigOption *option =  self.filter[section];
    
    FHSearchFilterConfigItem *item = [self configItemForOptions:option];
    FHMapSearchSelectItemModel *selectItem = [self.selectionModel selectItemWithTabId:[item.tabId integerValue] section:section];
    if (!selectItem) {
        selectItem = [self.selectionModel makeItemWithTabId:item.tabId.integerValue section:section];
        if(self.filterPriceItem && self.filterPriceItem.tabId.integerValue == item.tabId.integerValue){
            selectItem.rate = self.filterPriceItem.rate;
        }
    }
    if (!selectItem.configOption) {
        selectItem.configOption = option;
    }
    return selectItem;
}

-(void)handleSelectForIndexPath:(NSIndexPath *)indexPath byUser:(BOOL)byUser
{
    NSInteger section = indexPath.section;
    
    if (self.filter.count > section) {
        
        FHSearchFilterConfigOption *option =  self.filter[section];
        FHMapSearchSelectItemModel *selectItem = [self selectItemForSection:section];
        
        NSInteger index = indexPath.item;
        if ([option.type.lowercaseString isEqualToString:PRICE_TYPE] &&[self.filterPriceItem.options containsObject:option]) {
            selectItem.lowerPrice = nil;
            selectItem.higherPrice = nil;
            [self.priceCell updateWithLowerPrice:nil higherPrice:nil];
            index--;
        }
        
        if([self.selectionModel selecteItem:selectItem containIndex:index] && byUser){
            //反选
            [self.selectionModel delSelecteItem:selectItem withIndex:index];
        }else{
            //添加选择
            if ([option.supportMulti boolValue]) {
                [self.selectionModel addSelecteItem:selectItem withIndex:index];
            }else{
                [self.selectionModel clearAddSelecteItem:selectItem withIndex:index];
            }
        }
    }
}

#pragma mark - price cell delegate
-(void)updateLowerPrice:(NSString *)price inCell:(FHMapSearchPriceCell *)cell
{
    FHMapSearchSelectItemModel *priceItem = [self priceItem];
    priceItem.lowerPrice = price;
}

-(void)updateHigherPrice:(NSString *)price inCell:(FHMapSearchPriceCell *)cell
{
    FHMapSearchSelectItemModel *priceItem = [self priceItem];
    priceItem.higherPrice = price;
}

-(void)priceDidChange:(NSString *)price inCell:(FHMapSearchPriceCell *)cell
{
    FHMapSearchSelectItemModel *priceItem = [self priceItem];
    if (priceItem.selectIndexes.count > 0) {
        [self deselectPriceItems:priceItem];
    }
}

-(FHMapSearchSelectItemModel *)priceItem
{
    FHMapSearchSelectItemModel *priceItem = [self.selectionModel selectItemWithTabId:FHMapSearchTabIdTypePrice section:_filterPriceSection];
    if (!priceItem) {
        priceItem = [self.selectionModel makeItemWithTabId:FHMapSearchTabIdTypePrice section:_filterPriceSection];
        priceItem.rate = self.filterPriceItem.rate;
    }
    return priceItem;
}

-(void)deselectPriceItems:(FHMapSearchSelectItemModel *)priceItem
{
    if (priceItem.selectIndexes.count > 0) {
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (NSNumber *index in [priceItem.selectIndexes allObjects]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index.integerValue+1 inSection:_filterPriceSection];
            [indexPaths addObject:indexPath];
        }
        [priceItem.selectIndexes removeAllObjects];
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }
}

#pragma mark - collectionview datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.filter.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    FHSearchFilterConfigOption *options = self.filter[section];
    
    NSInteger count = options.options.count;
    if ([options.type.lowercaseString isEqualToString:@"price"] && [self.filterPriceItem.options containsObject:options]) {
        count++;
    }
    return count;
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger section = indexPath.section;
    NSArray *filter = self.filter;
    if (filter.count > section) {
        
        FHMapSearchSelectModel *model = self.selectionModel;
        FHSearchFilterConfigOption *option = filter[section];
        BOOL isPriceOption = NO;
        if ([option.type.lowercaseString isEqualToString:@"price"] && [self.filterPriceItem.options containsObject:option]) {
            isPriceOption = YES;
        }
        if (isPriceOption && indexPath.item == 0) {
            
            FHMapSearchPriceCell *pcell = [collectionView dequeueReusableCellWithReuseIdentifier:PRICE_CELL_ID forIndexPath:indexPath];
            
            pcell.delegate = self;
            
            FHMapSearchSelectItemModel *priceItem = [model selectItemWithTabId:FHMapSearchTabIdTypePrice section:section];
            if (!priceItem) {
                priceItem = [model makeItemWithTabId:FHMapSearchTabIdTypePrice section:section];
                priceItem.rate = self.filterPriceItem.rate;
                priceItem.configOption = option;
            }else{
                priceItem.rate = self.filterPriceItem.rate;
                priceItem.configOption = option;
            }
            if (priceItem) {
                [pcell updateWithLowerPrice:priceItem.lowerPrice higherPrice:priceItem.higherPrice];
            }
            self.priceCell = pcell;
            
            return pcell;
            
        }else{
            
            FHMapSearchTextItemCell *tcell = [collectionView dequeueReusableCellWithReuseIdentifier:NORMAL_CELL_ID forIndexPath:indexPath];
            NSString *text = nil;
            
            NSInteger index = indexPath.item;
            if (isPriceOption) {
                index--;
            }
            
            if (option.options.count > index) {
                FHSearchFilterConfigOption *options = option.options[index];
                text = options.text;
            }else{
                text = option.text;
            }
            
            BOOL selected = NO;
            
            if (model) {
                FHSearchFilterConfigItem *item = [self configItemForOptions:option];
                FHMapSearchSelectItemModel *selectItem = [model selectItemWithTabId:[item.tabId integerValue] section:section];
                selected = [model selecteItem:selectItem containIndex:index];
            }

            [tcell updateWithTitle:text highlighted:selected];
            
            return tcell;
        }
        
    }
    
    return [[UICollectionViewCell alloc] init];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        FHMapSearchFilterHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
        
        NSInteger section = indexPath.section;
        NSArray *filter = self.filter;
        if (filter.count > section) {
            FHSearchFilterConfigOption *item =  filter[section];
            [headerView updateTitle:item.text];
        }else{
            return nil;
        }
        
        return headerView;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger section = indexPath.section;
    NSArray *filter = self.filter;
    if (filter.count > section) {
        FHSearchFilterConfigOption *option =  filter[section];
        if (indexPath.item == 0 && [option.type.lowercaseString isEqualToString:@"price"] && [self.filterPriceItem.options containsObject:option]) {
            //输入价格
            return CGSizeMake(collectionView.frame.size.width - 2*ITEM_HOR_MARGIN, 36);
        }else{
            return CGSizeMake(74, 30);
        }
    }
    
    return CGSizeMake(collectionView.frame.size.width, 60);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *filter = self.filter;
    
    NSInteger section = indexPath.section;
    
    if (filter.count > section) {
        [self handleSelectForIndexPath:indexPath byUser:YES];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        //        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        [CATransaction commit];
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, ITEM_HOR_MARGIN, 0, ITEM_HOR_MARGIN);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 9;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height = 57;
    if (section == 0) {
        height -= 10;
    }
    
    return CGSizeMake(collectionView.frame.size.width - 2*ITEM_HOR_MARGIN, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self endEditing:YES];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

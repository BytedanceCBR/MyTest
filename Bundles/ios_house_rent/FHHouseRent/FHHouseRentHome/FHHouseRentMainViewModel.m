//
//  FHHouseRentMainViewModel.m
//  FHHouseRent
//
//  Created by 谷春晖 on 2018/11/22.
//

#import "FHHouseRentMainViewModel.h"
#import "FHHouseRentCell.h"
#import <FHMainApi.h>
#import <UIScrollView+Refresh.h>
#import "FHSearchFilterOpenUrlModel.h"
#import <TTRoute.h>
#import "FHRefreshCustomFooter.h"
#import "FHHouseBridgeManager.h"
#import "FHUserTracker.h"
#import <FHHouseSuggestionDelegate.h>
#import "FHFakeInputNavbar.h"
#import "FHErrorMaskView.h"
#import "FHPlaceHolderCell.h"
#import <UIViewAdditions.h>
#import <FHConfigModel.h>
#import "FHSpringboardView.h"
#import <UIImageView+WebCache.h>
#import "UIColor+Theme.h"
#import "TTReachability.h"
#import "FHMainManager+Toast.h"
#import "FHHouseRentFilterType.h"
#import <UIImageView+WebCache.h>
#import "FHBaseViewController.h"
#import <TTHttpTask.h>
#import <FHRentArticleListNotifyBarView.h>
#import "UIViewController+Track.h"
#import "FHEnvContext.h"

#define kPlaceCellId @"placeholder_cell_id"
#define kFilterBarHeight 44
#define MAX_ICON_COUNT 4
#define ICON_HEADER_HEIGHT 109
#define TABLE_HEADER_HEIGHT (ICON_HEADER_HEIGHT+6)

@interface FHHouseRentMainViewModel ()<FHHouseSuggestionDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) FHConfigDataRentOpDataModel *rentModel;

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , weak) FHBaseViewController *viewController;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) UIView *iconHeaderView;
@property(nonatomic , strong) FHSpringboardView *iconsHeaderView;

@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) FHSearchFilterOpenUrlModel *filterOpenUrlMdodel;
@property(nonatomic , strong) FHHouseRentDataModel *currentRentDataModel;
@property(nonatomic , copy)  NSString *conditionFilter;
@property(nonatomic , strong) NSString *suggestion;
@property(nonatomic , strong) NSDictionary *houseSearchDict;
@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic , strong) UIImage *placeHolderImage;
@property(nonatomic , copy  ) NSString *mapFindHouseOpenUrl;
@property(nonatomic , weak) TTHttpTask *requestTask;

//for log
//@property(nonatomic , strong) NSDate *startDate;
@property(nonatomic , strong) NSMutableDictionary *showHouseDict;
@property(nonatomic , strong) NSMutableDictionary *stayTraceDict;
@property(nonatomic , assign) CGFloat headerHeight;

@property(nonatomic , copy) NSString *originSearchId;
@property(nonatomic , assign) BOOL isFirstLoad;

@end


@implementation FHHouseRentMainViewModel


-(instancetype)initWithViewController:(FHBaseViewController *)viewController tableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
        _headerHeight = kFilterBarHeight;
        
        self.tableView = tableView;
        self.viewController = viewController;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [_tableView registerClass:[FHHouseRentCell class] forCellReuseIdentifier:@"item"];
        [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kPlaceCellId];
        
        __weak typeof(self) wself = self;
        FHRefreshCustomFooter *footer = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            [wself requestData:NO];
        }];
        _tableView.mj_footer = footer;
        footer.hidden = YES;
        
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        [self setupHeader];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
        
        _showHouseDict = [NSMutableDictionary new];
        
        viewController.tracerModel.originSearchId = nil;
        
        self.isFirstLoad = YES;
        
    }
    return self;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetUpdateState) object:nil];
}

-(void)setupHeader
{
//    NSDictionary *dict = [[[FHHouseBridgeManager sharedInstance] envContextBridge] appConfigRentOpData];
    
    NSDictionary *dict = nil;
    if ([[[FHEnvContext sharedInstance] getConfigFromCache].rentOpData respondsToSelector:@selector(toDictionary)]) {
        dict =  [[FHEnvContext sharedInstance] getConfigFromCache].rentOpData.toDictionary;
    }
    
    _rentModel = [[FHConfigDataRentOpDataModel alloc] initWithDictionary:dict error:nil];
    
    _iconsHeaderView =  [[FHSpringboardView alloc] initWithRowCount:MAX_ICON_COUNT];
    _iconsHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewController.view.frame), 109);
    __weak typeof(self) wself = self;
    _iconsHeaderView.tapIconBlock = ^(NSInteger index) {        
        if (index < wself.rentModel.items.count ) {
            //TODO: 添加埋点
            FHConfigDataRentOpDataItemsModel *model = wself.rentModel.items[index];
            [wself quickJump:model];
        }
    };
    
    NSMutableArray *items = [NSMutableArray new];
    UIImage *placeHolder = [UIImage imageNamed:@"icon_placeholder"];
    for(FHConfigDataRentOpDataItemsModel *model in _rentModel.items){
        FHSpringboardIconItemView* item = [[FHSpringboardIconItemView alloc] init];
        item.nameLabel.text = model.title;
        FHConfigDataRentOpDataItemsImageModel *imgModel = [model.image firstObject];
        NSURL *imgUrl = [NSURL URLWithString:imgModel.url];
        [item.iconView sd_setImageWithURL:imgUrl placeholderImage:placeHolder];
        [items addObject:item];
    }
    if (items.count > MAX_ICON_COUNT) {
        items = [items subarrayWithRange:NSMakeRange(0, MAX_ICON_COUNT)];
    }

    _iconsHeaderView.backgroundColor = [UIColor whiteColor];
    [_iconsHeaderView addItems:items];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.viewController.view.frame), TABLE_HEADER_HEIGHT)];
    header.backgroundColor  = [UIColor themeGrayPale];
    [header addSubview:_iconsHeaderView];
    
    self.iconHeaderView = header;
}

-(UIView *)iconHeaderView
{
    return _iconHeaderView;
}

-(void)setContainerScrollView:(UIScrollView *)containerScrollView
{
    _containerScrollView = containerScrollView;
    _containerScrollView.delegate = self;
}

-(void)setErrorMaskView:(FHErrorMaskView *)errorMaskView
{
    _errorMaskView = errorMaskView;    
    __weak typeof(self) wself = self;
    _errorMaskView.retryBlock = ^{
        [wself requestData:YES];
    };
    _errorMaskView.hidden = YES;

}

-(void)showErrorMask:(BOOL)show tip:(NSString *)tip enableTap:(BOOL)enableTap showReload:(BOOL)showReload
{
    if (show) {
        [_errorMaskView showErrorWithTip:tip];
        if (enableTap) {
            [_errorMaskView enableTap:enableTap];
        }
        
        [_errorMaskView showRetry:showReload];
        
        self.tableView.scrollEnabled = NO;
    }
    self.errorMaskView.hidden = !show;
}

-(void)requestData:(BOOL)isHead
{
    [_requestTask cancel];
    
    NSString *query = [_filterOpenUrlMdodel query];
    NSInteger offset = 0;
    if (!isHead) {
        offset = _houseList.count;
    }
    
    if (isHead) {
        self.showPlaceHolder = YES;
    }
    
    if (![TTReachability isNetworkConnected]) {        
        if (isHead) {
            [self showErrorMask:YES tip:@"网络不给力，点击屏幕重试" enableTap:YES showReload:YES];
        }else{
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    
    __weak typeof(self) wself = self;
   self.requestTask =  [FHMainApi searchRent:query params:nil offset:offset searchId:self.currentRentDataModel.searchId sugParam:nil completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        
        wself.tableView.scrollEnabled = YES;
        if (error) {
            //add error toast
            if (error.code != NSURLErrorCancelled) {
                //不是主动取消                
                if (isHead) {
                    NSString *tip = @"数据走丢了";
                    if (![TTReachability isNetworkConnected]) {
                        tip = @"网络不给力，点击屏幕重试";
                    }
                    [wself showErrorMask:YES tip:tip enableTap:NO showReload:YES];
                }else{
                    [[FHMainManager sharedInstance] showToast:@"请求失败" duration:2];
                    [wself.tableView.mj_footer endRefreshing];
                }
            }
            return;
        }
        
        [wself showErrorMask:NO tip:nil enableTap:NO showReload:YES];
        if (isHead) {
            if (model.data.items.count > 0) {
                NSString *tip = model.data.refreshTip;
                if (tip.length == 0) {
                    tip = @"请求成功";
                }
                wself.showNotify(tip);
            }
        }
       
       wself.tableView.mj_footer.hidden = NO;
       //reset load more state
       if (model.data && !model.data.hasMore) {
           [wself.tableView.mj_footer endRefreshingWithNoMoreData];
       }else{
           if (isHead) {
               [wself.tableView.mj_footer resetNoMoreData];
           }else{
               [wself.tableView.mj_footer endRefreshing];
           }
       }
       
        
        if (!isHead && model.data.items.count == 0) {
            [[FHMainManager sharedInstance] showToast:@"请求失败" duration:2];
        }
       
        wself.currentRentDataModel = model.data;
        wself.searchId = model.data.searchId;

        if (isHead) {
            [wself.houseList removeAllObjects];
        }
        
        [wself.houseList addObjectsFromArray:model.data.items];
        wself.showPlaceHolder = NO;
        [wself.tableView reloadData];
        wself.mapFindHouseOpenUrl = model.data.mapFindHouseOpenUrl;
        
        if (!isHead) {
            [wself addLoadMoreRefreshLog];
        }
//        else if(wself.overwriteFilter){
//            wself.overwriteFilter(model.data.houseListOpenUrl);
//        }
        
        if (wself.houseList.count == 0) {
            NSString *tip;
            if (self.conditionFilter.length > 0) {
                tip = @"没有找到相关信息，换个条件试试吧~";
            }else{
                tip = @"数据走丢了";
            }
            [wself showErrorMask:YES tip:tip enableTap:NO showReload:NO];
        }
        wself.viewController.tracerModel.searchId = model.data.searchId;
        if (wself.isFirstLoad) {
            wself.viewController.tracerModel.originSearchId = model.data.searchId ?:@"be_null";
            wself.originSearchId = model.data.searchId;
            [wself addEnterLog];
            wself.isFirstLoad = NO;
        }
       
       wself.tableView.mj_footer.hidden = (wself.houseList.count == 0);
       
       if (isHead && wself.houseList.count > 0) {
           [wself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
       }
       
    }];
}

-(void)showInputSearch
{
    SETTRACERKV(UT_ORIGIN_FROM,@"renting_search");
    [self addClickSearchLog];
    if (self.closeConditionFilter) {
        self.closeConditionFilter();
    }
    
    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    [envBridge setTraceValue:@"renting_search" forKey:@"origin_from"];
    
    NSMutableDictionary *traceParam = [self baseLogParam];
    traceParam[@"element_from"] = @"renting_search";
    traceParam[@"page_type"] = @"renting";
    traceParam[@"origin_from"] = @"renting_search";
    traceParam[@"origin_search_id"] = self.originSearchId ? : @"be_null";

    //sug_list
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(FHHouseTypeRentHouse) ,
                           @"tracer": traceParam,
                           @"from_home":@(4),
                           @"sug_delegate":sugDelegateTable
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://sug_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        
}

-(void)showMapSearch
{
    if (self.currentRentDataModel.mapFindHouseOpenUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:self.currentRentDataModel.mapFindHouseOpenUrl];
        NSDictionary *dict = @{};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

-(void)viewWillAppear
{
//    self.startDate = [NSDate date];
}

-(void)viewWillDisapper
{
    [self addStayLog];
}


#pragma mark - filter delegate

-(void)onConditionChanged:(NSString *)condition
{
    if ([self.conditionFilter isEqualToString:condition]) {
        return;
    }
 
    self.tableView.scrollEnabled = YES;
    
    self.conditionFilter = condition;
    
    [self.filterOpenUrlMdodel overwriteFliter:condition];
    [self.tableView triggerPullDown];
    [self requestData:YES];
}

-(void)onConditionPanelWillDisplay
{
    self.containerScrollView.contentOffset = CGPointMake(0, TABLE_HEADER_HEIGHT);
    self.containerScrollView.scrollEnabled = NO;
}

-(void)onConditionPanelWillDisappear
{
    self.containerScrollView.scrollEnabled = YES;
}

-(UIImage *)placeHolderImage
{
    if (!_placeHolderImage) {
        _placeHolderImage = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolderImage;
}

-(UIImage *)contentSnapshot
{
    CGRect bounds = self.tableView.frame;
    bounds.origin = CGPointZero;
    // 1、先根据 view，生成 整个 view 的截图
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0);  //NO，YES 控制是否透明
    if ([self.tableView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self.tableView drawViewHierarchyInRect:bounds afterScreenUpdates:NO];
    } else {
        [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *wholeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // 2、根据 view 的图片。生成指定位置大小的图片。
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGFloat top = [self headerBottomOffset];
    bounds = CGRectMake(0, top, self.tableView.width, self.tableView.height - top);
    CGRect imageToExtractFrame = CGRectApplyAffineTransform(bounds, CGAffineTransformMakeScale(screenScale, screenScale));
    CGImageRef imageRef = CGImageCreateWithImageInRect([wholeImage CGImage], imageToExtractFrame);
    
    wholeImage = nil;
    
    UIImage *image = [UIImage imageWithCGImage:imageRef
                                         scale:screenScale
                                   orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return image;
    
}

#pragma mark - tableview delegate & datasource
-(NSInteger)numberOfSections
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_showPlaceHolder) {
        return  10;
    }
    
    return _houseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (_showPlaceHolder) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:kPlaceCellId];
        
    }else{
        
        FHHouseRentCell *rentCell = [tableView dequeueReusableCellWithIdentifier:@"item"];
        FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
        
        rentCell.majorTitle.text = model.title;
        rentCell.extendTitle.text = model.subtitle;
        rentCell.priceLabel.text = model.pricing;
        if (model.tags.count > 0) {
            NSMutableArray *tags = [NSMutableArray new];
            for (FHSearchHouseDataItemsTagsModel *tag in model.tags) {
                FHTagItem *item = [FHTagItem instanceWithText:tag.content withColor:tag.textColor withBgColor:tag.backgroundColor];
                [tags addObject:item];
            }
            [rentCell setTags:tags];
        }else{
            [rentCell setTags:@[]];
        }
     
        FHSearchHouseDataItemsHouseImageModel *imgModel = [model.houseImage firstObject];
        [rentCell setHouseImages:model.houseImageTag];
        [rentCell.iconView sd_setImageWithURL:[NSURL URLWithString:imgModel.url] placeholderImage:self.placeHolderImage];
        
                
        cell = rentCell;
        
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showPlaceHolder) {
        return 105;
    }

    if (indexPath.row == 0) {
        return 115;
    }
    return 105;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_showPlaceHolder) {
        [self addHouseShowLog:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showPlaceHolder || [_houseList count] <= indexPath.row) {
        return;
    }
    
    FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
    
    SETTRACERKV(UT_ORIGIN_FROM, @"renting_list");
    
    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    [envBridge setTraceValue:@"renting_list" forKey:@"origin_from"];
    
    NSMutableDictionary* tracer = [[self.viewController.tracerModel neatLogDict] mutableCopy];
    tracer[@"card_type"] = @"left_pic";
    tracer[@"element_from"] = @"be_null";
    tracer[@"enter_from"] = @"renting";
    tracer[@"log_pb"] = model.logPb;
    tracer[@"rank"] = @(indexPath.row);
    tracer[@"origin_from"] = @"renting_list";
    tracer[@"origin_search_id"] = self.originSearchId ? : @"be_null";

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://rent_detail?house_id=%@", model.id]];
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer": tracer}];
    [[TTRoute sharedRoute] openURLByViewController:url userInfo: userInfo];
}



//-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    if (velocity.y > 0.5) {
//        //向下滑动
//        CGFloat topHeight = [self topViewHeight];
//        if (scrollView.contentOffset.y < topHeight ) {
//            *targetContentOffset = CGPointMake(0, topHeight);
//        }
//    }else if (velocity.y < -0.5){
//        //向上滑动
//        CGFloat topHeight = [self topViewHeight];
//        if (scrollView.contentOffset.y > topHeight && scrollView.contentOffset.y < fabs(velocity.y)*1.5*CGRectGetHeight(scrollView.frame)) {
//            *targetContentOffset = CGPointMake(0, topHeight);
//        }else if(scrollView.contentOffset.y < 40  ){
//            *targetContentOffset = CGPointZero;
//        }
//
//    }
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = self.tableView.contentOffset;
    CGPoint coffset = self.containerScrollView.contentOffset;
    [self.viewController.view endEditing:YES];
    
//    NSLog(@"scrollview scroll: %@  offset is: %f  coffset is: %f  draging: %@",scrollView == self.tableView?@"TableView":@"ContainerView",offset.y,coffset.y,scrollView.isDragging?@"YES":@"NO");
    
    CGFloat threshold = TABLE_HEADER_HEIGHT;//self.iconsHeaderView.height;
    CGFloat realOffset = offset.y + self.tableView.contentInset.top;
    
    if (scrollView == _containerScrollView) {
        
        if (coffset.y > threshold) {
            //向上滑动， 此时应滑动tableview
            if (self.tableView.scrollEnabled) {
                if (self.tableView.height + self.tableView.contentInset.bottom + self.tableView.contentInset.top > self.tableView.contentSize.height) {
                    //内容不满一屏幕
                    offset = CGPointMake(0, -self.tableView.contentInset.top);;
                }else{
                    CGFloat delta = (offset.y + self.tableView.height + self.tableView.contentInset.bottom + self.tableView.contentInset.top - self.tableView.contentSize.height);
                    if (delta > 0) {
                        if (delta < 10) {
                            offset.y += (coffset.y - threshold);
                        }else{
                            offset.y += (coffset.y - threshold)*(10/delta);
                        }
                    }else{
                        offset.y += coffset.y - threshold;
                    }
                    offset.y -= self.tableView.contentInset.top;
                }
            }
            coffset.y = threshold;
            
            self.tableView.contentOffset = offset;
            self.containerScrollView.contentOffset = CGPointMake(0, threshold);
        }else if(coffset.y > 0 && realOffset > 0){
            //注释后，则在筛选器在顶部时不能向下滑动，只能等tableview滑动下来后才可以
//            offset.y += (coffset.y-threshold - self.tableView.contentInset.top);
//            self.tableView.contentOffset = offset;
            if (self.tableView.scrollEnabled) {
                self.containerScrollView.contentOffset = CGPointMake(0, threshold);
            }
        }
        
        
    }else if (scrollView == self.tableView){
        
        UIEdgeInsets insets = self.tableView.contentInset;
        CGFloat realOffset = offset.y + insets.top;
        if (realOffset < 0) {
            
            if (coffset.y > -10) {
                coffset.y += realOffset;
            }else if (coffset.y > -20){
                coffset.y += realOffset * 0.3;
            }else {//if (coffset.y > -50)
                coffset.y += realOffset * 0.1;
            }
            
            if (coffset.y < -30) {
                coffset.y = -30;
            }
            
            self.tableView.contentOffset = CGPointMake(0, -insets.top);
            self.containerScrollView.contentOffset = coffset;
        }else if (coffset.y < threshold){
            
            coffset.y += realOffset;
            if (coffset.y > threshold) {
                coffset.y = threshold;
            }
            self.tableView.contentOffset = CGPointMake(0, -insets.top);;
            self.containerScrollView.contentOffset = coffset;
        }
    }
    
}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    if (scrollView == self.tableView && self.tableView.contentOffset.y + self.tableView.height - self.tableView.contentInset.bottom + 0.5 - self.tableView.contentSize.height > 0) {
//        [self checkScrollMoveEffect:scrollView animated:YES];
//    }
//}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self checkScrollMoveEffect:scrollView animated:YES];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self checkScrollMoveEffect:scrollView animated:NO];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self checkScrollMoveEffect:scrollView animated:YES];
    }    
}

-(void)checkScrollMoveEffect:(UIScrollView *)scrollView animated:(BOOL)animated
{
//    NSLog(@"scrollview move %@ info is: %@",scrollView == self.tableView?@"tableview":@"containerview",scrollView);
    if (scrollView == self.tableView) {
        if (self.containerScrollView.contentOffset.y < 0) {
            if (animated) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.containerScrollView.contentOffset = CGPointZero;
                }];
            }else{
                [self.containerScrollView setContentOffset:CGPointZero animated:NO];
            }
        }else if(self.containerScrollView.contentOffset.y + self.containerScrollView.height > self.containerScrollView.contentSize.height){
            self.containerScrollView.contentOffset = CGPointMake(0, self.containerScrollView.contentSize.height - self.containerScrollView.height);
        }
        if ([self tableViewDragUpToLimit]) {
            //滑动到底部
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.height - 0.5) animated:YES];
        }
        
    }else if (scrollView == self.containerScrollView && self.tableView.scrollEnabled){
        if (self.tableView.height + self.tableView.contentInset.bottom + self.tableView.contentInset.top > self.tableView.contentSize.height) {
            //内容不满一屏幕
            self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);;
        }else{
            if (self.tableView.contentOffset.y + self.tableView.contentInset.top < 0) {
                self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
            }else if (self.tableView.contentOffset.y + self.tableView.height  > self.tableView.contentSize.height + self.tableView.contentInset.bottom){                
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.height - self.tableView.contentInset.top );
            }
        }
    }

}

-(BOOL)tableViewDragUpToLimit
{
    return self.tableView.contentOffset.y + self.tableView.height - self.tableView.contentInset.bottom + 0.5 - self.tableView.contentSize.height > 0;
}


-(CGFloat)topViewHeight
{
    return self.tableView.tableHeaderView.height;
}

-(CGFloat)headerBottomOffset
{
    return   MAX(CGRectGetHeight(self.tableView.tableHeaderView.frame) -self.tableView.contentOffset.y,0)+kFilterBarHeight;
}


#pragma mark - quick jump
-(void)quickJump:(FHConfigDataRentOpDataItemsModel *)model
{
    NSMutableString *openUrl = [[NSMutableString alloc] initWithString:model.openUrl];// model.openUrl;
    if (![openUrl containsString:@"house_type"]) {
        [openUrl appendFormat:@"&house_type=%ld",FHHouseTypeRentHouse];
//        openUrl = [openUrl stringByAppendingFormat:@"&house_type=%ld",FHHouseTypeRentHouse];
    }
    if (![openUrl containsString:@"search_id"]) {
        [openUrl appendFormat:@"&search_id=%@",self.searchId?:@"be_null"];
    }
    TTRouteUserInfo *userInfo = nil;
    NSURL *url = nil;
    FHHouseRentFilterType filterType = [self rentFilterType:model.openUrl];
    
    NSString *originFrom = model.logPb[@"origin_from"];
    
    if (filterType == FHHouseRentFilterTypeMap){
        
        //王然说点击不爆切换埋点
//        [self addMapsearchLog];
        
//        if (self.mapFindHouseOpenUrl.length > 0) {
//            //使用跳转
//            openUrl = self.mapFindHouseOpenUrl;
//        }
        if (originFrom.length == 0) {
            originFrom = @"renting_mapfind";
        }
        
        
        if (![openUrl containsString:@"enter_from"]) {
            [openUrl appendString:@"&enter_from=renting"];
        }
        if (![openUrl containsString:@"origin_from"]) {
            [openUrl appendFormat:@"&origin_from=%@",originFrom];
        }
       
        SETTRACERKV(UT_ORIGIN_FROM, originFrom);
        
        NSMutableDictionary *params = [[self.viewController.tracerModel neatLogDict] mutableCopy];
        params[@"enter_from"] = @"renting";
        params[@"origin_from"] = originFrom;
        params[@"origin_search_id"] = nil;//remove origin_search_id
        
        NSDictionary *infoDict = @{@"tracer":params};
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
        
    }else{
        NSDictionary *param = [self addEnterHouseListLog:model.openUrl];
        if (param) {
            NSDictionary *infoDict = @{@"tracer":param};
            userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
            if (originFrom.length == 0) {
                originFrom = param[@"origin_from"];
            }
            
            if (originFrom) {
                SETTRACERKV(@"origin_from", originFrom);
            }
        }
    }
    url = [NSURL URLWithString:openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}



#pragma mark - log

-(NSMutableDictionary *)baseLogParam
{
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */
    
    NSMutableDictionary *param = [NSMutableDictionary new];
//    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
//    NSDictionary *houseParams = [envBridge homePageParamsMap];
    [param addEntriesFromDictionary:[self.viewController.tracerModel logDict]];
//    [param addEntriesFromDictionary:houseParams];
    param[@"origin_search_id"] = self.originSearchId ?: @"be_null";
    param[@"search_id"] = self.searchId ?: @"be_null";
    param[@"enter_from"] = @"renting";
    
    return param;
}

-(void)addEnterLog
{
    /*
     enter_category
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     */
    
    if (self.viewController.tracerModel) {
        
        FHTracerModel *model = self.viewController.tracerModel;
        TRACK_MODEL(UT_ENTER_CATEOGRY,model);
        
        self.stayTraceDict = [model logDict];
        
//        NSMutableDictionary *param = [NSMutableDictionary new];
//        [param addEntriesFromDictionary:self.tracerDict];
//        param[@"category_name"] = @"renting";
//
//        TRACK_EVENT(@"enter_category", param);
    }
    
}

-(void)addClickSearchLog
{

    /*
     1. event_type：house_app2c_v2
     2. page_type（页面类型）：renting（租房大类页），rent_list（租房列表页），findtab_rent（租房）
     3. origin_from
     4. origin_search_id
     5. hot_word（搜索框轮播词，无轮播词记为be_null）
     */
    
    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    NSDictionary *houseParams = [envBridge homePageParamsMap];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:houseParams];
    params[@"page_type"] = @"renting";
    params[@"origin_search_id"] = self.viewController.tracerModel.originSearchId?:@"be_null";
    params[@"hot_word"] = @"be_null";
    params[@"origin_from"] = @"renting_search";
    
    TRACK_EVENT(@"click_house_search",params);
}

-(void)addStayLog
{
    NSTimeInterval duration = self.viewController.ttTrackStayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */
    
//    NSMutableDictionary *param = [self.viewController.tracerModel logDict];//[NSMutableDictionary new];
//    [param addEntriesFromDictionary:self.tracerDict];
//    param[@"search_id"] = self.searchId;
    self.stayTraceDict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",duration];
//    param[@"category_name"] = @"renting";
    
    TRACK_EVENT(@"stay_category", self.stayTraceDict);
    [self.viewController tt_resetStayTime];
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */

    
}


-(void)addLoadMoreRefreshLog
{
    NSMutableDictionary *param = [self baseLogParam];
    
    /*
     "1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. refresh_type（刷新类型）：pre_load_more（滑动频道）"
     */
    
//    param[@"search_id"] = self.searchId;
    param[@"refresh_type"] = @"pre_load_more";
    param[@"enter_from"] = self.viewController.tracerModel.enterFrom?:@"maintab";
    
    TRACK_EVENT(@"category_refresh", param);
}

-(void)addHouseShowLog:(NSIndexPath *)indexPath
{
    FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
    if (_showHouseDict[model.id]) {
        //already add log
        return;
    }
    
    _showHouseDict[model.id] = @(1);
    
    NSDictionary *baseParam = [self baseLogParam];
    
    /*
     "1. event_type：house_app2c_v2
     2. house_type（房源类型）：rent（租房）
     3. card_type（卡片样式）：left_pic（左图）
     4. page_type（页面类型）：renting（租房大类页）
     5. element_type：be_null
     6. group_id
     7. impr_id
     8. search_id
     9. rank
     10. origin_from：renting_list（租房大类页推荐列表）
     11. origin_search_id"
     */
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"house_type"] = @"rent";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"renting";
    param[@"element_type"] = @"be_null";
    param[@"group_id"] = model.id;
    param[@"impr_id"] = model.imprId;
    param[@"search_id"] = self.searchId;
    param[@"rank"] = @(indexPath.row);
    param[@"log_pb"] = model.logPb;
    param[@"origin_from"] = baseParam[@"origin_from"] ? : @"be_null";;
    param[@"origin_search_id"] = self.viewController.tracerModel.originSearchId ? : @"be_null";;
    
    TRACK_EVENT(@"house_show", param);
}

-(void)addGodetailLog:(NSIndexPath *)indexPath
{
    FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
    NSMutableDictionary *param = [self baseLogParam];
    
    /*
     "1. event_type：house_app2c_v2
     2. house_type（房源类型）：rent（租房）
     3. card_type（卡片样式）：left_pic（左图）
     4. page_type（页面类型）：renting（租房大类页）
     5. element_type：be_null
     6. group_id
     7. impr_id
     8. search_id
     9. rank
     10. origin_from：renting_list（租房大类页推荐列表）
     11. origin_search_id"
     */
    
    param[@"house_type"] = @"rent";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"renting";
    param[@"element_type"] = @"be_null";
    param[@"impr_id"] = model.imprId;
    param[@"log_pb"] = model.logPb;
    param[@"rank"] = @(indexPath.row);
    param[@"search_id"] = self.searchId;
    
    TRACK_EVENT(@"go_detail", param);
}

-(NSDictionary *)addEnterHouseListLog:(NSString *)openUrl
{
    /*
     "1. event_type：house_app2c_v2
     2. category_name（列表名）：rent_list（租房列表页）
     3. enter_from（列表入口）：renting（租房大类页），maintab（首页），findtab（找房tab）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：renting_icon（租房大类页icon），renting_search（租房大类页搜索），maintab_search（首页搜索）, findtab_find（找房tab开始找房）findtab_search（找房tab搜索）
     6. search_id
     7. origin_from：renting_all（租房大类页全部房源icon），renting_joint（租房大类页合租icon），renting_fully（租房大类页整租icon），renting_apartment（租房大类页公寓icon），maintab_search（首页搜索），findtab_find（找房tab开始找房），findtab_search（找房tab搜索）
     8. origin_search_id"
     
     enter_category
     */
    
    FHHouseRentFilterType filterType = [self rentFilterType:openUrl];
    if (filterType == FHHouseRentFilterTypeMap) {
//        [self addMapsearchLog];
        return nil;
    }
    
    NSString *originFrom = [self originFromWithFilterType:filterType];
    if (!originFrom) {
        return nil ;
    }
    
    NSMutableDictionary *param = [[self baseLogParam]mutableCopy];
    param[@"category_name"] = @"rent_list";
    param[@"enter_type"] = @"click";
    param[@"element_from"] = @"renting_icon";
    param[@"search_id"] = self.searchId;
    
    param[@"origin_from"] = originFrom;
    if (!param[@"origin_search_id"]) {
        param[@"origin_search_id"] = @"be_null";
    }
    
    return param;
}

-(void)addMapsearchLog
{
    /*
     let params = TracerParams.momoid() <|>
     toTracerParams(enterFrom, key: "enter_from") <|>
     toTracerParams("click", key: "enter_type") <|>
     toTracerParams("map", key: "click_type") <|>
     toTracerParams(catName, key: "category_name") <|>
     toTracerParams(categoryListViewModel?.originSearchId ?? "be_null", key: "search_id") <|>
     toTracerParams(elementName, key: "element_from") <|>
     toTracerParams(originFrom, key: "origin_from") <|>
     toTracerParams(originSearchId, key: "origin_search_id")
     
     recordEvent(key: TraceEventName.click_switch_mapfind, params: params)
     */
    
    NSMutableDictionary *param = [[self baseLogParam]mutableCopy];
    param[@"element_from"] = @"renting_icon";
    param[@"origin_from"] = @"renting_mapfind";
    param[UT_CATEGORY_NAME] = @"rent_list";
    
    TRACK_EVENT(@"click_switch_mapfind", param);
}

-(void)addSearchLog
{
    
}

-(NSString *)originFromWithFilterType:(FHHouseRentFilterType)filterType
{
    switch (filterType) {
        case FHHouseRentFilterTypeWhole:
            return  @"renting_fully";
        case FHHouseRentFilterTypeApart:
            return  @"renting_apartment";
        case FHHouseRentFilterTypeShare:
            return  @"renting_joint";
        case FHHouseRentFilterTypeMap:
            return @"renting_mapfind";
        default:
            return nil;
    }
    return nil;
}

-(FHHouseRentFilterType)rentFilterType:(NSString *)openUrl
{
    NSURL *url = [NSURL URLWithString:openUrl];
    if (!url) {
        return FHHouseRentFilterTypeNone;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    if ([components.host isEqualToString:@"mapfind_rent"]) {
        return FHHouseRentFilterTypeMap;
    }
    
    if ([components.host isEqualToString:@"house_list"]) {
        for (NSURLQueryItem *queryItem in components.queryItems) {
            if ([queryItem.name isEqualToString:@"rental_type[]"]) {
                if ([queryItem.value isEqualToString:@"1"]) {
                    //整租
                    return FHHouseRentFilterTypeWhole;
                }else if ([queryItem.value isEqualToString:@"2"]){
                    //合租
                    return FHHouseRentFilterTypeShare;
                }
            }else if ([queryItem.name isEqualToString:@"rental_contract_type[]"]){
                if ([queryItem.value isEqualToString:@"2"]) {
                    //公寓
                    return FHHouseRentFilterTypeApart;
                }
                
            }
        }
    }
    
    
    return FHHouseRentFilterTypeNone;
    
    
}

#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject
{

    //JUMP to cat list page
    [self.viewController.navigationController popViewControllerAnimated:NO];
    
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    NSMutableDictionary *tracerDict = [self baseLogParam];
    [tracerDict addEntriesFromDictionary:allInfo[@"houseSearch"]];
    tracerDict[@"category_name"] = @"rent_list";
    tracerDict[UT_ELEMENT_FROM] = @"renting_search";
    tracerDict[@"page_type"] = @"renting";
    
    NSMutableDictionary *houseSearchDict = [[NSMutableDictionary alloc] initWithDictionary:allInfo[@"houseSearch"]];
    houseSearchDict[@"page_type"] = @"renting";
    allInfo[@"houseSearch"] = houseSearchDict;
    allInfo[@"tracer"] = tracerDict;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:allInfo];
    
    routeObject.paramObj.userInfo = userInfo;        
    [[TTRoute sharedRoute] openURLByPushViewController:routeObject.paramObj.sourceURL userInfo:routeObject.paramObj.userInfo];

}

-(void)resetCondition
{
//    self.resetConditionBlock(nil);
}

-(void)backAction:(UIViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}


#pragma mark - network changed
-(void)connectionChanged:(NSNotification *)notification
{
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status != NotReachable) {
        //有网络了，重新请求
        if (!self.errorMaskView.isHidden) {
            //只有在显示错误的时候才自动刷新
            [self requestData:YES];
        }
    }
}

@end

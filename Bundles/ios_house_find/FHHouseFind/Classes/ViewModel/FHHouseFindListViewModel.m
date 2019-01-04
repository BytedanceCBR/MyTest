//
//  FHHouseFindListViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindListViewModel.h"
#import "FHHouseFindCollectionCell.h"
#import "TTRoute.h"
#import "FHEnvContext.h"
#import "FHHomeConfigManager.h"

#define kFHHouseFindCollectionViewCell @"kFHHouseFindCollectionViewCell"
@interface FHHouseFindListViewModel () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,weak)UICollectionView *collectionView;
@property(nonatomic,strong)FHTracerModel *tracerModel;
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , strong) FHConfigDataModel *configDataModel;

@end

@implementation FHHouseFindListViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self) {
        
        __weak typeof(self)wself = self;
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        [self.collectionView registerClass:[FHHouseFindCollectionCell class] forCellWithReuseIdentifier:kFHHouseFindCollectionViewCell];
        
        self.configDataModel = [[FHEnvContext sharedInstance]getConfigFromCache];
        //订阅config变化
        __block BOOL isFirstChange = YES;
        [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            
            //过滤多余刷新
            if (wself.configDataModel == [[FHEnvContext sharedInstance]getConfigFromCache] && !isFirstChange) {
                return;
            }
            wself.configDataModel = [[FHEnvContext sharedInstance]getConfigFromCache];
            [wself refreshDataWithConfigDataModel];
            isFirstChange = NO;
        }];
        [self refreshDataWithConfigDataModel];
    }
    
    return self;
}

- (void)refreshDataWithConfigDataModel
{
    [self.collectionView reloadData];
}

- (void)jump2GuessVC
{
    NSDictionary *traceParam = [self.tracerModel toDictionary] ? : @{};
    //sug_list
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(3), // list
                           @"sug_delegate":sugDelegateTable
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://sug_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

- (void)setTracerModel:(FHTracerModel *)tracerModel
{
    _tracerModel = tracerModel;
    self.originFrom = tracerModel.originFrom;
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.configDataModel.opData.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFHHouseFindCollectionViewCell forIndexPath:indexPath];
    if (indexPath.item < self.configDataModel.opData.items.count) {
        
        FHConfigDataOpDataItemsModel *item = self.configDataModel.opData.items[indexPath.item];
        [cell updateDataWithOpenUrl:item.openUrl];
    }

    return cell;
}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return self.collectViewSize;
//}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

    //    if ((_userDrag && ![self.lastCategoryID isEqualToString:self.currentCategory.categoryID]) || _userClick) {
//        if ([[cell class] conformsToProtocol:@protocol(TTFeedCollectionCell)]) {
//            id<TTFeedCollectionCell> collectionCell = (id<TTFeedCollectionCell>)cell;
//
//            if ([collectionCell respondsToSelector:@selector(willDisappear)]) {
//                [collectionCell willDisappear];
//            }
//
//            TTCategory *category = [self categoryAtIndex:indexPath.item];
//            [self leaveCategory:category];
//
//            if ([collectionCell respondsToSelector:@selector(didDisappear)]) {
//                [collectionCell didDisappear];
//            }
//        }
//    }
}


@end

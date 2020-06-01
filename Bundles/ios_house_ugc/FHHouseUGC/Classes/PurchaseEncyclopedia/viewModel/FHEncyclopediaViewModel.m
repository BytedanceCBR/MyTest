//
//  FHEncyclopediaViewModel.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/21.
//

#import "FHEncyclopediaViewModel.h"
#import "FHHouseUGCAPI.h"
#import "ToastManager.h"
#import "FHEnvContext.h"
#import "FHUGCEncyclopediaListCell.h"
#import "UIViewAdditions.h"
#import "UIDevice+BTDAdditions.h"
#import "FHUGCencyclopediaTracerHelper.h"
@interface FHEncyclopediaViewModel()<UICollectionViewDelegate,UICollectionViewDataSource,FHEncyclopediaHeaderDelegate>
@property (weak, nonatomic) FHEncyclopediaViewController *baseVC;
@property (weak, nonatomic) UICollectionView *mainCollection;
@property (weak,nonatomic) FHEncyclopediaHeader *encyclopediaHeader;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, strong) EncyclopediaDataModel *encyclopediaModel;
@property(nonatomic, strong)FHUGCencyclopediaTracerHelper *tracerHelper;
@end

@implementation FHEncyclopediaViewModel
- (instancetype)initWithWithController:(FHEncyclopediaViewController *)viewController collectionView:(UICollectionView *)collectionView headerView:(FHEncyclopediaHeader *)header tracerModel:(nonnull FHTracerModel *)tracerModel {
    self = [super init];
    if (self) {
        self.baseVC = viewController;
        self.mainCollection = collectionView;
        self.encyclopediaHeader = header;
        self.encyclopediaHeader.delegate = self;
        self.currentTabIndex = 0;
        self.tracerModel = tracerModel;
        self.categoryId = @"f_house_encyclopedia";
        [self requestHeaderConfig];
        [self configTracerHelper];
    }
    return self;
}

- (void)configTracerHelper {
    _tracerHelper = [[FHUGCencyclopediaTracerHelper alloc]init];
}

- (void)setTracerModel:(FHTracerModel *)tracerModel {
    _tracerModel = tracerModel;
    _tracerHelper.tracerModel = tracerModel;
}
- (void)configCollection {
    self.mainCollection.delegate = self;
    self.mainCollection.dataSource = self;
}

- (void)requestHeaderConfig {
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    [FHHouseUGCAPI requestEncyclopediaConfigWithCategory:self.categoryId extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (error) {
                [[ToastManager manager] showToast:@"网络异常"];
                        return;
        }else {
            EncyclopediaConfigDataModel *configModel = (EncyclopediaConfigDataModel *)model;
            NSMutableArray *items = configModel.items.mutableCopy;
            [items insertObject:@{@"text":@"全部",@"channel_id":@(0),@"options":@""} atIndex:0];
            configModel.items = items;
            [self.encyclopediaHeader updateModel:configModel];
            [self collectionDataCrate:configModel.items];
        }
    }];
}

- (void)collectionDataCrate:(NSArray *)array {
    [self.dataList addObjectsFromArray:array];
     [self configCollection];
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}

#pragma mark - UICollectionViewDelegate

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_%ld", [indexPath row]];
    [collectionView registerClass:[FHUGCEncyclopediaListCell class] forCellWithReuseIdentifier:cellIdentifier];
    FHUGCEncyclopediaListCell *cell = (FHUGCEncyclopediaListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.tracerModel = self.tracerModel;
    cell.headerConfigData = self.dataList[indexPath.row];
    [self.baseVC addChildViewController:cell.contentViewController];
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat bottom = 49;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 11.0, *)) {
        safeTop = self.baseVC.view.tt_safeAreaInsets.top;
    }
    if (safeTop > 0) {
        top += safeTop;
    } else {
        if([[UIApplication sharedApplication] statusBarFrame].size.height > 0){
            top += [[UIApplication sharedApplication] statusBarFrame].size.height;
        }else{
            if([UIDevice btd_isIPhoneXSeries]){
                top += 44;
            }else{
                top += 20;
            }
        }
    }
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - top - bottom);
    
    return size;
}
//头部选择事件
- (void)selectSegmentWithData:(id)param {
    __block NSInteger index = 0;
    if ([param isKindOfClass:[NSString class]]) {
        NSDictionary *selectData = [self dictionaryWithJsonString:param];
        [self.dataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *data = (NSDictionary *)obj;
            if ([[NSString stringWithFormat:@"%@",data[@"channel_id"]] isEqualToString:[NSString stringWithFormat:@"%@",selectData[@"channel_id"]]]) {
                index = idx;
            }
        }];
    }else {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
     [self.mainCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self.tracerHelper trackHeaderSegmentClickOptions:index+1];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end

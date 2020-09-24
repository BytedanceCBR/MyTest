//
//  FHShortVideoDetailFetchManager.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/9/18.
//

#import "FHShortVideoDetailFetchManager.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager/TTNetworkManager.h"
#import "HTSVideoPlayJSONResponseSerializer.h"
#import "TSVShortVideoDecoupledFetchManager.h"
#import "TSVChannelDecoupledConfig.h"
#import "ReactiveObjC.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHHouseUGCAPI.h"
#import "FHUGCShortVideoRealtorInfoModel.h"
#import "FHEnvContext.h"
#import "FHHouseUGCAPI.h"
#import "TTHttpTask.h"
#import "FHFeedListModel.h"
#import "FHMainApi.h"
#import "NSDictionary+BTDAdditions.h"


@interface FHShortVideoDetailFetchManager()
@property (nonatomic, strong) NSMutableArray<FHFeedUGCCellModel *> *awemedDetailItems;
@property (nonatomic, strong) TSVShortVideoDecoupledFetchManager *decoupledFetchManager;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property (nonatomic, strong) FHUGCShortVideoRealtorInfo *realtorInfo;
@end
@implementation FHShortVideoDetailFetchManager


- (NSUInteger)numberOfShortVideoItems
{
    return [self.awemedDetailItems count];
}

- (FHFeedUGCCellModel *)itemAtIndex:(NSInteger)index
{
//    return [self itemAtIndex:index replaced:YES];
    return [self.awemedDetailItems objectAtIndex:index];
}

//- (FHFeedUGCCellModel *)itemAtIndex:(NSInteger)index replaced:(BOOL)replaced
//{
//    NSParameterAssert(index < [self.awemedDetailItems count]);
//
//    if (replaced && self.replacedModel && index == self.replacedIndex) {
//        return self.replacedModel;
//    } else if (index < [self.awemedDetailItems count]) {
//        return [self.awemedDetailItems objectAtIndex:index];
//    }
//    return nil;
//}


- (void)requestDataForGroupIdAutomatically:(BOOL)isAutomatically
                               finishBlock:(TTFetchListFinishBlock)finishBlock
{
    NSString *urlStr = [ArticleURLSetting shortVideoInfoURL];
    NSDictionary *params = @{
        @"group_id" : self.groupID,
    };
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:params method:@"POST" needCommonParams:YES requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (error || jsonObj == nil || jsonObj[@"data"] == nil) {
            if (finishBlock){
                finishBlock(0,error);
            }
            return;
        }
        if (![jsonObj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *dic = @{@"raw_data":jsonObj[@"data"],@"cell_type":@(FHUGCFeedListCellTypeUGCSmallVideo)};
        FHFeedUGCCellModel *cellModle = [FHFeedUGCCellModel modelFromFeed:dic];
        if (!cellModle) {
            return;
        }
        [self.awemedDetailItems addObject:cellModle];
        if (wself.dataDidChangeBlock) {
            wself.dataDidChangeBlock();
        }
    }];
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
//    NSString *refreshType = @"pre_load_more";
    
//    [self trackCategoryRefresh:refreshType];
    
    NSInteger listCount = self.awemedDetailItems.count;
    
    double behotTime = 0;
    if(listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.awemedDetailItems lastObject];
        behotTime = [cellModel.behotTime doubleValue];
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    __weak typeof(self)wself = self;
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:YES isFirst:NO listCount:10 extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        if (error) {
            return;
        }
        if(model){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSArray *result = [wself convertModel:feedListModel.data isHead:NO];
                [wself.awemedDetailItems addObjectsFromArray:result];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (wself.dataDidChangeBlock) {
                        wself.dataDidChangeBlock();
                    }
                });
            });
        }
    }];
    
}

- (void)setCurrentShortVideoModel:(FHFeedUGCCellModel *)currentShortVideoModel {
    self.awemedDetailItems = [[NSMutableArray alloc]init];
    if (currentShortVideoModel) {
            [self.awemedDetailItems addObject:currentShortVideoModel];
    }else {
        [self requestDataForGroupIdAutomatically:YES finishBlock:^(NSUInteger increaseCount, NSError *error) {
        }];
    }
}

- (void)setOtherShortVideoModels:(NSArray<FHFeedUGCCellModel *> *)otherShortVideoModels {
    [self.awemedDetailItems addObjectsFromArray:otherShortVideoModels];
    NSInteger numberOfItemLeft = self.numberOfShortVideoItems - self.currentIndex;
    if (numberOfItemLeft<=4) {
        [self requestDataAutomatically:YES finishBlock:^(NSUInteger increaseCount, NSError *error) {
        }];
    }
}

- (NSArray *)convertModel:(NSArray *)feedList isHead:(BOOL)isHead {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo || cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo2){
            cellModel.categoryId = self.categoryId;
            cellModel.enterFrom = self.enterFrom;
//            if(cellModel){
//                if(isHead){
                    [resultArray addObject:cellModel];
//                    //去重逻辑
//                    [self removeDuplicaionModel:cellModel.groupId];
//                }else{
//                    NSInteger index = [self getCellIndex:cellModel];
//                    if(index < 0){
//                        [resultArray addObject:cellModel];
//                    }
//                }
//            }
        }
    }
    return resultArray;
}

- (void)removeDuplicaionModel:(NSString *)groupId {
    for (FHFeedUGCCellModel *itemModel in self.awemedDetailItems) {
        if([groupId isEqualToString:itemModel.groupId]){
            [self.awemedDetailItems removeObject:itemModel];
            break;
        }
    }
}

- (NSInteger)getCellIndex:(FHFeedUGCCellModel *)cellModel {
    for (NSInteger i = 0; i < self.awemedDetailItems.count; i++) {
        FHFeedUGCCellModel *model = self.awemedDetailItems[i];
        if([model.groupId isEqualToString:cellModel.groupId]){
            return i;
        }
    }
    return -1;
}
@end

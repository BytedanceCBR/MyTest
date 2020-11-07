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
@property (nonatomic, weak) TTHttpTask *requestTask;
@property (nonatomic, strong) FHUGCShortVideoRealtorInfo *realtorInfo;
@property (nonatomic, assign) BOOL isLoadingMoreData;
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
//    NSString *urlStr = [ArticleURLSetting shortVideoInfoURL];
//    NSDictionary *params = @{
//        @"group_id" : self.groupID,
//    };
//    WeakSelf;
//    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:params method:@"POST" needCommonParams:YES requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:^(NSError *error, id jsonObj) {
//        StrongSelf;
//        if (error || jsonObj == nil || jsonObj[@"data"] == nil) {
//            if (finishBlock){
//                finishBlock(0,error);
//            }
//            return;
//        }
//        if (![jsonObj isKindOfClass:[NSDictionary class]]) {
//            return;
//        }
//        NSDictionary *dic = @{@"raw_data":jsonObj[@"data"],@"cell_type":@(FHUGCFeedListCellTypeUGCSmallVideo)};
//        FHFeedUGCCellModel *cellModle = [FHFeedUGCCellModel modelFromFeed:dic];
//        if (!cellModle) {
//            return;
//        }
//        [self.awemedDetailItems addObject:cellModle];
//        if (wself.dataDidChangeBlock) {
//            wself.dataDidChangeBlock();
//        }
//    }];
}

- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    if(self.isLoadingMoreData){
        return;
    }
    
    self.isLoadingMoreData = YES;
    
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
    [extraDic setValue:self.groupID forKey:@"group_id"];
    [extraDic setValue:self.topID forKey:@"top_id"];
    __weak typeof(self)wself = self;
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:YES isFirst:NO listCount:10 extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        if (error) {
            wself.isLoadingMoreData = NO;
            if (wself.dataDidChangeBlock) {
                wself.dataDidChangeBlock();
            }
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
                    wself.isLoadingMoreData = NO;
                });
            });
        }else{
            wself.isLoadingMoreData = NO;
        }
    }];
    
}

- (void)setCurrentShortVideoModel:(FHFeedUGCCellModel *)currentShortVideoModel {
    self.awemedDetailItems = [[NSMutableArray alloc]init];
    if (currentShortVideoModel && currentShortVideoModel.originContent) {
        FHFeedUGCCellModel *cellmodel = [FHFeedUGCCellModel modelFromFeed:currentShortVideoModel.originContent];
        if (cellmodel) {
            cellmodel.tracerDic =  [self trackDict:currentShortVideoModel rank:0];
            [self.awemedDetailItems addObject:cellmodel];
        }
    }
}

- (void)setOtherShortVideoModels:(NSArray<FHFeedUGCCellModel *> *)otherShortVideoModels {
    for (int m =0; m < otherShortVideoModels.count; m ++) {
        FHFeedUGCCellModel *itemModel = otherShortVideoModels[m];
        if (itemModel && itemModel.originContent) {
            FHFeedUGCCellModel *cellmodel = [FHFeedUGCCellModel modelFromFeed:itemModel.originContent];
            cellmodel.tracerDic =   [self trackDict:itemModel rank:self.awemedDetailItems.count + m];
            [self.awemedDetailItems addObject:cellmodel];
        }
    }
//    NSInteger numberOfItemLeft = self.numberOfShortVideoItems - self.currentIndex;
//    if (numberOfItemLeft<=4) {
//        [self requestDataAutomatically:YES finishBlock:^(NSUInteger increaseCount, NSError *error) {
//        }];
//    }
}

- (NSArray *)convertModel:(NSArray *)feedList isHead:(BOOL)isHead {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (int m =0; m<feedList.count; m++) {
        FHFeedListDataModel *itemModel = feedList[m];
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo || cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo2){
            cellModel.categoryId = self.categoryId;
            cellModel.enterFrom = self.enterFrom;
            cellModel.tracerDic = [self trackDict:cellModel rank:self.awemedDetailItems.count + m];
           [resultArray addObject:cellModel];
        }
    }
    return resultArray;
}

- (NSMutableDictionary *)trackDict:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.tracerDic[@"origin_from"] ?: @"be_null";
    dict[@"enter_from"] = self.tracerDic[@"enter_from"] ?: @"be_null";
    dict[@"page_type"] = self.tracerDic[@"page_type"]?:@"be_null";
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    dict[@"group_id"] = cellModel.groupId;
    if(cellModel.logPb[@"impr_id"]){
        dict[@"impr_id"] = cellModel.logPb[@"impr_id"];
    }
    if(cellModel.logPb[@"group_source"]){
        dict[@"group_source"] = cellModel.logPb[@"group_source"];
    }
    if(cellModel.fromGid){
        dict[@"from_gid"] = cellModel.fromGid;
    }
    if(cellModel.fromGroupSource){
        dict[@"from_group_source"] = cellModel.fromGroupSource;
    }
    return dict;
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

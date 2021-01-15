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

#define kRealtorRequestSuccessNotification @"kRealtorRequestSuccessNotification"
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



- (void)requestDataAutomatically:(BOOL)isAutomatically
                     finishBlock:(TTFetchListFinishBlock)finishBlock
{
    if(self.isLoadingMoreData){
        return;
    }
    
    if (!self.canLoadMore) {
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
        FHFeedUGCCellModel *cellmodel = [FHFeedUGCCellModel copyFromModel:currentShortVideoModel];
        if (cellmodel) {
            if (!self.canLoadMore) {
                [self handleCellModel:cellmodel];
            }
            cellmodel.tracerDic =  [self trackDict:currentShortVideoModel rank:0];
            [self.awemedDetailItems addObject:cellmodel];
        }
    }else {
        [self requestShortVideoByGroupId];
    }
}

- (void)requestShortVideoByGroupId {
    self.awemedDetailItems = [[NSMutableArray alloc]init];
    if ([self numberOfShortVideoItems] == 0 && !isEmptyString(self.groupID)) {
        NSString *urlStr = [ArticleURLSetting shortVideoInfoURL];
        NSDictionary *params = @{
                                 @"group_id" : self.groupID,
                                 };
        self.isLoadingRequest = YES;
        WeakSelf;
        [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr params:params method:@"POST" needCommonParams:YES requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:^(NSError *error, id jsonObj) {
            StrongSelf;
            if (error || jsonObj == nil || jsonObj[@"data"] == nil) {
                self.hasMoreToLoad = NO;
                self.isLoadingRequest = NO;
                return;
            }
            NSMutableDictionary *fixedDict = [NSMutableDictionary dictionary];
            [fixedDict setValue:jsonObj[@"data"] forKey:@"raw_data"];
            
            NSDictionary *dic = @{@"raw_data":jsonObj[@"data"],@"cell_type":@(FHUGCFeedListCellTypeUGCSmallVideo)};
            FHFeedUGCCellModel *cellModle = [FHFeedUGCCellModel modelFromFeed:dic];
            cellModle.tracerDic = [self trackDict:cellModle rank:0];
            NSString *enter_from = self.tracerDic[@"enter_from"];
            if ([enter_from isEqualToString:@"favorite"]) {
                cellModle.userRepin = YES;
            }
            if (!cellModle) {
                return;
            }
            [self handleCellModel:cellModle];
            NSMutableDictionary *tracerDic = [self.tracerDic mutableCopy];
            [tracerDic setValue:self.groupID forKey:@"group_id"];
            cellModle.tracerDic = [tracerDic copy];
            [self.awemedDetailItems addObject:cellModle];
            if (wself.dataDidChangeBlock) {
                wself.dataDidChangeBlock();
            }
        }];
    }
}

- (void)handleCellModel:(FHFeedUGCCellModel *)cellModel {
    __weak typeof(self)weakSelf = self;
        [FHHouseUGCAPI requestShortVideoWithGroupId:self.groupID completion:^(id<FHBaseModelProtocol>  _Nonnull models, NSError * _Nonnull errors) {
            if (!errors && models) {
                FHUGCShortVideoRealtor *realtor = [(FHUGCShortVideoRealtorInfoModel *)models data];
                weakSelf.realtorInfo = realtor.realtor;
            }
            if (weakSelf.realtorInfo) {
                FHFeedUGCCellRealtorModel *realtor = [[FHFeedUGCCellRealtorModel alloc] init];
                realtor.avatarUrl  = weakSelf.realtorInfo.avatarUrl;
                realtor.avatarTagUrl =  weakSelf.realtorInfo.imageTag.imageUrl;
                realtor.realtorId  = weakSelf.realtorInfo.realtorId;
                realtor.realtorName  =  weakSelf.realtorInfo.realtorName;
                realtor.firstBizType = weakSelf.realtorInfo.firstBizType;
                cellModel.realtor = realtor;
                
                FHFeedUGCCellUserModel *user = cellModel.user;
                
                if (realtor.realtorId.length>0) {
                    user.name = realtor.realtorName;
                    user.avatarUrl = realtor.avatarUrl;
                    user.realtorId = realtor.realtorId;
                    user.firstBizType = realtor.firstBizType;
                }
            }
            NSMutableArray *awemeDetailItems = [NSMutableArray array];
            if (cellModel) {
                [awemeDetailItems addObject:cellModel];
            }
            self.awemedDetailItems = awemeDetailItems;
            self.isLoadingRequest = NO;
            NSDictionary *cellModelDic = @{@"cellModel":cellModel};
            [[NSNotificationCenter defaultCenter] postNotificationName:kRealtorRequestSuccessNotification object:cellModel userInfo:cellModelDic];
        }];

}



- (void)setOtherShortVideoModels:(NSArray<FHFeedUGCCellModel *> *)otherShortVideoModels {
    for (int m =0; m < otherShortVideoModels.count; m ++) {
        FHFeedUGCCellModel *itemModel = otherShortVideoModels[m];
        if (itemModel && itemModel.originContent) {
            FHFeedUGCCellModel *cellmodel = [FHFeedUGCCellModel copyFromModel:itemModel];
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

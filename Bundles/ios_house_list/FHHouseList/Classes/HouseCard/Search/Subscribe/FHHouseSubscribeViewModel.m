//
//  FHHouseSubscribeViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseSubscribeViewModel.h"
#import "TTHttpTask.h"
#import "FHHouseListAPI.h"
#import "FHSuggestionSubscribCell.h"
#import "FHSugSubscribeModel.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "NSDictionary+BTDAdditions.h"

@interface FHHouseSubscribeViewModel()
@property (nonatomic, weak) TTHttpTask *requestTask;
@property (nonatomic, copy) NSDictionary *subScribeShowDict;
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseSubscribeViewModel

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showed) return;
    self.showed = YES;
    NSInteger rankOffset = [self.context btd_integerValueForKey:@"rank_offset"];
    NSInteger rank = indexPath.row + rankOffset;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"rank"] = @(rank);
    tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
    tracerDict[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : @"be_null";
    tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : @"be_null";
    
    FHSugSubscribeDataDataSubscribeInfoModel *cellSubModel = (FHSugSubscribeDataDataSubscribeInfoModel *)self.model;
    if ([cellSubModel.subscribeId isKindOfClass:[NSString class]] && [cellSubModel.subscribeId integerValue] != 0) {
        tracerDict[@"subscribe_id"] = cellSubModel.subscribeId;
    }else {
        tracerDict[@"subscribe_id"] = @"be_null";
    }
    tracerDict[@"title"] = cellSubModel.title ? : @"be_null";
    tracerDict[@"text"] = cellSubModel.text ? : @"be_null";

    self.subScribeShowDict = tracerDict;
    [FHUserTracker writeEvent:@"subscribe_show" params:tracerDict];
}

- (void)requestDeleteSubScribe:(NSString *)subscribeId
{
    FHSugSubscribeDataDataSubscribeInfoModel *subscribModel = (FHSugSubscribeDataDataSubscribeInfoModel *)self.model;
    NSString *text = subscribModel.text;
    
    [_requestTask cancel];
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseListAPI requestDeleteSugSubscribe:subscribeId class:nil completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!error) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if (text.length > 0) {
                [dict setValue:text forKey:@"text"];
            }
            [dict setValue:@"0" forKey:@"status"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionSubscribeNotificationKey object:nil userInfo:dict];
            
            NSMutableDictionary *uiDict = [NSMutableDictionary new];
            [uiDict setValue:@(NO) forKey:@"subscribe_state"];
            [uiDict setValue:subscribeId forKey:@"subscribe_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHSugSubscribeNotificationName" object:uiDict];
            
            
            if (wself.subScribeShowDict) {
                NSMutableDictionary *traceParams = [NSMutableDictionary dictionaryWithDictionary:self.subScribeShowDict];
                [traceParams setValue:@"cancel" forKey:@"click_type"];
                TRACK_EVENT(@"subscribe_click",traceParams);
            }
        }
    }];
    
    self.requestTask = task;
}

- (void)requestAddSubScribe:(NSString *)text {
    [_requestTask cancel];
    __weak typeof(self) wself = self;
    NSDictionary *paramsDict = nil;
    NSInteger houseType = [self.context btd_integerValueForKey:@"house_type"];
    if (houseType) {
        paramsDict = @{@"house_type":@(houseType)};
    }
    
    NSString *subScribeQuery = [self.context btd_stringValueForKey:@"subscribe_query"];
    NSString *subScribeSearchId = [self.context btd_stringValueForKey:@"subscribe_search_id"];
    NSInteger subScribeOffset = [self.context btd_integerValueForKey:@"subscribe_offset"];
    
    TTHttpTask *task = [FHHouseListAPI requestAddSugSubscribe:subScribeQuery params:paramsDict offset:subScribeOffset searchId:subScribeSearchId sugParam:nil class:[FHSugSubscribeModel class] completion:^(id<FHBaseModelProtocol>  _Nullable model, NSError * _Nullable error) {
        if ([model isKindOfClass:[FHSugSubscribeModel class]]) {
            FHSugSubscribeModel *infoModel = (FHSugSubscribeModel *)model;
            if ([infoModel.data.items.firstObject isKindOfClass:[FHSugSubscribeDataDataItemsModel class]]) {
                FHSugSubscribeDataDataItemsModel *subModel = (FHSugSubscribeDataDataItemsModel *)infoModel.data.items.firstObject;
                
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setValue:text ? : @"" forKey:@"text"];
                [dict setValue:@"1" forKey:@"status"];
                [dict setValue:subModel.subscribeId forKey:@"subId"];

                [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionSubscribeNotificationKey object:nil userInfo:dict];
                
                NSMutableDictionary *uiDict = [NSMutableDictionary new];
                [uiDict setValue:@(YES) forKey:@"subscribe_state"];
                [uiDict setValue:subModel.subscribeId ? : @"" forKey:@"subscribe_id"];
                [uiDict setValue:subModel forKey:@"subscribe_item"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHSugSubscribeNotificationName" object:uiDict];
                
                NSMutableDictionary *dictClickParams = [NSMutableDictionary new];
                
                if (self.subScribeShowDict) {
                    [dictClickParams addEntriesFromDictionary:self.subScribeShowDict];
                }
                
                if (subModel.subscribeId) {
                    [dictClickParams setValue:subModel.subscribeId forKey:@"subscribe_id"];
                }
                
                if (subModel.title) {
                    [dictClickParams setValue:subModel.title forKey:@"title"];
                }else
                {
                    [dictClickParams setValue:@"be_null" forKey:@"title"];
                }
                
                if (subModel.text) {
                    [dictClickParams setValue:subModel.text forKey:@"text"];
                }else
                {
                    [dictClickParams setValue:@"be_null" forKey:@"text"];
                }
                
                if (dictClickParams) {
                    self.subScribeShowDict = [NSDictionary dictionaryWithDictionary:dictClickParams];
                }
                
                if (wself.subScribeShowDict) {
                    [dictClickParams setValue:@"confirm" forKey:@"click_type"];
                    TRACK_EVENT(@"subscribe_click",dictClickParams);
                }
            }
        }
    }];
    
    self.requestTask = task;
}

@end

//
//  FHNewHouseDetailRGCListSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailRGCListSM.h"
#import "FHFeedUGCCellModel.h"

@implementation FHNewHouseDetailRGCListSM

- (void)updateModel:(FHDetailNewModel *)model {
    
    self.contentModel = model.data.realtorContent.content;
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    for (int m = 0; m < _contentModel.data.count;  m++) {
        NSString *content = _contentModel.data[m];
        FHFeedUGCCellModel *model = [FHFeedUGCCellModel modelFromFeed:content];
        model.realtorIndex = m;
        model.isShowLineView = m < _contentModel.data.count -1;
        switch (model.cellType) {
            case FHUGCFeedListCellTypeUGC:
                model.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerImage;
                break;
            case FHUGCFeedListCellTypeUGCSmallVideo:
                model.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerVideo;
                break;
            default:
                break;
        }
        //        model.tracerDic = self.detailTracerDic;
        NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
        tracerDic[@"rank"] = @(m);
        tracerDic[@"origin_from"] = self.detailTracerDic[@"origin_from"] ?: @"be_null";
        tracerDic[@"enter_from"] = self.detailTracerDic[@"enter_from"] ?: @"be_null";
        tracerDic[@"page_type"] = self.detailTracerDic[@"page_type"] ?: @"be_null";
        tracerDic[@"element_type"] = @"realtor_evaluate";
        tracerDic[@"group_id"] = model.groupId;
        tracerDic[@"from_gid"] = self.extraDic[@"houseId"];
        tracerDic[@"log_pb"] = model.logPb;
        if(model.logPb[@"impr_id"]){
            tracerDic[@"impr_id"] = model.logPb[@"impr_id"];
        }
        if(model.logPb[@"group_source"]){
            tracerDic[@"group_source"] = model.logPb[@"group_source"];
        }
        model.tracerDic = [tracerDic copy];
        
        if (model) {
            [dataArr addObject:model];
        }
    }
    self.contentModel.fHFeedUGCCellModelDataArr = dataArr;
    self.items = dataArr.copy;
        
    self.title = model.data.realtorContent.title;
    self.count = model.data.realtorContent.content.count;
}



- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end

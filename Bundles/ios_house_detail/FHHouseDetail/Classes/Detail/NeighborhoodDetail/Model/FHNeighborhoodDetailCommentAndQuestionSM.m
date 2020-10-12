//
//  FHNeighborhoodDetailCommentAndQuestionSM.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/12.
//

#import "FHNeighborhoodDetailCommentAndQuestionSM.h"
#import "FHFeedUGCCellModel.h"

@implementation FHNeighborhoodDetailCommentAndQuestionSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    //有点评
    BOOL isHaveComment = NO;
    NSMutableArray *itemArray = [NSMutableArray array];
    if(model.data.comments.content.data.count > 0){
        isHaveComment = YES;
        FHNeighborhoodDetailCommentHeaderModel *commentHeaderModel = [[FHNeighborhoodDetailCommentHeaderModel alloc] init];
        commentHeaderModel.title = model.data.comments.title;
        commentHeaderModel.subTitle = @"超过XX位小区业主和附近居民进行了评分";
        commentHeaderModel.commentsListSchema = model.data.comments.content.commentsListSchema;
        [itemArray addObject:commentHeaderModel];
        
        self.contentModel = model.data.comments.content;
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
//                [itemArray addObject:model];
            }
        }
    }
    
    self.items = [itemArray copy];
        
    self.title = model.data.comments.title;
    self.count = @([model.data.comments.content.count integerValue]);
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end

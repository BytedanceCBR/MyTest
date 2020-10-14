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
    BOOL isHaveComment = (model.data.comments.content.data.count > 0);
    //有问答
    BOOL isHaveQuestion = (model.data.question != nil);
    
    NSMutableArray *itemArray = [NSMutableArray array];
    if(model.data.comments.content.data.count > 0){
        FHDetailNeighborhoodDataCommentsContentModel *contentModel = model.data.comments.content;
        self.commentHeaderModel = [[FHNeighborhoodDetailCommentHeaderModel alloc] init];
        _commentHeaderModel.title = model.data.comments.title;
        _commentHeaderModel.totalCount = [contentModel.count integerValue];
        _commentHeaderModel.count = contentModel.data.count;
        if(!isEmptyString(model.data.comments.content.count)){
            NSInteger totalCount = [contentModel.count integerValue];
            if(totalCount > 0 && contentModel.data.count > 0){
                _commentHeaderModel.title = [NSString stringWithFormat:@"%@（%li）",_commentHeaderModel.title,(long)totalCount];
            }
        }
        
        _commentHeaderModel.subTitle = @"超过XX位小区业主和附近居民进行了评分";
        _commentHeaderModel.commentsListSchema = model.data.comments.content.commentsListSchema;
        _commentHeaderModel.neighborhoodId = model.data.id;
        _commentHeaderModel.detailTracerDic = self.detailTracerDic;
        [itemArray addObject:_commentHeaderModel];
        
        //有评论时候
        FHNeighborhoodDetailSpaceModel *spaceModel = [[FHNeighborhoodDetailSpaceModel alloc] init];
        spaceModel.height = 14;
        [itemArray addObject:spaceModel];
        //评论tag
        self.commentTagsModel = [[FHNeighborhoodDetailCommentTagsModel alloc] init];
        
        NSMutableArray *tags = [NSMutableArray array];
        
        FHNeighborhoodDetailCommentTagModel *tag = [[FHNeighborhoodDetailCommentTagModel alloc] init];
        tag.persent = @"80%";
        tag.content = @"小区的物业很棒";
        [tags addObject:tag];
        
        FHNeighborhoodDetailCommentTagModel *tag1 = [[FHNeighborhoodDetailCommentTagModel alloc] init];
        tag1.persent = @"77%";
        tag1.content = @"离地铁很近";
        [tags addObject:tag1];
        
        FHNeighborhoodDetailCommentTagModel *tag2 = [[FHNeighborhoodDetailCommentTagModel alloc] init];
        tag2.persent = @"53%";
        tag2.content = @"附近菜市场物美价廉";
        [tags addObject:tag2];
        
        FHNeighborhoodDetailCommentTagModel *tag3 = [[FHNeighborhoodDetailCommentTagModel alloc] init];
        tag3.persent = @"21%";
        tag3.content = @"交通便利";
        [tags addObject:tag3];
        
        FHNeighborhoodDetailCommentTagModel *tag4 = [[FHNeighborhoodDetailCommentTagModel alloc] init];
        tag4.persent = @"3%";
        tag4.content = @"周边配套设施完善 教育资源丰富 环境很优美";
        [tags addObject:tag4];
        
        _commentTagsModel.tags = tags;
        
        [itemArray addObject:_commentTagsModel];
        
        for (int m = 0; m < contentModel.data.count;  m++) {
            NSString *content = contentModel.data[m];
            FHFeedUGCCellModel *model = [FHFeedUGCCellModel modelFromFeed:content];
            model.isInNeighbourhoodCommentsList = NO;
            model.realtorIndex = m;
            model.isShowLineView = m < contentModel.data.count -1;


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
                [itemArray addObject:model];
            }
        }
        
        FHNeighborhoodDetailSpaceModel *spaceModel1 = [[FHNeighborhoodDetailSpaceModel alloc] init];
        spaceModel1.height = isHaveQuestion ? 16 : 20;
        [itemArray addObject:spaceModel1];
    }
    
    if(model.data.question){
        self.questionHeaderModel = [[FHNeighborhoodDetailQuestionHeaderModel alloc] init];
        if(model.data.question.content.data.count > 0){
            FHDetailNeighborhoodDataQuestionContentModel *contentModel = model.data.question.content;
            _questionHeaderModel.title = model.data.question.title;
            _questionHeaderModel.totalCount = [contentModel.count integerValue];
            _questionHeaderModel.count = contentModel.data.count;
            if(!isEmptyString(model.data.question.content.count)){
                NSInteger totalCount = [contentModel.count integerValue];
                if(totalCount > 0 && contentModel.data.count > 0){
                    _questionHeaderModel.title = [NSString stringWithFormat:@"%@（%li）",_questionHeaderModel.title,(long)totalCount];
                }
            }
            
            _questionHeaderModel.isEmpty = NO;
            _questionHeaderModel.hiddenTopLine = !isHaveComment;
            _questionHeaderModel.topMargin = isHaveComment ? 14 : 18;
            _questionHeaderModel.questionListSchema = model.data.question.content.questionListSchema;
            _questionHeaderModel.neighborhoodId = model.data.id;
            _questionHeaderModel.detailTracerDic = self.detailTracerDic;
            [itemArray addObject:_questionHeaderModel];
            
            for (int m = 0; m < contentModel.data.count;  m++) {
                NSString *content = contentModel.data[m];
                FHFeedUGCCellModel *model = [FHFeedUGCCellModel modelFromFeed:content];
                model.realtorIndex = m;
                model.isShowLineView = m < contentModel.data.count -1;

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
                    [itemArray addObject:model];
                }
            }
            
            FHNeighborhoodDetailSpaceModel *spaceModel = [[FHNeighborhoodDetailSpaceModel alloc] init];
            spaceModel.height = 15;
            [itemArray addObject:spaceModel];
        }else{
            _questionHeaderModel.title = @"暂无回答";
            _questionHeaderModel.totalCount = 0;
            _questionHeaderModel.count = 0;
            _questionHeaderModel.hiddenTopLine = !isHaveComment;
            _questionHeaderModel.topMargin = isHaveComment ? 14 : 18;
            _questionHeaderModel.isEmpty = YES;
            _questionHeaderModel.questionWriteTitle = model.data.question.questionWrite.title;
            _questionHeaderModel.questionWriteSchema = model.data.question.questionWrite.schema;
            _questionHeaderModel.questionWriteEmptyContent = model.data.question.questionWrite.contentEmptyTitle;
            _questionHeaderModel.neighborhoodId = model.data.id;
            _questionHeaderModel.detailTracerDic = self.detailTracerDic;
            [itemArray addObject:_questionHeaderModel];
        }
    }
    
    self.items = [itemArray copy];
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end

//
//  FHFeedUGCCellModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import "FHFeedUGCCellModel.h"
#import "FHMainApi.h"
#import <FHHouseBase/FHBusinessManager.h>
#import "TTBaseMacro.h"
#import "FHUGCCellHelper.h"
#import "TTVideoApiModel.h"
#import "TTVFeedItem+Extension.h"
#import "FHLocManager.h"
#import "TTBusinessManager+StringUtils.h"
#import "JSONAdditions.h"

@implementation FHFeedUGCCellCommunityModel

@end

@implementation FHFeedUGCVoteModel

@end

@implementation FHFeedUGCCellUserModel

@end

@implementation FHFeedUGCOriginItemModel

@end

@implementation FHFeedUGCCellContentDecorationModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _showCommunity = YES;
        _bottomLineHeight = 5;
    }
    return self;
}

+ (FHFeedContentModel *)contentModelFromFeedContent:(NSString *)content {
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    NSDictionary *dic = nil;
    @try {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingMutableContainers
                                                error:&err];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    if(!err){
        Class cls = [FHFeedContentModel class];
        __block NSError *backError = nil;
        id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:cls error:&backError];
        if(!backError){
            return model;
        }
    }
    
    return nil;
}

+ (FHFeedUGCCellModel *)modelFromFeed:(id)content {
    FHFeedUGCCellModel *cellModel = nil;
    NSError *err = nil;
    NSDictionary *dic = nil;
    NSString *jsonStr = nil;
    NSData *jsonData = nil;
    
    if([content isKindOfClass:[NSString class]]){
        jsonStr = content;
        jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        @try {
            dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:NSJSONReadingMutableContainers
                                                    error:&err];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }else if([content isKindOfClass:[NSDictionary class]]){
        dic = content;
        jsonStr = [dic tt_JSONRepresentation];
        jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        return cellModel;
    }
    
    if(!err){
        FHUGCFeedListCellType type = [dic[@"cell_type"] integerValue];
        BOOL hasVideo = [dic[@"has_video"] boolValue];
        NSInteger videoStyle = [dic[@"video_style"] integerValue];
        Class cls = nil;
        if(type == FHUGCFeedListCellTypeUGC){
            cls = [FHFeedUGCContentModel class];
        }else if(type == FHUGCFeedListCellTypeArticle ||
                 type == FHUGCFeedListCellTypeQuestion ||
                 type == FHUGCFeedListCellTypeAnswer ||
                 type == FHUGCFeedListCellTypeArticleComment ||
                 type == FHUGCFeedListCellTypeUGCBanner ||
                 type == FHUGCFeedListCellTypeUGCRecommend ||
                 type == FHUGCFeedListCellTypeUGCBanner2 ||
                 type == FHUGCFeedListCellTypeArticleComment2 ||
                 type == FHUGCFeedListCellTypeUGCHotTopic ||
                 type == FHUGCFeedListCellTypeUGCVote ||
                 type == FHUGCFeedListCellTypeUGCSmallVideo ||
                 type == FHUGCFeedListCellTypeUGCVoteInfo){
            cls = [FHFeedContentModel class];
        }else{
            //其他类型直接过滤掉
            return cellModel;
        }
        
        __block NSError *backError = nil;
        
        id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:cls error:&backError];
        if(!backError){
            if([model isKindOfClass:[FHFeedContentModel class]]){
                FHFeedContentModel *fModel = (FHFeedContentModel *)model;
                cellModel = [self modelFromFeedContent:fModel];
            }else if([model isKindOfClass:[FHFeedUGCContentModel class]]){
                FHFeedUGCContentModel *fModel = (FHFeedUGCContentModel *)model;
                cellModel = [self modelFromFeedUGCContent:fModel];
            }
        }
        
        //视频类型，需要先转成 TTFeedItemContentStructModel
        if(type == FHUGCFeedListCellTypeArticle && hasVideo && videoStyle > 0){
            cls = [TTFeedItemContentStructModel class];
            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:cls error:&backError];
            if(!backError && [model isKindOfClass:[TTFeedItemContentStructModel class]]){
                TTFeedItemContentStructModel *fModel = (TTFeedItemContentStructModel *)model;
                TTVFeedItem *item = [TTVFeedItem FeedItemWithContentStruct:fModel];
                cellModel.videoFeedItem = item;
                cellModel.videoItem = [FHUGCCellHelper configureVideoItem:cellModel];
            }
        }
    }
    
    return cellModel;
}

+ (FHFeedUGCCellContentDecorationModel *)contentDecorationFromString:(NSString *)contentDecoration {
    
    if(contentDecoration.length == 0){
        return nil;
    }
    
    NSData *jsonData = [contentDecoration dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = nil;
    @try {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingMutableContainers
                                                error:&err];
    } @catch (NSException *exception) {} @finally {}
    
    if(!err){
        __block NSError *backError = nil;
        Class cls = [FHFeedUGCCellContentDecorationModel class];
        FHFeedUGCCellContentDecorationModel *model = [FHMainApi generateModel:jsonData class:cls error:&backError];
        if(!backError){
            return model;
        }
    }
    return nil;
}

+ (FHFeedUGCCellModel *)modelFromFeedContent:(FHFeedContentModel *)model {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.cellType = [model.cellType integerValue];
    cellModel.behotTime = model.behotTime;
    cellModel.groupId = model.groupId;
    cellModel.logPb = model.logPb;
    cellModel.aggrType = model.aggrType;
    cellModel.needLinkSpan = YES;
    cellModel.behotTime = model.behotTime;
    cellModel.isStick = (model.isStick || model.rawData.isStick);
    cellModel.stickStyle = ((model.stickStyle != FHFeedContentStickStyleUnknown) ? model.stickStyle : model.rawData.stickStyle);
    cellModel.contentDecoration = [self contentDecorationFromString:(model.contentDecoration.length > 0 ? model.contentDecoration : model.rawData.contentDecoration)];
    cellModel.originData = model;
    //目前仅支持话题类型
    cellModel.supportedLinkType = @[@(TTRichSpanLinkTypeHashtag),@(TTRichSpanLinkTypeAt), @(TTRichSpanLinkTypeLink)];
    //处理圈子信息
    FHFeedUGCCellCommunityModel *community = nil;
    if(model.community){
        community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.community.name;
        community.url = model.community.url;
        community.socialGroupId = model.community.socialGroupId;
        community.showStatus = model.community.showStatus;
    }else if(model.rawData.community){
        community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.rawData.community.name;
        community.url = model.rawData.community.url;
        community.socialGroupId = model.rawData.community.socialGroupId;
        community.showStatus = model.rawData.community.showStatus;
    }
    cellModel.community = community;
    
    if(cellModel.community && ![cellModel.community.showStatus isEqualToString:@"1"]){
        cellModel.showCommunity = YES;
    }else{
        cellModel.showCommunity = NO;
    }
    
    //处理其他数据
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle){
        if(model.hasVideo && [model.videoStyle integerValue] > 0){
            //视频
            cellModel.hasVideo = model.hasVideo;
            cellModel.content = model.title;
            cellModel.numberOfLines = 3;
            
            if (model.isFromDetail) {
                cellModel.numberOfLines = 0;
            }
            
            FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
            user.name = model.userInfo.name;
            user.avatarUrl = model.userInfo.avatarUrl;
            user.userId = model.userInfo.userId;
            user.schema = model.userInfo.schema;
            cellModel.user = user;
            
            [FHUGCCellHelper setRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40) numberOfLines:cellModel.numberOfLines];
            
            cellModel.desc = [self generateUGCDescWithCreateTime:model.publishTime readCount:model.readCount distanceInfo:nil];
            
            cellModel.userDigg = model.userDigg;
            cellModel.diggCount = model.diggCount;
            cellModel.commentCount = model.commentCount;
            
            if(model.openUrl){
                cellModel.openUrl = model.openUrl;
            }else if(model.articleSchema){
                cellModel.openUrl = model.articleSchema;
            }else if(model.rawData.articleSchema){
                cellModel.openUrl = model.rawData.articleSchema;
            }else{
                cellModel.openUrl = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&item_id=%@",model.groupId,model.itemId];
            }
            
            cellModel.videoDetailInfo = model.videoDetailInfo;

            NSString *dur = model.videoDuration;
            if (dur.length > 0) {
                double durTime = [dur doubleValue];
                cellModel.videoDuration = (NSInteger)durTime;
            } else {
                cellModel.videoDuration = 0;
            }
            
            cellModel.imageList = model.largeImageList;
            cellModel.largeImageList = nil;
            
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCVideo;
        }else{
            //文章
            cellModel.title = model.title;
            cellModel.openUrl = model.openUrl;
            cellModel.numberOfLines = 3;
            
            if (model.isFromDetail) {
                cellModel.numberOfLines = 0;
            }
            
            [FHUGCCellHelper setArticleRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40)];
            cellModel.desc = [self generateArticleDesc:model];
            if(model.openUrl){
                cellModel.openUrl = model.openUrl;
            }else if(model.articleSchema){
                cellModel.openUrl = model.articleSchema;
            }else if(model.rawData.articleSchema){
                cellModel.openUrl = model.rawData.articleSchema;
            }else{
                cellModel.openUrl = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&item_id=%@",model.groupId,model.itemId];
            }
            
            //处理图片
            cellModel.imageList = model.imageList;
            //处理大图
            cellModel.largeImageList = model.largeImageList;
            
            if(cellModel.imageList.count == 1){
                cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleSingleImage;
            }else if(cellModel.imageList.count > 1){
                cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleMultiImage;
            }else{
                cellModel.cellSubType = FHUGCFeedListCellSubTypeArticlePureTitle;
            }
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        // 发布用户的信息
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.rawData.content.user.uname;
        user.avatarUrl = model.rawData.content.user.avatarUrl;
        user.userId = model.rawData.content.user.userId;
        user.schema = model.rawData.content.user.userSchema;
        cellModel.user = user;
        
        cellModel.title = model.rawData.content.question.title;
        cellModel.openUrl = model.rawData.content.question.questionListSchema;
        cellModel.writeAnswerSchema = model.rawData.content.question.writeAnswerSchema;
        
        //  优先使用qid，使用groudId 兜底
        NSString *qid = model.rawData.content.question.qid;
        NSString *groupId = qid.length > 0 ? qid : model.rawData.groupId;
        cellModel.groupId = groupId;
        
        cellModel.numberOfLines = 3;
        
        cellModel.imageList = model.rawData.content.question.content.thumbImageList;
        //处理大图
        cellModel.largeImageList = model.rawData.content.question.content.largeImageList;
        
        if (model.isFromDetail) {
            cellModel.numberOfLines = 0;
        }
        
        [FHUGCCellHelper setArticleRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40)];
        
        if(model.sourceDesc){
            cellModel.desc = [[NSMutableAttributedString alloc] initWithString:model.sourceDesc];
        }else if(model.rawData.content.extra.answerCount){
            cellModel.desc = [[NSMutableAttributedString alloc] initWithString:model.rawData.content.extra.answerCount];
        }
        
        if(cellModel.imageList.count == 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleSingleImage;
        }else if(cellModel.imageList.count > 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleMultiImage;
        }else{
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticlePureTitle;
        }
        
        //小区问答数据处理
        if([model.cellCtrls.cellLayoutStyle isEqualToString:@"10001"]){
            cellModel.qid = groupId;
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion;
            cellModel.questionStr = model.rawData.content.question.title;
            cellModel.answerCountText = model.rawData.content.extra.answerCount;
            cellModel.answerCount = [model.rawData.content.question.niceAnsCount integerValue] + [model.rawData.content.question.normalAnsCount integerValue];
        }
        
        //小区问答数据处理
//        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion;
//        cellModel.questionStr = @"语雀是一款优雅高效的在线文档编辑";
//        cellModel.answerStr = @"AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代";
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeAnswer){
        cellModel.groupId = model.rawData.groupId;
        cellModel.content = model.rawData.content.answer.abstractText;
        cellModel.openUrl = model.rawData.content.answer.answerDetailSchema;
        cellModel.showLookMore = YES;
        cellModel.numberOfLines = 3;
        
        cellModel.imageList = model.rawData.content.answer.thumbImageList;
        //处理大图
        cellModel.largeImageList = model.rawData.content.answer.largeImageList;
        
        cellModel.desc = [self generateUGCDescWithCreateTime:model.rawData.content.answer.createTime readCount:nil distanceInfo:nil];
        
        cellModel.diggCount = model.rawData.content.answer.diggCount;
        cellModel.commentCount = model.rawData.content.answer.commentCount;
        cellModel.userDigg = model.rawData.content.answer.isDigg;
        
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.rawData.content.user.uname;
        user.avatarUrl = model.rawData.content.user.avatarUrl;
        user.userId = model.rawData.content.user.userId;
        user.schema = model.rawData.content.user.userSchema;
        cellModel.user = user;
        
        FHFeedUGCOriginItemModel *originItemModel = [[FHFeedUGCOriginItemModel alloc] init];
        originItemModel.type = @"[问答]";
        originItemModel.content = model.rawData.content.question.title;
        originItemModel.openUrl = model.rawData.content.question.questionListSchema;
        cellModel.originItemModel = originItemModel;
        
        if(cellModel.originItemModel.imageModel){
            cellModel.originItemHeight = 80;
        }else{
            [FHUGCCellHelper setOriginContentAttributeString:cellModel width:([UIScreen mainScreen].bounds.size.width - 60) numberOfLines:2];
        }
    
        if(cellModel.imageList.count == 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeSingleImage;
        }else if(cellModel.imageList.count > 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeMultiImage;
        }else{
            cellModel.cellSubType = FHUGCFeedListCellSubTypePureTitle;
            cellModel.numberOfLines = 3;
        }
        if (model.isFromDetail) {
            cellModel.numberOfLines = 0;
        }
        
        [FHUGCCellHelper setRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40) numberOfLines:cellModel.numberOfLines];
        
        //小区问答数据处理
        if([model.cellCtrls.cellLayoutStyle isEqualToString:@"10001"]){
            cellModel.qid = model.rawData.content.question.qid;
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion;
            cellModel.questionStr = model.rawData.content.question.title;
            cellModel.answerStr = model.rawData.content.answer.abstractText;
            cellModel.answerCountText = model.rawData.content.extra.answerCount;
            cellModel.answerCount = [model.rawData.content.question.niceAnsCount integerValue] + [model.rawData.content.question.normalAnsCount integerValue];
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeArticleComment || cellModel.cellType == FHUGCFeedListCellTypeArticleComment2){
        cellModel.groupId = model.rawData.commentBase.id;
        cellModel.content = model.rawData.commentBase.content;
        cellModel.contentRichSpan = model.rawData.commentBase.contentRichSpan;
        cellModel.openUrl = model.rawData.commentBase.detailSchema;
        cellModel.showLookMore = YES;
        cellModel.numberOfLines = 3;
        
        cellModel.imageList = model.rawData.commentBase.imageList;
        cellModel.largeImageList = model.rawData.commentBase.imageList;
        
        double time = [model.rawData.commentBase.createTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
        cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
        
        cellModel.desc = [self generateUGCDescWithCreateTime:model.rawData.commentBase.createTime readCount:model.rawData.commentBase.action.readCount distanceInfo:nil];
        
        cellModel.diggCount = model.rawData.commentBase.action.diggCount;
        cellModel.commentCount = model.rawData.commentBase.action.commentCount;
        cellModel.userDigg = model.rawData.commentBase.action.userDigg;
        
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.rawData.commentBase.user.info.name;
        user.avatarUrl = model.rawData.commentBase.user.info.avatarUrl;
        user.userId = model.rawData.commentBase.user.info.userId;
        user.schema = model.rawData.commentBase.user.info.schema;
        cellModel.user = user;
        
        FHFeedUGCOriginItemModel *originItemModel = [[FHFeedUGCOriginItemModel alloc] init];
        if(model.rawData.originType.length > 0){
            originItemModel.type = [NSString stringWithFormat:@"[%@]",model.rawData.originType];
        }else if(model.originType.length > 0){
            originItemModel.type = [NSString stringWithFormat:@"[%@]",model.originType];
        }else{
            
        }
        if(model.rawData.originGroup){
            originItemModel.content = model.rawData.originGroup.title;
            originItemModel.contentRichSpan = model.rawData.originGroup.titleRichSpan;
            originItemModel.openUrl = model.rawData.originGroup.schema;
            originItemModel.imageModel = model.rawData.originGroup.middleImage;
        }else if(model.rawData.originThread){
            originItemModel.content = model.rawData.originThread.content;
            originItemModel.contentRichSpan = model.rawData.originThread.contentRichSpan;
            originItemModel.openUrl = model.rawData.originThread.schema;
            originItemModel.imageModel = [model.rawData.originThread.thumbImageList firstObject];
        }else if(model.rawData.originUgcVideo){
            originItemModel.content = model.rawData.originUgcVideo.rawData.title;
            originItemModel.contentRichSpan = model.rawData.originUgcVideo.rawData.titleRichSpan;
            originItemModel.openUrl = model.rawData.originUgcVideo.rawData.detailSchema;
            originItemModel.imageModel = [model.rawData.originUgcVideo.rawData.thumbImageList firstObject];
        }else{
            originItemModel.content = model.rawData.originCommonContent.title;
            originItemModel.contentRichSpan = model.rawData.originCommonContent.titleRichSpan;
            originItemModel.openUrl = model.rawData.originCommonContent.schema;
            originItemModel.imageModel = model.rawData.originCommonContent.coverImage;
        }
        cellModel.originItemModel = originItemModel;
        
        [FHUGCCellHelper setOriginContentAttributeString:cellModel width:([UIScreen mainScreen].bounds.size.width - 60) numberOfLines:2];
        if(cellModel.originItemModel.imageModel){
            cellModel.originItemHeight = 80;
        }
        
        if(cellModel.imageList.count == 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeSingleImage;
        }else if(cellModel.imageList.count > 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeMultiImage;
        }else{
            cellModel.cellSubType = FHUGCFeedListCellSubTypePureTitle;
            cellModel.numberOfLines = 5;
        }
        if (model.isFromDetail) {
            cellModel.numberOfLines = 0;
        }
        [FHUGCCellHelper setRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40) numberOfLines:cellModel.numberOfLines];
        
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner || cellModel.cellType == FHUGCFeedListCellTypeUGCBanner2){
        cellModel.groupId = model.rawData.groupId;
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBanner;
        
        if(model.imageList){
            cellModel.imageList = model.imageList;
        }else{
            cellModel.imageList = model.rawData.operation.imageList;
        }
        
        if(model.url){
            cellModel.openUrl = model.url;
        }else{
            cellModel.openUrl = model.rawData.operation.url;
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCRecommend){
        cellModel.groupId = model.rawData.groupId;
        cellModel.hotCommunityCellType = model.rawData.subCellType;
        if([model.rawData.subCellType isEqualToString:@"hot_social"]){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCHotCommunity;
            cellModel.hotCellList = model.rawData.hotCellList;
        }else{
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCRecommend;
            cellModel.elementFrom = @"like_neighborhood";
            if(model.recommendSocialGroupList){
                cellModel.recommendSocialGroupList = model.recommendSocialGroupList;
            }else{
                cellModel.recommendSocialGroupList = model.rawData.recommendSocialGroupList;
            }
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCHotTopic){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCHotTopic;
        cellModel.groupId = model.rawData.groupId;
        cellModel.hotTopicList = model.rawData.hotTopicList;
        cellModel.elementFrom = @"hot_topic";
        if(cellModel.hotTopicList.count <= 0){
            return nil;
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVote){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCVote;
        cellModel.groupId = model.rawData.vote.voteId;
        
        FHFeedUGCVoteModel *vote = [[FHFeedUGCVoteModel alloc] init];
        vote.content = model.rawData.vote.title;
        vote.leftDesc = model.rawData.vote.leftName;
        vote.leftValue = model.rawData.vote.leftValue;
        vote.rightDesc = model.rawData.vote.rightName;
        vote.rightValue = model.rawData.vote.rightValue;
        vote.personDesc = model.rawData.vote.personDesc;
        vote.openUrl = model.rawData.vote.schema;
        vote.needUserLogin = model.rawData.vote.needUserLogin;
        cellModel.vote = vote;
        
        [FHUGCCellHelper setVoteContentString:cellModel width:([UIScreen mainScreen].bounds.size.width - 78) numberOfLines:2];
    } else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVoteInfo){
        // UGC 投票
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCVoteDetail;
        cellModel.groupId = model.rawData.voteInfo.voteId;
        
        cellModel.voteInfo = model.rawData.voteInfo;
        if (cellModel.voteInfo == nil || cellModel.voteInfo.items.count < 2) {
            return nil;
        }
        //保存一下title原本的内容，为了复制用
        cellModel.voteInfo.originTitle = cellModel.voteInfo.title;
        
        if ([cellModel.voteInfo.voteType isEqualToString:@"1"]) {
            // 单选
            cellModel.voteInfo.title = [NSString stringWithFormat:@"【单选】%@",cellModel.voteInfo.title];
        } else if ([cellModel.voteInfo.voteType isEqualToString:@"2"]) {
            // 多选
            cellModel.voteInfo.title = [NSString stringWithFormat:@"【多选】%@",cellModel.voteInfo.title];
        }
        cellModel.voteInfo.voteState = FHUGCVoteStateNone;
        cellModel.voteInfo.needFold = NO;
        cellModel.voteInfo.isFold = NO;
        cellModel.voteInfo.hasReloadForVoteExpired = NO;
        cellModel.voteInfo.needAnimateShow = NO;
        cellModel.openUrl = model.rawData.detailSchema;
        if (cellModel.voteInfo.selected) {
            cellModel.voteInfo.voteState = FHUGCVoteStateComplete;
        }
        NSInteger displayCount = [cellModel.voteInfo.displayCount integerValue];
        if (displayCount <= 0 || displayCount >= cellModel.voteInfo.items.count) {
            cellModel.voteInfo.needFold = NO;
        } else {
            cellModel.voteInfo.needFold = YES;
            cellModel.voteInfo.isFold = YES;// 默认折叠，后续点击按钮修改
        }
        
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.rawData.user.info.name;
        user.avatarUrl = model.rawData.user.info.avatarUrl;
        user.userId = model.rawData.user.info.userId;
        user.schema = model.rawData.user.info.schema;
        cellModel.user = user;
        
        // 时间以及距离
        cellModel.desc = [self generateUGCDescWithCreateTime:model.rawData.createTime readCount:model.rawData.readCount distanceInfo:model.rawData.distanceInfo];
        
        cellModel.diggCount = model.rawData.diggCount;
        cellModel.commentCount = model.rawData.commentCount;
        cellModel.userDigg = model.rawData.userDigg;
        
        [FHUGCCellHelper setUGCVoteContentString:cellModel width:([UIScreen mainScreen].bounds.size.width - 60) numberOfLines:2];
        cellModel.voteInfo.descHeight = 17;
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCSmallVideo;
        cellModel.groupId = model.rawData.groupId;
        cellModel.openUrl = model.rawData.detailSchema;
        cellModel.showLookMore = YES;
        cellModel.numberOfLines = 3;
        NSString *dur = model.rawData.video.duration;
        if (dur.length > 0) {
            double durTime = [dur doubleValue];
            cellModel.videoDuration = (NSInteger)durTime;
        } else {
            cellModel.videoDuration = 0;
        }
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.rawData.user.info.name;
        user.avatarUrl = model.rawData.user.info.avatarUrl;
        user.userId = model.rawData.user.info.userId;
        user.schema = model.rawData.user.info.schema;
        cellModel.user = user;
        
        cellModel.diggCount = model.rawData.action.diggCount;
        cellModel.commentCount = model.rawData.action.commentCount;
        cellModel.userDigg = model.rawData.action.userDigg;
        
        cellModel.content = model.rawData.title;
        cellModel.contentRichSpan = model.rawData.titleRichSpan;
        
        double time = [model.rawData.createTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
        cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
        
        cellModel.imageList = model.rawData.firstFrameImageList;
        cellModel.largeImageList = nil;
        
        [FHUGCCellHelper setRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40) numberOfLines:cellModel.numberOfLines];
    }
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFeedUGCContent:(FHFeedUGCContentModel *)model {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.originData = model;
    cellModel.cellType = [model.cellType integerValue];
    cellModel.title = model.title;
    cellModel.behotTime = model.behotTime;
    cellModel.isStick = model.isStick;
    cellModel.stickStyle = model.stickStyle;
    cellModel.contentDecoration = [self contentDecorationFromString:model.contentDecoration];
    cellModel.content = model.content;
    cellModel.contentRichSpan = model.contentRichSpan;
    cellModel.diggCount = model.diggCount;
    cellModel.readCount = model.readCount;
    cellModel.commentCount = model.commentCount;
    cellModel.userDigg = model.userDigg;
    cellModel.desc = [self generateUGCDesc:model];
    cellModel.groupId = model.threadId;
    cellModel.logPb = model.logPb;
    cellModel.showLookMore = YES;
    cellModel.needLinkSpan = YES;
    cellModel.numberOfLines = 3;
    cellModel.hasEdit = [model.hasEdit boolValue];
    cellModel.groupSource = model.groupSource;
    //目前仅支持话题类型
    cellModel.supportedLinkType = @[@(TTRichSpanLinkTypeHashtag),@(TTRichSpanLinkTypeAt), @(TTRichSpanLinkTypeLink)];
    
    FHFeedUGCCellCommunityModel *community = nil;
    if(model.community){
        community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.community.name;
        community.url = model.community.url;
        community.socialGroupId = model.community.socialGroupId;
        community.showStatus = model.community.showStatus;
    }
    cellModel.community = community;
    if(cellModel.community && ![cellModel.community.showStatus isEqualToString:@"1"]){
        cellModel.showCommunity = YES;
    }else{
        cellModel.showCommunity = NO;
    }
    
    FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
    user.name = model.user.name;
    user.avatarUrl = model.user.avatarUrl;
    user.userId = model.user.userId;
    user.schema = model.user.schema;
    cellModel.user = user;
    
    NSMutableArray *cellImageList = [NSMutableArray array];
    if(model.ugcU13CutImageList.count > 0){
        //单图
        [cellImageList addObject:[model.ugcU13CutImageList firstObject]];
    }else{
        if(model.thumbImageList.count > 0){
            //多图
            [cellImageList addObjectsFromArray:model.thumbImageList];
        }else{
            //纯文本
            cellModel.numberOfLines = 5;
        }
    }
    
    if (model.isFromDetail) {
        cellModel.numberOfLines = 0;
    }
    
    cellModel.imageList = cellImageList;
    cellModel.largeImageList = model.largeImageList;
    
    [FHUGCCellHelper setRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40) numberOfLines:cellModel.numberOfLines];
    
    if(cellModel.imageList.count == 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeSingleImage;
    }else if(cellModel.imageList.count > 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeMultiImage;
    }else{
        cellModel.cellSubType = FHUGCFeedListCellSubTypePureTitle;
    }
    
    return cellModel;
}

+ (NSAttributedString *)generateUGCDesc:(FHFeedUGCContentModel *)model {
    return [self generateUGCDescWithCreateTime:model.createTime readCount:model.readCount distanceInfo:model.distanceInfo];
}

+ (NSAttributedString *)generateUGCDescWithCreateTime:(NSString *)createTime readCount:(NSString *)readCount distanceInfo:(NSString *)distanceInfo {
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    double time = [createTime doubleValue];
    
    NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
    
    if(!isEmptyString(publishTime)){
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:publishTime];
        [desc appendAttributedString:publishTimeAStr];
    }
    
    if(!isEmptyString(readCount) && [readCount integerValue] != 0){
        NSString *read = [NSString stringWithFormat:@"浏览%@",[TTBusinessManager formatCommentCount:[readCount longLongValue]]];
        if(desc.length > 0){
            read = [NSString stringWithFormat:@" %@",read];
        }
        NSAttributedString *readAStr = [[NSAttributedString alloc] initWithString:read];
        [desc appendAttributedString:readAStr];
    }
    
    // 法务合规，如果没有定位权限，不展示位置信息
    if(!isEmptyString(distanceInfo) && [[FHLocManager sharedInstance] isHaveLocationAuthorization]) {
        NSString *distance = [NSString stringWithFormat:@"   %@",distanceInfo];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.bounds = CGRectMake(8, 0, 8, 8);
        attachment.image = [UIImage imageNamed:@"fh_ugc_location"];
        NSAttributedString *attachmentAStr = [NSAttributedString attributedStringWithAttachment:attachment];
        [desc appendAttributedString:attachmentAStr];
        
        NSAttributedString *distanceAStr = [[NSAttributedString alloc] initWithString:distance];
        [desc appendAttributedString:distanceAStr];
    }
    
    return desc;
}

+ (NSAttributedString *)generateArticleDesc:(FHFeedContentModel *)model {
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if(!isEmptyString(model.readCount) && [model.readCount integerValue] != 0){
        NSString *read = [NSString stringWithFormat:@"浏览%@",[TTBusinessManager formatCommentCount:[model.readCount longLongValue]]];
        NSAttributedString *readAStr = [[NSAttributedString alloc] initWithString:read];
        [desc appendAttributedString:readAStr];
    }
    
    if(!isEmptyString(model.commentCount)){
        NSString *comment = [NSString stringWithFormat:@"%@评论",[TTBusinessManager formatCommentCount:[model.commentCount longLongValue]]];
        if(desc.length > 0){
            comment = [NSString stringWithFormat:@" %@",comment];
        }
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:comment];
        [desc appendAttributedString:publishTimeAStr];
        
    }
    
    double time = [model.publishTime doubleValue];
    NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time type:@"onlyDate"];
    
    if(![publishTime isEqualToString:@""]){
        if(desc.length > 0){
            publishTime = [NSString stringWithFormat:@" %@",publishTime];
        }
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:publishTime];
        [desc appendAttributedString:publishTimeAStr];
    }
    
    return desc;
}

- (void)setIsInNeighbourhoodQAList:(BOOL)isInNeighbourhoodQAList {
    _isInNeighbourhoodQAList = isInNeighbourhoodQAList;
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 60;
    if(isInNeighbourhoodQAList){
        width = [UIScreen mainScreen].bounds.size.width - 90;
    }
    self.numberOfLines = isInNeighbourhoodQAList ? 3 : 1;
    [FHUGCCellHelper setQuestionRichContentWithModel:self width:width numberOfLines:0];
    [FHUGCCellHelper setAnswerRichContentWithModel:self width:width numberOfLines:self.numberOfLines];
}

- (void)setCategoryId:(NSString *)categoryId {
    _categoryId = categoryId;
    _videoItem.categoryId = categoryId;
}

- (void)setTracerDic:(NSDictionary *)tracerDic {
    _tracerDic = tracerDic;
    _videoItem.extraDic = [tracerDic copy];
}

+ (FHFeedUGCCellModel *)modelFromFake {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.groupId = @"1000051";
    cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion;
    cellModel.questionStr = @"语雀是一款优雅高效的在线文档编辑与协同工具， 让每个企业轻松拥有文档";
    cellModel.answerStr = @"AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代";
    [FHUGCCellHelper setQuestionRichContentWithModel:cellModel width:[UIScreen mainScreen].bounds.size.width - 100 numberOfLines:0];
    [FHUGCCellHelper setAnswerRichContentWithModel:cellModel width:[UIScreen mainScreen].bounds.size.width - 100 numberOfLines:1];
    
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFake2 {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.groupId = @"1000061";
    cellModel.cellType = FHUGCFeedListCellTypeUGCSmallVideo;
    cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCSmallVideo;
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFake3:(BOOL)isList {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.isInNeighbourhoodQAList = isList;
    cellModel.groupId = @"1000051";
    cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion;
    cellModel.questionStr = @"语雀是一款优雅高效的在线文档编辑";
    cellModel.answerStr = @"AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代AntV 是蚂蚁金服全新一代";
    [FHUGCCellHelper setQuestionRichContentWithModel:cellModel width:[UIScreen mainScreen].bounds.size.width - 100 numberOfLines:0];
    [FHUGCCellHelper setAnswerRichContentWithModel:cellModel width:[UIScreen mainScreen].bounds.size.width - 100 numberOfLines:(cellModel.isInNeighbourhoodQAList ? 3 : 1)];
    
    return cellModel;
}

@end

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
#import <TTVideoApiModel.h>
#import "TTVFeedItem+Extension.h"
#import "FHLocManager.h"

@implementation FHFeedUGCCellCommunityModel

@end

//@implementation FHFeedUGCCellImageListUrlListModel
//
//@end
//
//@implementation FHFeedUGCCellImageListModel
//
//@end
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
    }
    return self;
}

+ (FHFeedUGCCellModel *)modelFromFeed:(NSString *)content {
    FHFeedUGCCellModel *cellModel = nil;
    
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
    FHFeedUGCCellCommunityModel *community = [[FHFeedUGCCellCommunityModel alloc] init];
    if(model.community){
        community.name = model.community.name;
        community.url = model.community.url;
        community.socialGroupId = model.community.socialGroupId;
    }else if(model.rawData.community){
        community.name = model.rawData.community.name;
        community.url = model.rawData.community.url;
        community.socialGroupId = model.rawData.community.socialGroupId;
    }
    cellModel.community = community;
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
            
            double time = [model.publishTime doubleValue];
            NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
            cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
            
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
        cellModel.groupId = model.rawData.groupId;
        cellModel.title = model.rawData.content.question.title;
        cellModel.openUrl = model.rawData.content.question.questionListSchema;
        cellModel.groupId = model.rawData.content.question.qid;
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
        
        double time = [model.rawData.content.answer.createTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
        cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
        
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
        if(model.rawData.originType){
            originItemModel.type = [NSString stringWithFormat:@"[%@]",model.rawData.originType];
        }else if(model.originType){
            originItemModel.type = [NSString stringWithFormat:@"[%@]",model.originType];
        }else{
            if([model.rawData.commentBase.repostParams.repostType integerValue] == 223){
                originItemModel.type = @"[视频]";
            }else{
                originItemModel.type = @"[文章]";
            }
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
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCRecommend;
        cellModel.groupId = model.rawData.groupId;
        if(model.recommendSocialGroupList){
            cellModel.recommendSocialGroupList = model.recommendSocialGroupList;
        }else{
            cellModel.recommendSocialGroupList = model.rawData.recommendSocialGroupList;
        }
        cellModel.elementFrom = @"like_neighborhood";
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
        cellModel.voteInfo.voteState = FHUGCVoteStateNone;
        cellModel.voteInfo.needFold = NO;
        cellModel.voteInfo.isFold = NO;
        cellModel.voteInfo.hasReloadForVoteExpired = NO;
        cellModel.voteInfo.needAnimateShow = NO;
        cellModel.openUrl = model.rawData.detailSchema;
        if (cellModel.voteInfo.selected) {
            cellModel.voteInfo.voteState = FHUGCVoteStateComplete;
        }
        // add by zyk  判断过期状态
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
        // add by zyk 需要确认数据是否是从这个地方取
        double time = [model.rawData.createTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
        cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
        
        cellModel.diggCount = model.rawData.diggCount;
        cellModel.commentCount = model.rawData.commentCount;
        cellModel.userDigg = model.rawData.userDigg;
        
//        cellModel.content = model.rawData.voteInfo.title;
//        cellModel.contentRichSpan = model.rawData.voteInfo.richContent;
        
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
    cellModel.commentCount = model.commentCount;
    cellModel.userDigg = model.userDigg;
    cellModel.desc = [self generateUGCDesc:model];
    cellModel.groupId = model.threadId;
    cellModel.logPb = model.logPb;
    cellModel.showLookMore = YES;
    cellModel.needLinkSpan = YES;
    cellModel.numberOfLines = 3;
    //目前仅支持话题类型
    cellModel.supportedLinkType = @[@(TTRichSpanLinkTypeHashtag),@(TTRichSpanLinkTypeAt), @(TTRichSpanLinkTypeLink)];
    
    FHFeedUGCCellCommunityModel *community = [[FHFeedUGCCellCommunityModel alloc] init];
    community.name = model.community.name;
    community.url = model.community.url;
    community.socialGroupId = model.community.socialGroupId;
    cellModel.community = community;
    
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
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    double time = [model.createTime doubleValue];
    
    NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
    
    if(![publishTime isEqualToString:@""]){
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:publishTime];
        [desc appendAttributedString:publishTimeAStr];
    }
    
    // 法务合规，如果没有定位权限，不展示位置信息
    if(!isEmptyString(model.distanceInfo) && [[FHLocManager sharedInstance] isHaveLocationAuthorization]) {
        NSString *distance = [NSString stringWithFormat:@"   %@",model.distanceInfo];
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
    
    if(model.source && ![model.source isEqualToString:@""]){
        NSAttributedString *sourceAStr = [[NSAttributedString alloc] initWithString:model.source];
        [desc appendAttributedString:sourceAStr];
    }
    
    if(model.commentCount && ![model.commentCount isEqualToString:@""]){
        NSString *comment = [NSString stringWithFormat:@"%@评论",model.commentCount];
        if(desc.length > 0){
            comment = [NSString stringWithFormat:@" %@",comment];
        }
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:comment];
        [desc appendAttributedString:publishTimeAStr];
        
    }
    
    double time = [model.publishTime doubleValue];
    NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
    
    if(![publishTime isEqualToString:@""]){
        if(desc.length > 0){
            publishTime = [NSString stringWithFormat:@" %@",publishTime];
        }
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:publishTime];
        [desc appendAttributedString:publishTimeAStr];
    }
    
    return desc;
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
    cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCVideo;
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFake2 {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.groupId = @"1000061";
    cellModel.cellType = FHUGCFeedListCellTypeUGCSmallVideo;
    cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCSmallVideo;
    
    return cellModel;
}

@end

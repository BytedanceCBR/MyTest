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
#import "HMDTTMonitor.h"
#import "TTSandBoxHelper+House.h"
#import "FHHouseUGCHeader.h"
#import "FHUtils.h"
#import "UIFont+House.h"
#import <ByteDanceKit/ByteDanceKit.h>

#define kRecommendSocialGroupListNil @"kRecommendSocialGroupListNil"
#define kHotTopicListNil @"kHotTopicListNil"
#define kHotCommunityListNil @"kHotCommunityListNil"
#define kHotRecommendCircleListNil @"kHotRecommendCircleListNil"

@implementation FHFeedUGCCellCommunityModel

@end

@implementation FHFeedUGCVoteModel

@end

@implementation FHFeedUGCCellUserModel

@end

@implementation FHFeedUGCOriginItemModel

@end
@implementation FHFeedUGCCellRealtorModel

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
        _bottomLineHeight = 1.2;
        _bottomLineLeftMargin = 20;
        _bottomLineRightMargin = 20;
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
        NSAssert([NSJSONSerialization isValidJSONObject:dic], @"数据异常，一定要跟踪到");
        if (![NSJSONSerialization isValidJSONObject:dic]) {
            return nil;
        }
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
                 type == FHUGCFeedListCellTypeUGCSmallVideo2 ||
                 type == FHUGCFeedListCellTypeUGCSmallVideoList ||
                 type == FHUGCFeedListCellTypeUGCVoteInfo ||
                 type == FHUGCFeedListCellTypeUGCRecommendCircle ||
                 type == FHUGCFeedListCellTypeUGCEncyclopedias ){
            cls = [FHFeedContentModel class];
        }else if(type >= FHUGCFeedListCellTypeUGCCommonLynx && type < 1300){
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
        
        cellModel.originContent = content;
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
    //防止这个字段返回一个string导致crash
    id logPb = model.logPb;
    NSDictionary *logPbDic = nil;
    if([logPb isKindOfClass:[NSDictionary class]]){
        logPbDic = logPb;
    }else if([logPb isKindOfClass:[NSString class]]){
        logPbDic = [FHUtils dictionaryWithJsonString:logPb];
    }
    cellModel.logPb = logPbDic;
    
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
            
            if([model.cellCtrls.cellLayoutStyle isEqualToString:@"10001"]){
                cellModel.cellSubType = FHUGCFeedListCellSubTypeFullVideo;
                cellModel.numberOfLines = 2;
            }else{
                cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCVideo;
                cellModel.numberOfLines = 3;
            }
            
            if (model.isFromDetail) {
                cellModel.numberOfLines = 0;
            }
            
            FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
            user.name = model.userInfo.name;
            user.avatarUrl = model.userInfo.avatarUrl;
            user.userId = model.userInfo.userId;
            user.schema = model.userInfo.schema;
            user.fverifyShow = model.userInfo.fverifyShow;
            user.verifiedContent = model.userInfo.verifiedContent;
            cellModel.user = user;
            
            if([model.cellCtrls.cellLayoutStyle isEqualToString:@"10001"]){
                [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 30) numberOfLines:cellModel.numberOfLines font:[UIFont themeFontMedium:16]];
            }else{
                [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 40) numberOfLines:cellModel.numberOfLines font:[UIFont themeFontRegular:16]];
            }
            
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
        }else{
            //文章
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticle;
            cellModel.title = model.title;
            cellModel.openUrl = model.openUrl;
            cellModel.numberOfLines = 3;
            
            if (model.isFromDetail) {
                cellModel.numberOfLines = 0;
            }
            
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
            if(model.imageList){
                cellModel.imageList = model.imageList;
            }else if(model.middleImage){
                NSMutableArray *imageList = [NSMutableArray array];
                [imageList addObject:model.middleImage];
                cellModel.imageList = imageList;
            }
            //处理大图
            cellModel.largeImageList = model.largeImageList;
            
            if(cellModel.imageList.count == 1){
                [FHUGCCellHelper setArticleRichContentWithModel:cellModel width:(screenWidth - 40 - 120 - 15)];
            }else{
                [FHUGCCellHelper setArticleRichContentWithModel:cellModel width:(screenWidth - 40)];
            }
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeQuestion;
        // 发布用户的信息
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.rawData.content.user.uname;
        user.avatarUrl = model.rawData.content.user.avatarUrl;
        user.userId = model.rawData.content.user.userId;
        user.schema = model.rawData.content.user.userSchema;
        user.fverifyShow = model.rawData.content.user.fverifyShow;
        user.verifiedContent = model.rawData.content.user.verifiedContent;
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
        
        FHFeedUGCOriginItemModel *originItemModel = [[FHFeedUGCOriginItemModel alloc] init];
        if (cellModel.title) {
            originItemModel.content = cellModel.title;
            cellModel.originItemModel = originItemModel;
        }
        
        if(model.sourceDesc){
            cellModel.desc = [[NSMutableAttributedString alloc] initWithString:model.sourceDesc];
        }else if(model.rawData.content.extra.answerCount){
            cellModel.desc = [[NSMutableAttributedString alloc] initWithString:model.rawData.content.extra.answerCount];
        }
        
        if(cellModel.imageList.count == 1){
            [FHUGCCellHelper setArticleRichContentWithModel:cellModel width:(screenWidth - 40 - 120 - 15)];
        }else{
            [FHUGCCellHelper setArticleRichContentWithModel:cellModel width:(screenWidth - 40)];
        }
        
        //小区问答数据处理
        if([model.cellCtrls.cellLayoutStyle isEqualToString:@"10001"]){
            cellModel.qid = groupId;
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion;
            cellModel.questionStr = model.rawData.content.question.title;
            cellModel.answerCountText = model.rawData.content.extra.answerCount;
            cellModel.answerCount = [model.rawData.content.question.niceAnsCount integerValue] + [model.rawData.content.question.normalAnsCount integerValue];
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeAnswer){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeAnswer;
        cellModel.groupId = model.rawData.groupId;
        cellModel.content = model.rawData.content.answer.abstractText;
        cellModel.openUrl = model.rawData.content.answer.answerDetailSchema;
        cellModel.commentSchema = model.rawData.content.commentSchema;
        cellModel.fromGid = model.rawData.fromGid;
        cellModel.fromGroupSource = model.rawData.fromGroupSource;
        
        cellModel.imageList = model.rawData.content.answer.thumbImageList;
        //处理大图
        cellModel.largeImageList = model.rawData.content.answer.largeImageList;
        
        if (cellModel.imageList.count == 0) {
            cellModel.numberOfLines = 5;
        }else {
             cellModel.numberOfLines = 3;
        }
        cellModel.desc = [self generateUGCDescWithCreateTime:model.rawData.content.answer.createTime readCount:nil distanceInfo:nil];
        
        cellModel.diggCount = model.rawData.content.answer.diggCount;
        cellModel.commentCount = model.rawData.content.answer.commentCount;
        cellModel.userDigg = model.rawData.content.answer.isDigg;
        
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.rawData.content.user.uname;
        user.avatarUrl = model.rawData.content.user.avatarUrl;
        user.fverifyShow = model.rawData.content.user.fverifyShow;
        user.userId = model.rawData.content.user.userId;
        user.schema = model.rawData.content.user.userSchema;
        user.verifiedContent = model.rawData.content.user.vIcon;
        
        cellModel.user = user;
        
        FHFeedUGCOriginItemModel *originItemModel = [[FHFeedUGCOriginItemModel alloc] init];
        originItemModel.type = @"[问答]";
        originItemModel.content = model.rawData.content.question.title;
        originItemModel.openUrl = model.rawData.content.question.questionListSchema;
        cellModel.originItemModel = originItemModel;
        
        if(cellModel.originItemModel.imageModel){
            cellModel.originItemHeight = 80;
        }else{
            [FHUGCCellHelper setOriginContentAttributeString:cellModel width:(screenWidth - 60) numberOfLines:2];
        }
        
        if (model.isFromDetail) {
            cellModel.numberOfLines = 0;
        }
        [FHUGCCellHelper setRichContentImageWithModel:cellModel width:(screenWidth - 40) numberOfLines:cellModel.numberOfLines];
        
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
        cellModel.cellSubType = FHUGCFeedListCellSubTypePost;
        cellModel.groupId = model.rawData.commentBase.id;
        cellModel.content = model.rawData.commentBase.content;
        cellModel.contentRichSpan = model.rawData.commentBase.contentRichSpan;
        cellModel.openUrl = model.rawData.commentBase.detailSchema;
        cellModel.numberOfLines = 3;
        cellModel.fromGid = model.rawData.fromGid;
        cellModel.fromGroupSource = model.rawData.fromGroupSource;
        
        cellModel.imageList = model.rawData.commentBase.imageList;
        cellModel.largeImageList = model.rawData.commentBase.imageList;
        
        double time = [model.rawData.commentBase.createTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time type:@"onlyDate"];
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
        user.fverifyShow = model.rawData.content.user.fverifyShow;
        user.verifiedContent = model.rawData.content.user.verifiedContent;
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
        
        [FHUGCCellHelper setOriginContentAttributeString:cellModel width:(screenWidth - 60) numberOfLines:2];
        if(cellModel.originItemModel.imageModel){
            cellModel.originItemHeight = 80;
        }
        
        if(cellModel.imageList.count <= 0){
            cellModel.numberOfLines = 5;
        }
        
        if (model.isFromDetail) {
            cellModel.numberOfLines = 0;
        }
        
        [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 40) numberOfLines:cellModel.numberOfLines];
        
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner || cellModel.cellType == FHUGCFeedListCellTypeUGCBanner2){
        cellModel.groupId = model.rawData.groupId;
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBanner;
        cellModel.hidelLine = model.rawData.hidelLine;
        cellModel.upSpace = model.rawData.upSpace;
        cellModel.downSpace = model.rawData.downSpace;
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
    }else if(cellModel.cellType >= FHUGCFeedListCellTypeUGCCommonLynx && cellModel.cellType < 1300){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCLynx;
        if(model.rawData.groupId){
            cellModel.groupId = model.rawData.groupId;
        }
        
        if (!cellModel.groupId) {
            cellModel.groupId = [model.rawData.lynxData[@"group_id"] description];
        }
        cellModel.lynxData = model.rawData.lynxData;
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCRecommend){
        cellModel.groupId = model.rawData.groupId;
        cellModel.hotCommunityCellType = model.rawData.subCellType;
        if([model.rawData.subCellType isEqualToString:@"hot_social"]){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCHotCommunity;
            cellModel.hotCellList = model.rawData.hotCellList;
            if(cellModel.hotCellList.count <= 0){
                [[HMDTTMonitor defaultManager] hmdTrackService:kHotCommunityListNil metric:nil category:@{
                    @"version_code": [TTSandBoxHelper fhVersionCode],
                    @"isEmpty":@(1)
                } extra:@{
                    
                }];
                return nil;
            }
        }else{
            cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCRecommend;
            cellModel.elementFrom = @"like_neighborhood";
            if(model.recommendSocialGroupList){
                cellModel.recommendSocialGroupList = model.recommendSocialGroupList;
            }else{
                cellModel.recommendSocialGroupList = model.rawData.recommendSocialGroupList;
            }
            if(cellModel.recommendSocialGroupList.count <= 0){
                [[HMDTTMonitor defaultManager] hmdTrackService:kRecommendSocialGroupListNil metric:nil category:@{
                    @"version_code": [TTSandBoxHelper fhVersionCode],
                    @"isEmpty":@(1)
                } extra:@{
                    
                }];
                return nil;
            }
        }
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCHotTopic){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCHotTopic;
        cellModel.groupId = model.rawData.groupId;
        cellModel.hotTopicList = model.rawData.hotTopicList;
        cellModel.elementFrom = @"hot_topic";
        if(cellModel.hotTopicList.count <= 0){
            [[HMDTTMonitor defaultManager] hmdTrackService:kHotTopicListNil metric:nil category:@{
                @"version_code": [TTSandBoxHelper fhVersionCode],
                @"isEmpty":@(1)
            } extra:@{
                
            }];
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
        
        [FHUGCCellHelper setVoteContentString:cellModel width:(screenWidth - 78) numberOfLines:2];
    } else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVoteInfo){
        // UGC 投票
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCVoteDetail;
        cellModel.groupId = model.rawData.voteInfo.voteId;
        
        cellModel.voteInfo = model.rawData.voteInfo;
        if (cellModel.voteInfo == nil || cellModel.voteInfo.items.count < 2) {
            return nil;
        }
        
        if ([cellModel.voteInfo.voteType isEqualToString:@"1"] && ![cellModel.voteInfo.title hasPrefix:@"【单选】"]) {
            // 单选
            //保存一下title原本的内容，为了复制用
            cellModel.voteInfo.originTitle = cellModel.voteInfo.title;
            cellModel.voteInfo.title = [NSString stringWithFormat:@"【单选】%@",cellModel.voteInfo.title];
        } else if ([cellModel.voteInfo.voteType isEqualToString:@"2"] && ![cellModel.voteInfo.title hasPrefix:@"【多选】"]) {
            // 多选
            //保存一下title原本的内容，为了复制用
            cellModel.voteInfo.originTitle = cellModel.voteInfo.title;
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
        user.fverifyShow = model.rawData.content.user.fverifyShow;
        user.verifiedContent = model.rawData.content.user.verifiedContent;
        cellModel.user = user;
        
        // 时间以及距离
        cellModel.desc = [self generateUGCDescWithCreateTime:model.rawData.createTime readCount:model.rawData.readCount distanceInfo:model.rawData.distanceInfo];
        
        cellModel.diggCount = model.rawData.diggCount;
        cellModel.commentCount = model.rawData.commentCount;
        cellModel.userDigg = model.rawData.userDigg;
        
        [FHUGCCellHelper setUGCVoteContentString:cellModel width:(screenWidth - 60) numberOfLines:2];
        cellModel.voteInfo.descHeight = 17;
    }
    else if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo || cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo2){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCSmallVideo;
        cellModel.groupId = model.rawData.groupId;
        cellModel.openUrl = model.rawData.detailSchema;
        cellModel.video = model.rawData.video;
        cellModel.itemId  = model.rawData.itemId;
        cellModel.share = [model.rawData.share copy];
        cellModel.videoSourceIcon = model.rawData.videoSourceIcon;
        cellModel.userRepin = model.rawData.userRepin;
        cellModel.videoAction = [model.rawData.action copy];
        cellModel.numberOfLines = 3;
        cellModel.createTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:model.rawData.createTime.doubleValue type:@"onlyDate"];
        NSString *dur = model.rawData.video.duration;
        if (dur.length > 0) {
            double durTime = [dur doubleValue];
            cellModel.videoDuration = (NSInteger)durTime;
        } else {
            cellModel.videoDuration = 0;
        }
        
        
        FHFeedUGCCellRealtorModel *realtor = [[FHFeedUGCCellRealtorModel alloc] init];
        realtor.agencyName = model.rawData.realtor.agencyName;
        realtor.avatarUrl  = model.rawData.realtor.avatarUrl;
        realtor.avatarTagUrl = model.rawData.realtor.imageTag.imageUrl;
        realtor.certificationIcon  = model.rawData.realtor.certificationIcon;
        realtor.certificationPage  = model.rawData.realtor.certificationPage;
        realtor.chatOpenurl  = model.rawData.realtor.chatOpenurl;
        realtor.desc  = model.rawData.realtor.desc;
        realtor.realtorId  = model.rawData.realtor.realtorId;
        realtor.realtorName  = model.rawData.realtor.realtorName;
        realtor.associateInfo = model.rawData.realtor.associateInfo;
        realtor.realtorLogpb = model.rawData.realtor.realtorLogpb;
        realtor.firstBizType = model.rawData.realtor.firstBizType;
        cellModel.realtor = realtor;
        
        
        
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];

        if (realtor.realtorId.length>0) {
                    user.name = realtor.realtorName;
            user.avatarUrl = realtor.avatarUrl;
            user.realtorId = realtor.realtorId;
            user.firstBizType = realtor.firstBizType;
        }else {
            user.name = model.rawData.user.info.name;
            user.avatarUrl = model.rawData.user.info.avatarUrl;
        }
        user.relation = [model.rawData.user.relation copy];
        user.relationCount = [model.rawData.user.relationCount copy];
        user.userId = model.rawData.user.info.userId;
        user.schema = model.rawData.user.info.schema;
        user.fverifyShow = model.rawData.content.user.fverifyShow;
        user.verifiedContent = model.rawData.content.user.verifiedContent;
        cellModel.user = user;
        
        cellModel.diggCount = model.rawData.action.diggCount;
        cellModel.commentCount = model.rawData.action.commentCount;
        cellModel.userDigg = model.rawData.action.userDigg;
        
        cellModel.content = model.rawData.title;
        cellModel.contentRichSpan = model.rawData.titleRichSpan;
        
        double time = [model.rawData.createTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time type:@"onlyDate"];
        cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
        cellModel.animatedImageList = model.rawData.animatedImageList;
        cellModel.imageList = model.rawData.firstFrameImageList;
        cellModel.largeImageList = model.rawData.detailCoverImageModel;
        if([model.cellCtrls.cellLayoutStyle isEqualToString:@"10001"]){
            [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 60) numberOfLines:3 font:[UIFont themeFontRegular:14]];
        }else {
            [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 40) numberOfLines:cellModel.numberOfLines];
        }
    } else if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideoList){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeSmallVideoList;
        double currentTime =  [[NSDate date] timeIntervalSince1970]*1000;
        NSString *strTime = [NSString stringWithFormat:@"%.0f",currentTime];
        cellModel.groupId = [model.rawData.groupId stringByAppendingString:strTime];
        cellModel.originGroupId = model.rawData.groupId;
        if (model.subRawDatas.count > 0) {
            NSMutableArray *videoModelArr = [[NSMutableArray alloc]init];
            for (id content in model.subRawDatas) {
                FHFeedUGCCellModel *cellmodel = [FHFeedUGCCellModel modelFromFeed:content];
                [videoModelArr addObject:cellmodel];
            }
            cellModel.videoList = [videoModelArr copy];
        }else {
            return nil;
        }
        if (model.rawData.showMore && [model.rawData.showMore objectForKey:@"url"]) {
            cellModel.openUrl = [model.rawData.showMore objectForKey:@"url"];
        }
    } else if (cellModel.cellType == FHUGCFeedListCellTypeUGCRecommendCircle) {
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCRecommendCircle;
        cellModel.hotSocialList = model.rawData.hotSocialList;
        cellModel.groupId = model.rawData.groupId;
        cellModel.upSpace = model.rawData.upSpace;
        cellModel.downSpace = model.rawData.downSpace;
        cellModel.hidelLine = model.rawData.hidelLine;
        if(cellModel.hotSocialList.count <= 0){
            [[HMDTTMonitor defaultManager] hmdTrackService:kHotRecommendCircleListNil metric:nil category:@{
                @"version_code": [TTSandBoxHelper fhVersionCode],
                @"isEmptOjumpy":@(1)
            } extra:@{
                
            }];
            return nil;
        }
    } else if (cellModel.cellType == FHUGCFeedListCellTypeUGCEncyclopedias) {
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCEncyclopedias;
        cellModel.groupId = model.rawData.groupId;
        cellModel.desc = [[NSAttributedString alloc] initWithString:model.rawData.title];
        cellModel.openUrl = model.rawData.schema;
        cellModel.logPb = model.logPb;
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.fverifyShow = model.rawData.content.user.fverifyShow;;
        user.verifiedContent = model.rawData.content.user.verifiedContent;
        user.name = model.rawData.userName;
        user.avatarUrl = model.rawData.icon;
        cellModel.user = user;
        cellModel.content = model.rawData.articleTitle;
        cellModel.logPb = model.logPb;
        cellModel.allSchema = model.rawData.allSchema;
        cellModel.numberOfLines = 3;
        cellModel.avatar = model.rawData.avatar;
        if(isEmptyString(cellModel.avatar)){
            [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 40) numberOfLines:cellModel.numberOfLines];
        }else{
            [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 40 - 120 - 15) numberOfLines:cellModel.numberOfLines];
        }
    }
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFeedUGCContent:(FHFeedUGCContentModel *)model {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.originData = model;
    cellModel.cellType = [model.cellType integerValue];
    cellModel.cellSubType = FHUGCFeedListCellSubTypePost;
    cellModel.title = model.title;
    cellModel.behotTime = model.behotTime;
    
    if(model.attachCardInfo && model.attachCardInfo.title.length > 0){
        cellModel.attachCardInfo = model.attachCardInfo;
        //这里转一下图片的模型
        FHFeedContentImageListModel *imageModel = [[FHFeedContentImageListModel alloc] init];
        imageModel.url = cellModel.attachCardInfo.coverImage.url;
        imageModel.uri = cellModel.attachCardInfo.coverImage.uri;
        
        NSMutableArray *urlList = [NSMutableArray array];
        for (NSInteger i = 0; i < 3; i++) {
            FHFeedContentImageListUrlListModel *urlListModel = [[FHFeedContentImageListUrlListModel alloc] init];
            urlListModel.url = cellModel.attachCardInfo.coverImage.url;
            [urlList addObject:urlListModel];
        }
        imageModel.urlList = [urlList copy];
        cellModel.attachCardInfo.imageModel = imageModel;
    }
    
    cellModel.isStick = (model.isStick || model.rawData.isStick);
    cellModel.stickStyle = ((model.stickStyle != FHFeedContentStickStyleUnknown) ? model.stickStyle : model.rawData.stickStyle);
    cellModel.contentDecoration = [self contentDecorationFromString:(model.contentDecoration.length > 0 ? model.contentDecoration : model.rawData.contentDecoration)];
    cellModel.content = model.content.length > 0 ? model.content : model.rawData.content;
    cellModel.contentRichSpan = model.contentRichSpan.length > 0 ? model.contentRichSpan : model.rawData.contentRichSpan;
    
    cellModel.diggCount =model.diggCount.length>0 ?model.diggCount:model.rawData.diggCount;
    cellModel.readCount = model.readCount.length>0 ?model.readCount:model.rawData.readCount;
    cellModel.commentCount = model.commentCount.length>0 ?model.commentCount:model.rawData.commentCount;
    if (model.createTime) {
            cellModel.createTime =  [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:model.createTime.doubleValue type:@"onlyDate"];
    }else {
            cellModel.createTime =  [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:model.rawData.createTime.doubleValue type:@"onlyDate"];
    }

    cellModel.userDigg = model.userDigg;
    cellModel.desc = [self generateUGCDesc:model];
    cellModel.groupId = model.threadId.length > 0 ? model.threadId: model.rawData.threadId;
    
    //防止这个字段返回一个string导致crash
    id logPb = model.logPb;
    NSDictionary *logPbDic = nil;
    if([logPb isKindOfClass:[NSDictionary class]]){
        logPbDic = logPb;
    }else if([logPb isKindOfClass:[NSString class]]){
        logPbDic = [FHUtils dictionaryWithJsonString:logPb];
    }
    cellModel.logPb = logPbDic;
    
    cellModel.needLinkSpan = YES;
    cellModel.numberOfLines = 3;
    cellModel.hasEdit = [model.hasEdit boolValue];
    cellModel.groupSource = model.groupSource;
    cellModel.detailScheme = model.schema.length > 0 ? model.schema : model.rawData.schema;
    
    //目前仅支持话题类型
    cellModel.supportedLinkType = @[@(TTRichSpanLinkTypeHashtag),@(TTRichSpanLinkTypeAt), @(TTRichSpanLinkTypeLink)];
    
    FHFeedUGCCellCommunityModel *community = nil;
    if(model.community){
        community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.community.name;
        community.url = model.community.url;
        community.socialGroupId = model.community.socialGroupId;
        community.showStatus = model.community.showStatus;
    } else if(model.rawData.community) {
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
    
    FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
    if(model.user) {
        user.name = model.user.name;
        user.avatarUrl = model.user.avatarUrl;
        user.userId = model.user.userId;
        user.schema = model.user.schema;
        user.userAuthInfo = model.user.userAuthInfo;
        user.userBackgroundColor = model.user.userBackgroundColor;
        user.userBorderColor = model.user.userBorderColor;
        user.userFontColor = model.user.userFontColor;
        user.fverifyShow = model.user.fverifyShow;
        user.verifiedContent = model.user.verifiedContent;
    } else if(model.rawData.user) {
        user.name = model.rawData.user.name;
        user.avatarUrl = model.rawData.user.avatarUrl;
        user.userId = model.rawData.user.userId;
        user.schema = model.rawData.user.schema;
        user.userAuthInfo = model.rawData.user.userAuthInfo;
        user.userBackgroundColor = model.rawData.user.userBackgroundColor;
        user.userBorderColor = model.rawData.user.userBorderColor;
        user.userFontColor = model.rawData.user.userFontColor;
        user.fverifyShow = model.rawData.user.fverifyShow;
        user.verifiedContent = model.rawData.user.verifiedContent;
    }

    
    FHFeedUGCCellRealtorModel *realtor = [[FHFeedUGCCellRealtorModel alloc] init];
    if(model.realtor) {
        realtor.agencyName = model.realtor.agencyName;
        realtor.avatarUrl  = model.realtor.avatarUrl;
        realtor.avatarTagUrl = model.realtor.imageTag.imageUrl;
        realtor.certificationIcon  = model.realtor.certificationIcon;
        realtor.certificationPage  = model.realtor.certificationPage;
        realtor.chatOpenurl  = model.realtor.chatOpenurl;
        realtor.desc  = model.realtor.desc;
        realtor.realtorId  = model.realtor.realtorId;
        realtor.realtorName  = model.realtor.realtorName;
        realtor.associateInfo  = model.realtor.associateInfo;
        realtor.realtorLogpb = model.realtor.realtorLogpb;
         realtor.firstBizType = model.realtor.firstBizType;
        cellModel.realtor = realtor;
    } else if(model.rawData.realtor) {
        realtor.agencyName = model.rawData.realtor.agencyName;
        realtor.avatarUrl  = model.rawData.realtor.avatarUrl;
        realtor.avatarTagUrl = model.rawData.realtor.imageTag.imageUrl;
        realtor.certificationIcon  = model.rawData.realtor.certificationIcon;
        realtor.certificationPage  = model.rawData.realtor.certificationPage;
        realtor.chatOpenurl  = model.rawData.realtor.chatOpenurl;
        realtor.desc  = model.rawData.realtor.desc;
        realtor.realtorId  = model.rawData.realtor.realtorId;
        realtor.realtorName  = model.rawData.realtor.realtorName;
        realtor.associateInfo  = model.rawData.realtor.associateInfo;
        realtor.realtorLogpb = model.rawData.realtor.realtorLogpb;
        realtor.firstBizType = model.rawData.realtor.firstBizType;
        cellModel.realtor = realtor;
    }
    
    
    if (realtor.realtorId.length>0) {
        user.name = realtor.realtorName;
        user.avatarUrl = realtor.avatarUrl;
        user.realtorId = realtor.realtorId;
        user.firstBizType =realtor.firstBizType;
        user.desc = realtor.desc;
    }
    cellModel.user = user;
    
    NSMutableArray *cellImageList = [NSMutableArray array];
    
    //单图
    if(model.ugcU13CutImageList.count > 0) {
        [cellImageList addObject:[model.ugcU13CutImageList firstObject]];
    }
    //单图
    else if(model.rawData.ugcU13CutImageList.count > 0) {
        [cellImageList addObject:[model.rawData.ugcU13CutImageList firstObject]];
    }
    else{
        //多图
        if(model.thumbImageList.count > 0){
            [cellImageList addObjectsFromArray:model.thumbImageList];
        }
        //多图
        else if(model.rawData.thumbImageList.count > 0) {
            [cellImageList addObjectsFromArray:model.rawData.thumbImageList];
        }
        else{
            //纯文本
            cellModel.numberOfLines = 5;
        }
    }
    
    if (model.isFromDetail) {
        cellModel.numberOfLines = 0;
    }
    
    cellModel.imageList = cellImageList;
    if(model.largeImageList.count > 0) {
        cellModel.largeImageList = model.largeImageList;
    } else if(model.rawData.largeImageList.count > 0) {
        cellModel.largeImageList = model.rawData.largeImageList;
    }
    if([model.cellCtrls.cellLayoutStyle isEqualToString:@"10001"]){
        [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 42) numberOfLines:cellModel.numberOfLines font:[UIFont themeFontRegular:14]];
    }else {
        [FHUGCCellHelper setRichContentWithModel:cellModel width:(screenWidth - 40) numberOfLines:cellModel.numberOfLines];
    }

    
    return cellModel;
}

+ (NSAttributedString *)generateUGCDesc:(FHFeedUGCContentModel *)model {
    NSString *createTime = model.createTime.length > 0 ? model.createTime : model.rawData.createTime;
    NSString *readCount = model.readCount.length > 0 ? model.readCount : model.rawData.readCount;
    NSString *distanceInfo = model.distanceInfo.length > 0 ? model.distanceInfo : model.rawData.distanceInfo;
    NSString *realtorDesc = model.realtor.desc.length>0?model.realtor.desc:model.rawData.realtor.desc;
    return [self generateUGCDescWithCreateTime:createTime readCount:readCount distanceInfo:distanceInfo realtorDesc:realtorDesc];
}

+ (NSAttributedString *)generateUGCDescWithCreateTime:(NSString *)createTime readCount:(NSString *)readCount distanceInfo:(NSString *)distanceInfo {
    return [self generateUGCDescWithCreateTime:createTime readCount:readCount distanceInfo:distanceInfo realtorDesc:nil];
}

+ (NSAttributedString *)generateUGCDescWithCreateTime:(NSString *)createTime readCount:(NSString *)readCount distanceInfo:(NSString *)distanceInfo realtorDesc:(NSString *)realtorDesc {
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    double time = [createTime doubleValue];
    
    
    if (!isEmptyString(realtorDesc)) {
        NSAttributedString *descStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",realtorDesc]];
        [desc appendAttributedString:descStr];
    };
    
    NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time type:@"onlyDate"];
    
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
    
//    if(!isEmptyString(model.readCount) && [model.readCount integerValue] != 0){
//        NSString *read = [NSString stringWithFormat:@"浏览%@",[TTBusinessManager formatCommentCount:[model.readCount longLongValue]]];
//        NSAttributedString *readAStr = [[NSAttributedString alloc] initWithString:read];
//        [desc appendAttributedString:readAStr];
//    }
    if(!isEmptyString(model.userInfo.name) ){
//        NSString *read = [NSString stringWithFormat:@"浏览%@",[TTBusinessManager formatCommentCount:[model.readCount longLongValue]]];
        NSAttributedString *readAStr = [[NSAttributedString alloc] initWithString:model.userInfo.name];
        [desc appendAttributedString:readAStr];
    }
    
    
    if(!isEmptyString(model.commentCount)){
        NSString *comment = [NSString stringWithFormat:@"%@评论",[TTBusinessManager formatCommentCount:[model.commentCount longLongValue]]];
        if(desc.length > 0){
            comment = [NSString stringWithFormat:@"   %@",comment];
        }
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:comment];
        [desc appendAttributedString:publishTimeAStr];
        
    }
    
    double time = [model.publishTime doubleValue];
    NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time type:@"onlyDate"];
    
    if(![publishTime isEqualToString:@""]){
        if(desc.length > 0){
            publishTime = [NSString stringWithFormat:@"   %@",publishTime];
        }
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:publishTime];
        [desc appendAttributedString:publishTimeAStr];
    }
    
    return desc;
}

- (void)setIsInNeighbourhoodQAList:(BOOL)isInNeighbourhoodQAList {
    _isInNeighbourhoodQAList = isInNeighbourhoodQAList;
    CGFloat width = screenWidth - 60;
    if(isInNeighbourhoodQAList){
        width = screenWidth - 90;
    }
    self.numberOfLines = isInNeighbourhoodQAList ? 3 : 1;
    [FHUGCCellHelper setQuestionRichContentWithModel:self width:width numberOfLines:0];
    [FHUGCCellHelper setAnswerRichContentWithModel:self width:width numberOfLines:self.numberOfLines];
}

- (void)setIsInNeighbourhoodCommentsList:(BOOL)isInNeighbourhoodCommentsList {
    _isInNeighbourhoodCommentsList = isInNeighbourhoodCommentsList;
    CGFloat width = screenWidth - 32;
    if(isInNeighbourhoodCommentsList){
        width = screenWidth - 70;
    }
    if(self.isNewNeighbourhoodDetail){
        width = screenWidth - 62;
        self.numberOfLines = 2;
    }else{
        self.numberOfLines = self.imageList.count > 0 ? 3 : 5;
    }
    [FHUGCCellHelper setRichContentWithModel:self width:width numberOfLines:self.numberOfLines font:[UIFont themeFontRegular:14]];
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
    [FHUGCCellHelper setQuestionRichContentWithModel:cellModel width:(screenWidth - 100) numberOfLines:0];
    [FHUGCCellHelper setAnswerRichContentWithModel:cellModel width:(screenWidth - 100) numberOfLines:1];
    
    
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
    [FHUGCCellHelper setQuestionRichContentWithModel:cellModel width:(screenWidth - 100) numberOfLines:0];
    [FHUGCCellHelper setAnswerRichContentWithModel:cellModel width:(screenWidth - 100) numberOfLines:(cellModel.isInNeighbourhoodQAList ? 3 : 1)];
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)copyFromModel:(FHFeedUGCCellModel *)oldCellModel {
    FHFeedUGCCellModel *cellmodel = [FHFeedUGCCellModel modelFromFeed:oldCellModel.originContent];
    cellmodel.userDigg = oldCellModel.userDigg;
    cellmodel.diggCount = oldCellModel.diggCount;
    cellmodel.commentCount = oldCellModel.commentCount;
    cellmodel.userRepin = oldCellModel.userRepin;
    return cellmodel;
}

@end

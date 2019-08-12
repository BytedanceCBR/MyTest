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

@implementation FHFeedUGCCellCommunityModel

@end

//@implementation FHFeedUGCCellImageListUrlListModel
//
//@end
//
//@implementation FHFeedUGCCellImageListModel
//
//@end

@implementation FHFeedUGCCellUserModel

@end

@implementation FHFeedUGCOriginItemModel

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
        Class cls = nil;
        if(type == FHUGCFeedListCellTypeUGC){
            cls = [FHFeedUGCContentModel class];
        }else if(type == FHUGCFeedListCellTypeArticle || type == FHUGCFeedListCellTypeQuestion || type == FHUGCFeedListCellTypeAnswer || type == FHUGCFeedListCellTypeArticleComment || type == FHUGCFeedListCellTypeUGCBanner || type == FHUGCFeedListCellTypeUGCRecommend){
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
    }
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFeedContent:(FHFeedContentModel *)model {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.cellType = [model.cellType integerValue];
    cellModel.groupId = model.groupId;
    cellModel.logPb = model.logPb;
    //处理图片
    cellModel.imageList = model.imageList;
    //处理大图
    cellModel.largeImageList = model.largeImageList;
    //处理其他数据
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle || cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        cellModel.title = model.title;
        cellModel.behotTime = model.behotTime;
        cellModel.openUrl = model.openUrl;
        cellModel.numberOfLines = 5;
        
        if (model.isFromDetail) {
            cellModel.numberOfLines = 0;
        }
        
        [FHUGCCellHelper setArticleRichContentWithModel:cellModel width:([UIScreen mainScreen].bounds.size.width - 40)];
        
        if(cellModel.openUrl && !isEmptyString(cellModel.openUrl)){
            //针对问答的情况
            if(model.sourceDesc){
                cellModel.desc = [[NSMutableAttributedString alloc] initWithString:model.sourceDesc];
            }
        }else{
            //文章
            cellModel.desc = [self generateArticleDesc:model];
            cellModel.openUrl = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&item_id=%@",model.groupId,model.itemId];
        }
//        cellModel.detailScheme = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&item_id=%@",model.groupId,model.itemId];
        
        FHFeedUGCCellCommunityModel *community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.community.name;
        community.url = model.community.url;
        community.socialGroupId = model.community.socialGroupId;
        cellModel.community = community;
        
        if(cellModel.imageList.count == 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleSingleImage;
        }else if(cellModel.imageList.count > 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleMultiImage;
        }else{
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticlePureTitle;
        }
    }else if(cellModel.cellType == FHUGCFeedListCellTypeAnswer){
        cellModel.content = model.title;
        cellModel.behotTime = model.behotTime;
        cellModel.openUrl = model.openUrl;
        cellModel.showLookMore = YES;
        cellModel.numberOfLines = 3;
        
        double time = [model.publishTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
        cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
        
        cellModel.diggCount = model.diggCount;
        cellModel.commentCount = model.commentCount;
        cellModel.userDigg = model.userDigg;
        
        FHFeedUGCCellCommunityModel *community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.community.name;
        community.url = model.community.url;
        community.socialGroupId = model.community.socialGroupId;
        cellModel.community = community;
        
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.userInfo.name;
        user.avatarUrl = model.userInfo.avatarUrl;
        user.userId = model.userInfo.userId;
        cellModel.user = user;
        
        FHFeedUGCOriginItemModel *originItemModel = [[FHFeedUGCOriginItemModel alloc] init];
        originItemModel.type = @"[问答]";
        originItemModel.content = model.rawData.content.question.title;
        originItemModel.openUrl = model.rawData.content.question.questionListSchema;
        cellModel.originItemModel = originItemModel;
    
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
    }else if(cellModel.cellType == FHUGCFeedListCellTypeArticleComment){
        cellModel.content = model.rawData.commentBase.content;
        cellModel.behotTime = model.behotTime;
        cellModel.openUrl = model.rawData.commentBase.detailSchema;
        cellModel.showLookMore = YES;
        cellModel.numberOfLines = 3;
        
        double time = [model.publishTime doubleValue];
        NSString *publishTime = [FHBusinessManager ugcCustomtimeAndCustomdateStringSince1970:time];
        cellModel.desc = [[NSAttributedString alloc] initWithString:publishTime];
        
        cellModel.diggCount = model.diggCount;
        cellModel.commentCount = model.commentCount;
        cellModel.userDigg = model.userDigg;
        
        FHFeedUGCCellCommunityModel *community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.community.name;
        community.url = model.community.url;
        community.socialGroupId = model.community.socialGroupId;
        cellModel.community = community;
        
        FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
        user.name = model.userInfo.name;
        user.avatarUrl = model.userInfo.avatarUrl;
        user.userId = model.userInfo.userId;
        cellModel.user = user;
        
        FHFeedUGCOriginItemModel *originItemModel = [[FHFeedUGCOriginItemModel alloc] init];
        originItemModel.type = @"[文章]";
        originItemModel.content = model.rawData.originGroup.title;
        originItemModel.openUrl = model.rawData.originGroup.schema;
        originItemModel.imageModel = model.rawData.originGroup.middleImage;
        cellModel.originItemModel = originItemModel;
        
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
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBanner;
        cellModel.openUrl = model.url;
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCRecommend){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCRecommend;
        cellModel.recommendSocialGroupList = model.recommendSocialGroupList;
        cellModel.elementFrom = @"like_neighborhood";
    }
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFeedUGCContent:(FHFeedUGCContentModel *)model {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.originData = model;
    cellModel.cellType = [model.cellType integerValue];
    cellModel.title = model.title;
    cellModel.behotTime = model.behotTime;
    cellModel.content = model.content;
    cellModel.contentRichSpan = model.contentRichSpan;
    cellModel.diggCount = model.diggCount;
    cellModel.commentCount = model.commentCount;
    cellModel.userDigg = model.userDigg;
    cellModel.desc = [self generateUGCDesc:model];
    cellModel.groupId = model.threadId;
    cellModel.logPb = model.logPb;
    cellModel.showLookMore = YES;
    cellModel.numberOfLines = 3;
    
    FHFeedUGCCellCommunityModel *community = [[FHFeedUGCCellCommunityModel alloc] init];
    community.name = model.community.name;
    community.url = model.community.url;
    community.socialGroupId = model.community.socialGroupId;
    cellModel.community = community;
    
    FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
    user.name = model.user.name;
    user.avatarUrl = model.user.avatarUrl;
    user.userId = model.user.userId;
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
    
    if(!isEmptyString(model.distanceInfo)){
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

@end

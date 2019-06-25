//
//  FHFeedUGCCellModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import "FHFeedUGCCellModel.h"
#import "FHMainApi.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTBaseMacro.h"

@implementation FHFeedUGCCellCommunityModel

@end

@implementation FHFeedUGCCellImageListUrlListModel

@end

@implementation FHFeedUGCCellImageListModel

@end

@implementation FHFeedUGCCellUserModel

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
        }else if(type == FHUGCFeedListCellTypeArticle || type == FHUGCFeedListCellTypeQuestion || type == FHUGCFeedListCellTypeUGCBanner || type == FHUGCFeedListCellTypeUGCRecommend){
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
    //处理图片
    NSMutableArray *cellImageList = [NSMutableArray array];
    for (FHFeedContentImageListModel *imageModel in model.imageList) {
        FHFeedUGCCellImageListModel *cellImageModel = [[FHFeedUGCCellImageListModel alloc] init];
        cellImageModel.uri = imageModel.uri;
        cellImageModel.url = imageModel.url;
        cellImageModel.width = imageModel.width;
        cellImageModel.height = imageModel.height;
        
        NSMutableArray *cellImageModelUrlList = [NSMutableArray array];
        for (FHFeedContentImageListUrlListModel *urlListModel in imageModel.urlList) {
            FHFeedUGCCellImageListUrlListModel *cellUrlListModel = [[FHFeedUGCCellImageListUrlListModel alloc] init];
            cellUrlListModel.url = urlListModel.url;
            [cellImageModelUrlList addObject:cellUrlListModel];
        }
        cellImageModel.urlList = cellImageModelUrlList;
        
        [cellImageList addObject:cellImageModel];
    }
    cellModel.imageList = cellImageList;
    //处理其他数据
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle || cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        cellModel.title = model.title;
        cellModel.behotTime = model.behotTime;
        cellModel.openUrl = model.openUrl;
        
        if(!isEmptyString(model.openUrl) && !isEmptyString(model.sourceDesc)){
            //针对问答的情况
            cellModel.desc = [[NSMutableAttributedString alloc] initWithString:model.sourceDesc];
        }else{
            cellModel.desc = [self generateArticleDesc:model];
        }
        cellModel.detailScheme = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&item_id=%@",model.groupId,model.itemId];
        
        FHFeedUGCCellCommunityModel *community = [[FHFeedUGCCellCommunityModel alloc] init];
        community.name = model.community.name;
        community.url = model.community.url;
        cellModel.community = community;
        
        if(cellModel.imageList.count == 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleSingleImage;
        }else if(cellModel.imageList.count > 1){
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleMultiImage;
        }else{
            cellModel.cellSubType = FHUGCFeedListCellSubTypeArticlePureTitle;
        }
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCBanner){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBanner;
        cellModel.openUrl = model.url;
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCRecommend){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCRecommend;
        cellModel.recommendSocialGroupList = model.recommendSocialGroupList;
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
        FHFeedUGCContentUgcU13CutImageListModel *imageModel = [model.ugcU13CutImageList firstObject];
        FHFeedUGCCellImageListModel *cellImageModel = [[FHFeedUGCCellImageListModel alloc] init];
        cellImageModel.uri = imageModel.uri;
        cellImageModel.url = imageModel.url;
        cellImageModel.width = imageModel.width;
        cellImageModel.height = imageModel.height;
        
        NSMutableArray *cellImageModelUrlList = [NSMutableArray array];
        for (FHFeedUGCContentUgcU13CutImageListUrlListModel *urlListModel in imageModel.urlList) {
            FHFeedUGCCellImageListUrlListModel *cellUrlListModel = [[FHFeedUGCCellImageListUrlListModel alloc] init];
            cellUrlListModel.url = urlListModel.url;
            [cellImageModelUrlList addObject:cellUrlListModel];
        }
        cellImageModel.urlList = cellImageModelUrlList;
        
        [cellImageList addObject:cellImageModel];
    }else{
        if(model.thumbImageList.count > 0){
            //多图
            for (FHFeedUGCContentThumbImageListModel *imageModel in model.thumbImageList) {
                FHFeedUGCCellImageListModel *cellImageModel = [[FHFeedUGCCellImageListModel alloc] init];
                cellImageModel.uri = imageModel.uri;
                cellImageModel.url = imageModel.url;
                cellImageModel.width = imageModel.width;
                cellImageModel.height = imageModel.height;
                
                NSMutableArray *cellImageModelUrlList = [NSMutableArray array];
                for (FHFeedUGCContentThumbImageListUrlListModel *urlListModel in imageModel.urlList) {
                    FHFeedUGCCellImageListUrlListModel *cellUrlListModel = [[FHFeedUGCCellImageListUrlListModel alloc] init];
                    cellUrlListModel.url = urlListModel.url;
                    [cellImageModelUrlList addObject:cellUrlListModel];
                }
                cellImageModel.urlList = cellImageModelUrlList;
                
                [cellImageList addObject:cellImageModel];
            }
        }else{
            //纯文本
            cellModel.showLookMore = YES;
        }
    }
    
    cellModel.imageList = cellImageList;
    
    NSMutableArray *cellLargeImageList = [NSMutableArray array];
    if(model.largeImageList.count > 0){
        //大图
        for (FHFeedUGCContentLargeImageListModel *imageModel in model.largeImageList) {
            FHFeedUGCCellImageListModel *cellImageModel = [[FHFeedUGCCellImageListModel alloc] init];
            cellImageModel.uri = imageModel.uri;
            cellImageModel.url = imageModel.url;
            cellImageModel.width = imageModel.width;
            cellImageModel.height = imageModel.height;
            
            NSMutableArray *cellImageModelUrlList = [NSMutableArray array];
            for (FHFeedUGCContentLargeImageListUrlListModel *urlListModel in imageModel.urlList) {
                FHFeedUGCCellImageListUrlListModel *cellUrlListModel = [[FHFeedUGCCellImageListUrlListModel alloc] init];
                cellUrlListModel.url = urlListModel.url;
                [cellImageModelUrlList addObject:cellUrlListModel];
            }
            cellImageModel.urlList = cellImageModelUrlList;
            
            [cellLargeImageList addObject:cellImageModel];
        }
    }
    cellModel.largeImageList = cellLargeImageList;
    
    if(cellModel.imageList.count == 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeSingleImage;
    }else if(cellModel.imageList.count > 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeMultiImage;
    }else{
        cellModel.cellSubType = FHUGCFeedListCellSubTypePureTitle;
    }
    
    return cellModel;
}

//推荐假数据
+ (FHFeedUGCCellModel *)modelFromFakeData {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.cellType = 2001;
    cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCRecommend;
    
    NSMutableArray *sourceList = [NSMutableArray array];
    for (NSInteger i = 0; i < 20; i++) {
        [sourceList addObject:[NSString stringWithFormat:@"小区%li",(long)i]];
    }
//    cellModel.interestNeighbourhoodList = sourceList;
    
    return cellModel;
}

+ (NSAttributedString *)generateUGCDesc:(FHFeedUGCContentModel *)model {
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    double time = [model.createTime doubleValue];
    NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
    
    if(![publishTime isEqualToString:@""]){
        NSAttributedString *publishTimeAStr = [[NSAttributedString alloc] initWithString:publishTime];
        [desc appendAttributedString:publishTimeAStr];
    }
    
    if(!isEmptyString(model.distanceInfo)){
//        NSString *distance = @"   1.5km";
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
    NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:time];
    
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

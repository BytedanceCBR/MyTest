//
//  FHFeedUGCCellModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import "FHFeedUGCCellModel.h"
#import "FHMainApi.h"

@implementation FHFeedUGCCellImageListModel

@end

@implementation FHFeedUGCCellUserModel

@end

@implementation FHFeedUGCCellModel

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
        }else if(type == FHUGCFeedListCellTypeArticle){
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
    cellModel.cellType = model.cellType;
    cellModel.title = model.title;
    cellModel.behotTime = model.behotTime;
    cellModel.desc = @"信息来源";
    
    NSMutableArray *cellImageList = [NSMutableArray array];
    for (FHFeedContentImageListModel *imageModel in model.imageList) {
        FHFeedUGCCellImageListModel *cellImageModel = [[FHFeedUGCCellImageListModel alloc] init];
        cellImageModel.url = imageModel.url;
        cellImageModel.width = imageModel.width;
        cellImageModel.height = imageModel.height;
        [cellImageList addObject:cellImageModel];
    }
    
    cellModel.imageList = cellImageList;
    
    if(cellModel.imageList.count == 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleSingleImage;
    }else if(cellModel.imageList.count > 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeArticleMultiImage;
    }else{
        cellModel.cellSubType = FHUGCFeedListCellSubTypeArticlePureTitle;
    }
    
    return cellModel;
}

+ (FHFeedUGCCellModel *)modelFromFeedUGCContent:(FHFeedUGCContentModel *)model {
    FHFeedUGCCellModel *cellModel = [[FHFeedUGCCellModel alloc] init];
    cellModel.cellType = model.cellType;
    cellModel.title = model.title;
    cellModel.behotTime = model.behotTime;
    cellModel.content = model.content;
    cellModel.contentRichSpan = model.contentRichSpan;
    cellModel.diggCount = model.diggCount;
    cellModel.commentCount = model.commentCount;
    cellModel.desc = @"今天 14:00";
    
    FHFeedUGCCellUserModel *user = [[FHFeedUGCCellUserModel alloc] init];
    user.name = model.user.name;
    user.avatarUrl = model.user.avatarUrl;
    cellModel.user = user;
    
    NSMutableArray *cellImageList = [NSMutableArray array];
    
    if(model.ugcU13CutImageList.count > 0){
        //单图
        FHFeedUGCContentUgcU13CutImageListModel *imageModel = [model.ugcU13CutImageList firstObject];
        FHFeedUGCCellImageListModel *cellImageModel = [[FHFeedUGCCellImageListModel alloc] init];
        cellImageModel.url = imageModel.url;
        cellImageModel.width = imageModel.width;
        cellImageModel.height = imageModel.height;
        [cellImageList addObject:cellImageModel];
    }else{
        if(model.thumbImageList.count > 0){
            //多图
            for (FHFeedUGCContentThumbImageListModel *imageModel in model.thumbImageList) {
                FHFeedUGCCellImageListModel *cellImageModel = [[FHFeedUGCCellImageListModel alloc] init];
                cellImageModel.url = imageModel.url;
                cellImageModel.width = imageModel.width;
                cellImageModel.height = imageModel.height;
                [cellImageList addObject:cellImageModel];
            }
        }else{
            //纯文本
            cellModel.showLookMore = YES;
        }
    }
    
    cellModel.imageList = cellImageList;
    
    if(cellModel.imageList.count == 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeSingleImage;
    }else if(cellModel.imageList.count > 1){
        cellModel.cellSubType = FHUGCFeedListCellSubTypeMultiImage;
    }else{
        cellModel.cellSubType = FHUGCFeedListCellSubTypePureTitle;
    }
    
    return cellModel;
}

@end

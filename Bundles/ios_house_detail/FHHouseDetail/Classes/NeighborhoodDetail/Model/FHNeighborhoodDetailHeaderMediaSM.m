//
//  FHNeighborhoodDetailHeaderMediaSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailHeaderMediaSM.h"

@implementation FHNeighborhoodDetailHeaderMediaSM

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return YES;
}

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    // 添加头滑动图片 && 视频
    FHNeighborhoodDetailHeaderMediaModel *headerCellModel = [[FHNeighborhoodDetailHeaderMediaModel alloc] init];
    
    NSMutableArray<FHHouseDetailImageListDataModel> *imageListDataList = [NSMutableArray<FHHouseDetailImageListDataModel> arrayWithCapacity:model.data.albumInfo.tabList.count];
    
    for (FHHouseDetailMediaTabInfo *tabInfo in model.data.albumInfo.tabList) {
        FHHouseDetailImageListDataModel *houseImageDictList = [[FHHouseDetailImageListDataModel alloc] init];
        houseImageDictList.houseImageTypeName = tabInfo.tabName;
        houseImageDictList.usedSceneType = FHHouseDetailImageListDataUsedSceneTypeNeighborhood;
        NSMutableArray *imageArr = [NSMutableArray array];
        for (FHHouseDetailMediaStruct *imageStruct in tabInfo.tabContent) {
            [imageArr addObject:imageStruct.image];
        }
        houseImageDictList.houseImageList = imageArr.copy;
        [imageListDataList addObject:houseImageDictList];
    }
    headerCellModel.houseImageDictList = imageListDataList.copy;
    headerCellModel.albumInfo = model.data.albumInfo;
    headerCellModel.gaodeLon = model.data.neighborhoodInfo.gaodeLng;
    headerCellModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
    
    BOOL hasVideo = NO;
    if (model.data.neighborhoodVideo && model.data.neighborhoodVideo.videoInfos.count > 0) {
        hasVideo = YES;
    }
    
    if (hasVideo) {
        FHVideoHouseVideoVideoInfosModel *info = model.data.neighborhoodVideo.videoInfos[0];
        FHMultiMediaItemModel * itemModel = [[FHMultiMediaItemModel alloc] init];
        itemModel.cellHouseType = FHMultiMediaCellHouseNeiborhood;
        itemModel.mediaType = FHMultiMediaTypeVideo;
        itemModel.videoID = info.vid;
        itemModel.imageUrl = info.coverImageUrl;
        itemModel.vWidth = info.vWidth;
        itemModel.vHeight = info.vHeight;
        itemModel.infoTitle = model.data.neighborhoodVideo.infoTitle;
        itemModel.infoSubTitle = model.data.neighborhoodVideo.infoSubTitle;
        itemModel.groupType = @"视频";
        itemModel.pictureTypeName = @"视频";
        headerCellModel.vedioModel = itemModel;// 添加视频模型数据
    }
    if (model.data.neighborhoodInfo.baiduPanoramaUrl.length) {
        FHMultiMediaItemModel * itemModel = [[FHMultiMediaItemModel alloc] init];
        itemModel.cellHouseType = FHMultiMediaCellHouseNeiborhood;
        itemModel.mediaType = FHMultiMediaTypeBaiduPanorama;
        itemModel.imageUrl = model.data.neighborhoodInfo.baiduPanoramaUrl;
        itemModel.groupType = @"街景";
        itemModel.pictureTypeName = @"街景";
        headerCellModel.baiduPanoramaModel = itemModel;// 添加百度街景数据
    }
    
    
    self.headerCellModel = headerCellModel;
    self.items = [NSArray arrayWithObject:self.headerCellModel];
}

- (void)updateWithContactViewModel:(FHHouseDetailContactViewModel *)contactViewModel {
    self.headerCellModel.contactViewModel = contactViewModel;
}

@end

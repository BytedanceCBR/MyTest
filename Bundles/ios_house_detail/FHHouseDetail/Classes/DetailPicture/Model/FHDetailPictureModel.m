//
//  FHDetailPictureModel.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/20.
//

#import "FHDetailPictureModel.h"

@implementation FHDetailPictureModel

@end

@implementation FHDetailPictureItemModel

+ (FHVideoModel *)getVideoModelFromMediaStructVideoInfo:(FHVideoHouseVideoVideoInfosModel *)videoInfo {
    FHVideoModel *videoModel = [[FHVideoModel alloc] init];
    videoModel.videoID = videoInfo.vid;
    videoModel.vWidth = videoInfo.vWidth;
    videoModel.vHeight = videoInfo.vHeight;
    videoModel.muted = NO;
    videoModel.repeated = NO;
    videoModel.isShowControl = NO;
    videoModel.isShowMiniSlider = YES;
    videoModel.isShowStartBtnWhenPause = YES;
    return videoModel;
}

+ (NSArray<FHDetailPictureItemModel> *)getPictureTabInfo:(FHHouseDetailMediaTabInfo *)tabInfo rootName:(NSString *)rootName {
    NSMutableArray *groupModels = [NSMutableArray array];
    if (tabInfo.tabContent.count > 0) {
        for (FHHouseDetailMediaStruct *mediaStr in tabInfo.tabContent) {
            if (mediaStr.videoInfo) {   //视频
                FHDetailPictureItemVideoModel *videoItemModel = [[FHDetailPictureItemVideoModel alloc] init];
                videoItemModel.itemType = FHDetailPictureModelTypeVideo;
                videoItemModel.image = mediaStr.image;
                videoItemModel.desc = mediaStr.desc;
                videoItemModel.rootGroupName = rootName;
                videoItemModel.videoModel = [FHDetailPictureItemModel getVideoModelFromMediaStructVideoInfo:mediaStr.videoInfo];
                videoItemModel.videoModel.coverImageUrl = mediaStr.image.url;
                [groupModels addObject:videoItemModel];
            } else if (mediaStr.vrInfo) {   //VR
                FHDetailPictureItemVRModel *vrItemModel = [[FHDetailPictureItemVRModel alloc] init];
                vrItemModel.itemType = FHDetailPictureModelTypeVR;
                vrItemModel.image = mediaStr.image;
                vrItemModel.desc = mediaStr.desc;
                vrItemModel.rootGroupName = rootName;
                vrItemModel.vrModel = mediaStr.vrInfo;
                [groupModels addObject:vrItemModel];
            } else {                        //图片
                FHDetailPictureItemPictureModel *pictureItemModel = [[FHDetailPictureItemPictureModel alloc] init];
                pictureItemModel.itemType = FHDetailPictureModelTypePicture;
                pictureItemModel.image = mediaStr.image;
                pictureItemModel.desc = mediaStr.desc;
                pictureItemModel.rootGroupName = rootName;
                [groupModels addObject:pictureItemModel];
            }
        }
    } else if (tabInfo.subTab.count > 0) {
        for (FHHouseDetailMediaTabInfo *otherTabInfo in tabInfo.subTab) {
            NSArray *otherArr = [FHDetailPictureItemModel getPictureTabInfo:otherTabInfo rootName:rootName];
            [groupModels addObjectsFromArray:otherArr];
        }
    }
    return groupModels.copy;
}

@end

@implementation FHDetailPictureItemPictureModel

@end

@implementation FHDetailPictureItemVideoModel

@end

@implementation FHDetailPictureItemVRModel

@end


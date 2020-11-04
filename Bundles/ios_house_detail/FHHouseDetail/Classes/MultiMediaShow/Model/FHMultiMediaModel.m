//
//  FHMultiMediaModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaModel.h"

@implementation FHMultiMediaItemModel

+ (NSArray<FHMultiMediaItemModel> *)getMultiMediaItem:(FHHouseDetailMediaTabInfo *)tabInfo rootName:(NSString *)rootName {
    NSMutableArray *groupModels = [NSMutableArray array];
    if (tabInfo.tabContent.count > 0) {
        for (FHHouseDetailMediaStruct *mediaStr in tabInfo.tabContent) {
            FHMultiMediaItemModel *item = [[FHMultiMediaItemModel alloc] init];
            if (mediaStr.videoInfo) {   //视频
                item.mediaType = FHMultiMediaTypeVideo;
                item.groupType = tabInfo.tabName;
                item.imageUrl = mediaStr.image.url;
                item.videoID = mediaStr.videoInfo.vid;
                item.vHeight = mediaStr.videoInfo.vHeight;
                item.vWidth = mediaStr.videoInfo.vWidth;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            } else if (mediaStr.vrInfo) {   //VR
                item.mediaType = FHMultiMediaTypeVRPicture;
                item.groupType = tabInfo.tabName;
                item.imageUrl = mediaStr.image.url;
                item.vrOpenUrl = mediaStr.vrInfo.openUrl;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            } else if (mediaStr.panoramaInfo) { //街景
                item.mediaType = FHMultiMediaTypeBaiduPanorama;
                item.groupType = tabInfo.tabName;
                item.imageUrl = mediaStr.image.url;
                item.pictureTypeName = rootName;
                item.gaodeLat = mediaStr.panoramaInfo.gaodeLat;
                item.gaodeLng = mediaStr.panoramaInfo.gaodeLng;
                [groupModels addObject:item];
            } else {                        //图片
                item.mediaType = FHMultiMediaTypePicture;
                item.groupType = tabInfo.tabName;
                item.imageUrl = mediaStr.image.url;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            }
        }
    } else if (tabInfo.subTab.count > 0) {
        for (FHHouseDetailMediaTabInfo *otherTabInfo in tabInfo.subTab) {
            NSArray *otherArr = [FHMultiMediaItemModel getMultiMediaItem:otherTabInfo rootName:rootName];
            [groupModels addObjectsFromArray:otherArr];
        }
    }
    return groupModels.copy;
}

- (BOOL)isEqualWithOtherMediaItemModel:(FHMultiMediaItemModel *)other {
    return [self.imageUrl isEqualToString:other.imageUrl] && self.mediaType == other.mediaType;
}

@end

@implementation FHMultiMediaModel

@end

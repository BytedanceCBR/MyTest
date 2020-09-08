//
//  FHNewHouseDetailHeaderMediaSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailHeaderMediaSM.h"

@implementation FHNewHouseDetailHeaderMediaSM

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return YES;
}

- (void)updateDetailModel:(FHDetailNewModel *)model {
    // 添加头滑动图片 && 视频
    FHNewHouseDetailHeaderMediaModel *headerCellModel = [[FHNewHouseDetailHeaderMediaModel alloc] init];
    headerCellModel.houseImageAssociateInfo = model.data.imageGroupAssociateInfo;
    headerCellModel.imageAlbumAssociateInfo = model.data.imageAlbumAssociateInfo;
    headerCellModel.isShowTopImageTab = model.data.isShowTopImageTab;
    headerCellModel.vrModel = model.data.vrInfo;
    if ([model.data.topImages isKindOfClass:[NSArray class]] && model.data.topImages.count > 0) {
        NSMutableArray *houseImageList = [NSMutableArray array];
        //只有新房详情传递了 topImages 数据，用户对接图片列表页页
        headerCellModel.topImages = model.data.topImages;
        //这个地方组合的图片列表，如果isShowTopImageTab为true，头图只显示一张图片，大图详情和图片列表需要重新组合
        //false的话提供给头图使用，以及大图详情
        for (FHDetailNewTopImage *topImage in model.data.topImages) {
            FHHouseDetailImageListDataModel *houseImageDictList = [[FHHouseDetailImageListDataModel alloc] init];
            NSMutableArray *houseImages = [NSMutableArray array];
            for (FHHouseDetailImageGroupModel * groupModel in topImage.imageGroup) {
                for (NSInteger j = 0; j < groupModel.images.count; j++) {
                    [houseImages addObject:groupModel.images[j]];
                }
            }
            houseImageDictList.houseImageTypeName = topImage.name;
            houseImageDictList.usedSceneType = FHHouseDetailImageListDataUsedSceneTypeNew;
            houseImageDictList.houseImageList = houseImages.copy;
            houseImageDictList.houseImageType = topImage.type;
            [houseImageList addObject:houseImageDictList];
        }
        headerCellModel.houseImageDictList = houseImageList.copy;
    }
    self.headerCellModel = headerCellModel;
    self.items = [NSArray arrayWithObject:self.headerCellModel];
}

@end

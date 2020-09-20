//
//  FHDetailNeighborhoodMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/14.
//

#import "FHDetailBaseCell.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHFloorPanPicShowModel;

@interface FHDetailNeighborhoodMediaHeaderCell : FHDetailBaseCell

+ (CGFloat)cellHeight;

@end

@interface FHDetailNeighborhoodMediaHeaderModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageListDataModel> *houseImageDictList;// 图片数据
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *vedioModel;// 视频模型
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *baiduPanoramaModel;// 街景
@property (nonatomic, strong, nullable) FHHouseDetailAlbumInfo *albumInfo;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (strong, nonatomic) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型

@end


NS_ASSUME_NONNULL_END

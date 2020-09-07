//
//  FHFloorPanDetailMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/7.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailMediaHeaderCell : FHDetailBaseCell



@end

@interface FHFloorPanDetailMediaHeaderModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageListDataModel> *houseImageDictList;// 图片数据
@property (nonatomic, strong , nullable) FHDetailVRInfo *vrModel;                                  // vr数据
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *vedioModel;// 视频模型
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (strong, nonatomic) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型
@property (nonatomic, weak) UIViewController *weakVC;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *houseImageAssociateInfo;
//1.0.0 新增楼盘相册页线索
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *imageAlbumAssociateInfo;
/// 合并，组合，处理

@end

NS_ASSUME_NONNULL_END

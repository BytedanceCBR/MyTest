//
//  FHNewHouseDetailHeaderMediaCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/8.
//

#import "FHDetailBaseCell.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"
#import "FHDetailNewModel.h"
@class FHNewHouseDetailViewController;
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailHeaderMediaCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong, nullable) NSDictionary *detailTracerDict;
@end

@interface FHNewHouseDetailHeaderMediaModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageListDataModel> *houseImageDictList;// 图片数据
@property (nonatomic, strong , nullable) FHDetailNewVRInfo *vrModel;                                  // vr数据
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *vedioModel;// 视频模型
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewTopImage *> *topImages;
@property (nonatomic, weak) UIViewController *weakVC;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *houseImageAssociateInfo;
@property (nonatomic, assign) BOOL isShowTopImageTab;
//1.0.0 新增楼盘相册页线索
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *imageAlbumAssociateInfo;
/// 合并，组合，处理

@end

NS_ASSUME_NONNULL_END

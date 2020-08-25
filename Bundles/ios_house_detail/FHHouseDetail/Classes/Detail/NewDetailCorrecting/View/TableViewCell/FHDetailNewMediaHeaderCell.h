//
//  FHDetailNewMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//

//新房专用头图
#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"
#import "FHDetailNewModel.h"
NS_ASSUME_NONNULL_BEGIN
@class FHDetailNewTopImage;
@interface FHDetailNewMediaHeaderCell : FHDetailBaseCell

@end

@interface FHDetailNewMediaHeaderModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageListDataModel> *houseImageDictList;// 图片数据
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *vedioModel;// 视频模型
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *baiduPanoramaModel;// 街景

@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, assign) BOOL isInstantData;
@property (nonatomic, strong, nullable)   FHDetailHouseVRDataModel  *vrModel;// 视频模型
@property (strong, nonatomic) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型
@property (nonatomic, strong , nullable) NSArray<FHDetailNewTopImage *> *topImages;
@property (nonatomic, weak) UIViewController *weakVC;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *houseImageAssociateInfo;
@property (nonatomic, assign) BOOL isShowTopImageTab;

//新房头图进入图片列表页datasource
@property (nonatomic, copy) NSArray<FHHouseDetailImageGroupModel> *smallImageGroup;

//1.0.0 新增楼盘相册页线索
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *imageAlbumAssociateInfo;
/// 合并，组合，处理
- (NSArray *)processTopImagesToSmallImageGroups;

@end

NS_ASSUME_NONNULL_END

//
//  FHDetailMediaHeaderCorrectingCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"
NS_ASSUME_NONNULL_BEGIN

@class FHDetailNewTopImage;

@interface FHDetailMediaHeaderCorrectingCell : FHDetailBaseCell

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END

@interface FHDetailMediaHeaderCorrectingModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataHouseImageDictListModel> *houseImageDictList;// 图片数据
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *vedioModel;// 视频模型
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, assign) BOOL isInstantData;
@property (nonatomic, strong, nullable)   FHDetailHouseVRDataModel  *vrModel;// 视频模型
@property (strong, nonatomic) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型
@property (nonatomic, strong , nullable) NSArray<FHDetailNewTopImage *> *topImages;
@property (nonatomic, assign) BOOL isShowTopImageTab;

@end

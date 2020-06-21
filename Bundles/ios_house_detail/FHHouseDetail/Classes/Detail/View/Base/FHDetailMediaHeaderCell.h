//
//  FHDetailMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailMediaHeaderCell : FHDetailBaseCell

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END

@interface FHDetailMediaHeaderModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageListDataModel> *houseImageDictList;// 图片数据
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *vedioModel;// 视频模型
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, assign) BOOL isInstantData;
@property (nonatomic, strong, nullable)   FHDetailHouseVRDataModel  *vrModel;// 视频模型
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *houseImageAssociateInfo;
@end

//
//  FHNeighborhoodDetailHeaderMediaCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHDetailBaseCell.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHMultiMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHeaderMediaCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong, nullable) NSDictionary *detailTracerDict;

@end

@interface FHNeighborhoodDetailHeaderMediaModel : FHDetailBaseModel


@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageListDataModel> *houseImageDictList;// 图片数据
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *vedioModel;// 视频模型
@property (nonatomic, strong, nullable)   FHMultiMediaItemModel       *baiduPanoramaModel;// 街景
@property (nonatomic, strong, nullable) FHHouseDetailMediaInfo *albumInfo;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@end

NS_ASSUME_NONNULL_END

//
//  FHDetailAgentListCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN
// 推荐经纪人-列表
@interface FHDetailAgentListCell : FHDetailBaseCell

@end

@interface FHDetailAgentItemView : UIControl

@property (nonatomic, strong)   UIImageView       *avator;
@property (nonatomic, strong)   UIButton       *licenceIcon;
@property (nonatomic, strong)   UIButton       *callBtn;
@property (nonatomic, strong)   UILabel       *name;
@property (nonatomic, strong)   UILabel       *agency;

@end

// FHDetailAgentListModel

@interface FHDetailAgentListModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailContactModel> *recommendedRealtors;

@end

NS_ASSUME_NONNULL_END

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
#import "FHHouseDetailPhoneCallViewModel.h"
#import "FHHouseDetailFollowUpViewModel.h"

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

@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, strong , nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, strong)FHHouseDetailFollowUpViewModel *followUpViewModel;

@end

NS_ASSUME_NONNULL_END

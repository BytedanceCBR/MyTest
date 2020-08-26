//
//  FHDetailSurveyAgentListCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/08/26.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHHouseDetailPhoneCallViewModel.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
NS_ASSUME_NONNULL_BEGIN
// 推荐经纪人-列表
@interface FHDetailSurveyAgentListCell : FHDetailBaseCell <FHDetailScrollViewDidScrollProtocol>

@end

@interface FHDetailSurveyAgentListModel : FHDetailBaseModel

@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, copy , nullable) NSString *recommendedRealtorsTitle; // 推荐经纪人标题文案
@property (nonatomic, copy , nullable) NSString *recommendedRealtorsSubTitle; // 推荐经纪人副标题文案
@property (nonatomic, strong , nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, weak) UIViewController *belongsVC;

@end


NS_ASSUME_NONNULL_END

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
#import <FHHouseBase/FHHouseFollowUpHelper.h>
NS_ASSUME_NONNULL_BEGIN
// 推荐经纪人-列表
@interface FHDetailAgentListCell : FHDetailBaseCell <FHDetailScrollViewDidScrollProtocol>

@end

@interface FHDetailAgentItemView : UIControl

@property (nonatomic, strong)   UIImageView *avator;
@property(nonatomic , strong)   UIImageView *identifyView;
@property (nonatomic, strong)   UIButton    *licenceIcon;
@property (nonatomic, strong)   UIButton    *callBtn;
@property (nonatomic, strong)   UIButton    *imBtn;
@property (nonatomic, strong)   UILabel     *name;
@property (nonatomic, strong)   UILabel     *agency;
@property (nonatomic, strong)   UIImageView *agencyBac;
@property (nonatomic, strong)   UILabel     *score;
@property (nonatomic, strong)   UILabel     *scoreDescription;
@property (nonatomic, strong)   UILabel     *realtorEvaluate;  // 话术
@property (nonatomic, strong)   UIView      *agencyDescriptionBac;
@property (nonatomic, strong)   UILabel     *agencyDescriptionLabel;//公司介绍


-(instancetype)initWithModel:(FHDetailContactModel *)model;

-(void)configForLicenceIconWithHidden:(BOOL)isHidden;

@end

// FHDetailAgentListModel

@interface FHDetailAgentListModel : FHDetailBaseModel

@property (nonatomic, weak)     UITableView       *tableView;
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, copy , nullable) NSString *recommendedRealtorsTitle; // 推荐经纪人标题文案
@property (nonatomic, copy , nullable) NSString *recommendedRealtorsSubTitle; // 推荐经纪人副标题文案
@property (nonatomic, strong , nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, weak) UIViewController *belongsVC;

@end


NS_ASSUME_NONNULL_END

//
// Created by zhulijun on 2019-08-27.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"

@class FHHouseDetailPhoneCallViewModel;

@interface FHDetailHouseReviewCommentCell : FHDetailBaseCell
@end

@interface FHDetailHouseReviewCommentCellModel : FHDetailBaseModel
@property(nonatomic, strong, nullable) NSArray <FHDetailHouseReviewCommentModel> *houseReviewComment;
@property(nonatomic, assign) BOOL isExpand; // 折叠
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@end

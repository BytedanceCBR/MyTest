//
// Created by zhulijun on 2019-08-27.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"

@interface FHDetailHouseReviewCommentCell : FHDetailBaseCell
@end

@interface FHDetailHouseReviewCommentCellModel : FHDetailBaseModel
@property(nonatomic, strong, nullable) NSArray <FHDetailHouseReviewCommentModel> *houseReviewComment;
@property(nonatomic, assign) BOOL isExpand; // 折叠
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, weak) UITableView *tableView;
@end

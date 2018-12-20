//
//  FHHomeHeaderTableViewCell.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <UIKit/UIKit.h>
#import <FHHouseRent.h>
#import "FHHomeCellHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeHeaderTableViewCell : UITableViewCell

@property (nonatomic, strong) UITableView* contentTableView;
@property (nonatomic, strong) FHRowsView* rowsView;

- (void)refreshUI:(FHHomeHeaderCellPositionType) type;

- (void)refreshWithData:(nonnull id)data;

- (void)refreshUI;

@end

NS_ASSUME_NONNULL_END

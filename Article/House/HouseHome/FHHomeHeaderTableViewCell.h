//
//  FHHomeHeaderTableViewCell.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <UIKit/UIKit.h>
#import <FHHouseRent.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeHeaderTableViewCell : UITableViewCell

@property (nonatomic, strong) UITableView* contentTableView;
@property (nonatomic, strong) FHRowsView* rowsView;

- (void)refreshUI;

- (void)refreshWithData:(nonnull id)data;

@end

NS_ASSUME_NONNULL_END

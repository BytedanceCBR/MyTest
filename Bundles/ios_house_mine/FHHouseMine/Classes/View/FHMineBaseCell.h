//
//  FHMineBaseCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMineBaseCell : UITableViewCell

- (void)updateCell:(NSDictionary *)dic;

@property(nonatomic, strong) NSDictionary *dic;

@end

NS_ASSUME_NONNULL_END

//
//  FHSugSubscribeItemCell.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSugSubscribeItemCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *sugLabel;
@property (nonatomic, assign)   BOOL       isValid;

@end

NS_ASSUME_NONNULL_END

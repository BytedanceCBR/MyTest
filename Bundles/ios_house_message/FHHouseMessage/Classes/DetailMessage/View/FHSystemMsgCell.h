//
//  FHSystemMsgCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSystemMsgCell : UITableViewCell

@property(nonatomic, strong) UIView *dateView;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UIView *cardView;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UILabel *descLabel;

@property(nonatomic, strong) UIView *lookDetailView;
@property(nonatomic, strong) UILabel *lookDetailLabel;

@end

NS_ASSUME_NONNULL_END

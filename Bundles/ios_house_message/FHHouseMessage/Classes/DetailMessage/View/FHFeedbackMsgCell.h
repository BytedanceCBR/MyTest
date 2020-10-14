//
//  FHFeedbackMsgCell.h
//  FHHouseMessage
//
//  Created by bytedance on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import "FHHouseMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFeedbackMsgCell : UITableViewCell

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIStackView *buttonStackView;
@property (nonatomic, strong) NSMutableArray *buttonViews;

- (void)updateWithModel:(FHHouseMsgDataItemsModel *)model;

@property (nonatomic, copy) void (^pushURLBlock)(NSString *URLString);

@end

NS_ASSUME_NONNULL_END

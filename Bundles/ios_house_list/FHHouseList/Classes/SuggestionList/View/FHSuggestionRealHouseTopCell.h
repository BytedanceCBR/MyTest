//
//  FHSuggestionRealHouseTopCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/29.
//

#import <UIKit/UIKit.h>
#import <JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionRealHouseTopCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *realHouseLabel;
@property (nonatomic, strong)   UILabel       *falseHouseLabel;
@property (nonatomic, strong)   UIButton      *allWebHouseBtn;
@property (nonatomic, strong)   UIButton      *allFalseHouseBtn;
@property (nonatomic, strong)   UIView        *segementLine;
@property (nonatomic, strong)   UIImageView   *backImageView;

@property (nonatomic, copy) void (^addSubscribeAction)(NSString *subscribeText);

@property (nonatomic, copy) void (^deleteSubscribeAction)(NSString *subscribeId);

- (void)refreshUI:(JSONModel *)data;

@end

NS_ASSUME_NONNULL_END

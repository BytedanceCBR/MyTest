//
//  FHSuggestionSubscribCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/20.
//

#import <UIKit/UIKit.h>
#import <JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kFHSuggestionSubscribeNotificationKey = @"kFHSuggestionSubscribeNotificationKey";

@interface FHSuggestionSubscribCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *subTitleLabel;
@property (nonatomic, strong)   UILabel       *bottomContentLabel;
@property (nonatomic, strong)   UIButton      *subscribeBtn;
@property (nonatomic, strong)   UIImageView   *backImageView;

@property (nonatomic, copy) void (^addSubscribeAction)();

@property (nonatomic, copy) void (^deleteSubscribeAction)(NSString *subscribeId);

- (void)refreshUI:(JSONModel *)data;

@end

NS_ASSUME_NONNULL_END

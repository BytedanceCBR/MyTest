//
//  FHSuggestionSubscribCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/20.
//

#import <UIKit/UIKit.h>
#import "JSONModel.h"
#import <FHHouseBase/FHListBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kFHSuggestionSubscribeNotificationKey = @"kFHSuggestionSubscribeNotificationKey";

@interface FHSuggestionSubscribCell : FHListBaseCell

@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *subTitleLabel;
@property (nonatomic, strong)   UILabel       *bottomContentLabel;
@property (nonatomic, strong)   UIButton      *subscribeBtn;

@property (nonatomic, copy) void (^addSubscribeAction)(NSString *subscribeText);

@property (nonatomic, copy) void (^deleteSubscribeAction)(NSString *subscribeId);

- (void)refreshUI:(JSONModel *)data;

//- (void)updateHeightByIsFirst:(BOOL)isFirst;

@end

NS_ASSUME_NONNULL_END

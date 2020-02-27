//
//  FHSpecialTopicSectionHeaderView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSpecialTopicSectionHeaderView : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *bottomLine;
@property(nonatomic, strong) UIButton *postBtn;

@property(nonatomic, copy) void(^gotoPublishBlock)(void);

@end

NS_ASSUME_NONNULL_END

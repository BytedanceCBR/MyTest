//
//  FHDetailSocialEntranceView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/11/25.
//

#import <UIKit/UIKit.h>
#import "FHHouseNewsSocialModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailNoticeAlertView;

// 新房 填表单之后入口
@interface FHDetailSocialEntranceView : UIView

@property (nonatomic, weak)     FHDetailNoticeAlertView       *parentView;
@property (nonatomic, assign)   CGFloat       messageHeight;
@property (nonatomic, strong)     FHHouseNewsSocialModel       *socialInfo;

- (void)startAnimate;
- (void)stopAnimate;

@end

// 消息
typedef enum : NSUInteger {
    FHDetailSocialMessageDirectionNone,
    FHDetailSocialMessageDirectionLeft,
    FHDetailSocialMessageDirectionRight,
} FHDetailSocialMessageDirection;

@interface FHDetailSocialMessageView : UIView

@property (nonatomic, assign)   CGFloat       messageMaxWidth;
@property (nonatomic, assign)   FHDetailSocialMessageDirection  direction;
@property (nonatomic, strong)   FHDetailCommunityEntryActiveInfoModel       *activeInfo;

@end


NS_ASSUME_NONNULL_END

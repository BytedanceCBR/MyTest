//
//  FHPushMessageTipView.h
//  FHCHousePush
//
//  Created by 张静 on 2019/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHPushMessageTipCompleteType) {
    FHPushMessageTipCompleteTypeCancel,
    FHPushMessageTipCompleteTypeDone,
};

typedef void(^FHPushMessageTipViewComplete)(FHPushMessageTipCompleteType type);


@interface FHPushMessageTipView : UIView

- (instancetype)initAuthorizeTipWithCompleted:(FHPushMessageTipViewComplete)completed;
@end

NS_ASSUME_NONNULL_END

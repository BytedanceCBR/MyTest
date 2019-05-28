//
//  FHPushAuthorizeAlertView.h
//  FHCHousePush
//
//  Created by 张静 on 2019/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHAuthorizeHintCompleteType) {
    FHAuthorizeHintCompleteTypeCancel,
    FHAuthorizeHintCompleteTypeDone,
};

typedef void(^FHPushAuthorizeHintComplete)(FHAuthorizeHintCompleteType type);

@interface FHPushAuthorizeAlertView : UIView

- (instancetype)initAuthorizeHintWithImageName:(NSString *)imageName
                                         title:(NSString *)title
                                       message:(NSString *)message
                               confirmBtnTitle:(NSString *)confirmBtnTitle
                                     completed:(FHPushAuthorizeHintComplete)completed;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END

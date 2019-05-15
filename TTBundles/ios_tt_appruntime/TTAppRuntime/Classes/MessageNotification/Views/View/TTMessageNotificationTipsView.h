//
//  TTMessageNotificationTipsView.h
//  Article
//
//  Created by lizhuoli on 17/3/24.
//
//

#import "SSThemed.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"

#define kTTMessageNotificationTipsViewPadding [TTDeviceUIUtils tt_padding:8]
#define kTTMessageNotificationTipsViewHeight [TTDeviceUIUtils tt_padding:74]
#define kTTMessageNotificationTipsViewBottom (44 + [TTDeviceUIUtils tt_padding:8])

@class TTMessageNotificationTipsModel;
@interface TTMessageNotificationTipsView : UIView

@property (nonatomic, strong, readonly) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong, readonly) SSThemedLabel *nameLabel;
@property (nonatomic, strong, readonly) SSThemedLabel *actionLabel;
@property (nonatomic, strong, readonly) SSThemedLabel *contentLabel;
@property (nonatomic, strong, readonly) SSThemedView  *calloutView;
@property (nonatomic, strong, readonly) NSString      *actionType;
@property (nonatomic, strong, readonly) NSString      *msgID;

- (instancetype)initWithFrame:(CGRect)frame tabCenterX:(CGFloat)centerX; // 箭头指向的Tab的centerX，小于等于0表示无箭头

- (void)configWithModel:(TTMessageNotificationTipsModel *)tipsModel;

@end

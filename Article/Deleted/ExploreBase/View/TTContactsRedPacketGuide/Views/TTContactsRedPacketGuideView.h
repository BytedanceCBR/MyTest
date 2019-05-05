//
//  TTContactsRedPacketGuideView.h
//  Article
//  通讯录红包弹窗基类
//
//  Created by Jiyee Sheng on 7/31/17.
//
//


#import "SSThemed.h"

typedef void (^TTContactsRedPacketGuideViewDidCompleteBlock)();

@interface TTContactsRedPacketGuideView : SSThemedView

@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedButton *closeButton;
@property (nonatomic, strong) SSThemedButton *submitButton;

@property (nonatomic, copy) TTContactsRedPacketGuideViewDidCompleteBlock didAppearBlock;
@property (nonatomic, copy) TTContactsRedPacketGuideViewDidCompleteBlock didCloseBlock;
@property (nonatomic, copy) TTContactsRedPacketGuideViewDidCompleteBlock didSubmitBlock;

/**
 * 打开通讯录红包弹窗，在 Key Window 之上
 */
- (void)showInKeyWindowWithAnimation;

/**
 * 关闭通讯录红包弹窗
 */
- (void)dismissWithAnimation;

@end

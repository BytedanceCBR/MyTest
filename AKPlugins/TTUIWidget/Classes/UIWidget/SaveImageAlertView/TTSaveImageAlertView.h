//
//  TTSaveImageAlertView.h
//  Article
//
//  Created by 王双华 on 15/11/1.
//
//

#import "SSAlertViewBase.h"

@protocol TTSaveImageAlertViewDelegate;

@interface TTSaveImageAlertView : SSAlertViewBase
@property(nonatomic, weak)id<TTSaveImageAlertViewDelegate> delegate;
@property(nonatomic, assign)BOOL hideShareButton;
@property(nonatomic, assign) BOOL showScanQrCodeButton;
- (void)showActivityOnWindow:(UIWindow *)window;

- (void)showOnKeyWindow;// 建议调用次方法显示

@end

@protocol TTSaveImageAlertViewDelegate <NSObject>

@optional
- (void)alertDidShow;
- (void)alertDidHide;
- (void)shareButtonFired:(id)sender;
- (void)scanQrCodeButtonFired:(id)sender;
- (void)saveButtonFired:(id)sender;
- (void)cancelButtonFired:(id)sender;
@end


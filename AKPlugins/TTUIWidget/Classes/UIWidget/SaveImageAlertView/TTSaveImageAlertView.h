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
- (void)showActivityOnWindow:(UIWindow *)window;
@end

@protocol TTSaveImageAlertViewDelegate <NSObject>

@optional
- (void)alertDidShow;
- (void)shareButtonFired:(id)sender;
- (void)saveButtonFired:(id)sender;
- (void)cancelButtonFired:(id)sender;
@end


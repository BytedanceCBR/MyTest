//
//  Alert.h
//
//  Created by 涂耀辉 on 15/3/2.
//  Copyright (c) 2015年 com.ccigmall. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlertSystemCustomViewDelegate <NSObject>

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface AlertSystemCustom : UIView<AlertSystemCustomViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, assign) id<AlertSystemCustomViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(AlertSystemCustom *alertView, int buttonIndex) ;

- (id)init;
/*!
 DEPRECATED: Use the [CustomIOSAlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(AlertSystemCustom *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;



@end

@interface TTImagePickerAlert : NSObject

/**
 *  错误提示
 *
 *  @param title 标题
 *
 *  @return 提示框
 */
+ (void)showWithTitle:(NSString *)title;

+ (void)showWithTitle:(NSString *)title :(NSInteger)howlong;





@end

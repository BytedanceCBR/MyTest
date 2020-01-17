//
//  TTThemedAlertControllerProtocol.h
//  Pods
//
//  Created by pei yun on 2018/6/12.
//

#ifndef TTThemedAlertControllerProtocol_h
#define TTThemedAlertControllerProtocol_h

typedef NS_ENUM(NSInteger, TTThemedAlertControllerType)
{
    TTThemedAlertControllerTypeAlert,
    TTThemedAlertControllerTypeActionSheet
};

typedef NS_ENUM(NSInteger, TTThemedAlertActionType)
{
    TTThemedAlertActionTypeCancel,
    TTThemedAlertActionTypeNormal,
    TTThemedAlertActionTypeDestructive
};

typedef void (^TTThemedAlertActionBlock)(void);
typedef void (^TTThemedAlertTextFieldActionBlock)(UITextField *textField);
typedef void (^TTThemedAlertTextViewActionBlock)(UITextView *textView);

@protocol TTThemedAlertControllerProtocol <NSObject>

- (nonnull instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredType:(TTThemedAlertControllerType)type;

//添加左上角图片
- (void)addBannerImage:(nonnull NSString *)bundleImageName;

//添加按钮
- (void)addActionWithTitle:(nullable NSString *)title actionType:(TTThemedAlertActionType)actionType actionBlock:(nullable TTThemedAlertActionBlock)actionBlock;

//添加textField（可连续添加，显示顺序同添加顺序）
- (void)addTextFieldWithConfigurationHandler:(nullable TTThemedAlertTextFieldActionBlock)actionBlock;

//添加textView（只支持添加一个）
- (void)addTextViewWithConfigurationHandler:(nullable TTThemedAlertTextViewActionBlock)actionBlock;

//添加UI自定义属性
- (void)addTTThemedAlertControllerUIConfig:(nullable NSDictionary *)configuration;

//获取唯一的UITextView
- (nullable UITextView *)uniqueTextView;

//指定presentingViewController并显示alert、actionSheet
- (void)showFrom:(nonnull UIViewController *)viewController animated:(BOOL)animated;

//键盘弹起状态下弹出alertController
- (void)showFrom:(nonnull UIViewController *)viewController animated:(BOOL)animated keyboardPresentingWithFrameTop:(CGFloat)keyboardFrameTop;

//指定presentingViewController并显示popOver（iPad only）
- (void)showFrom:(nonnull UIViewController *)viewController sourceView:(nullable UIView *)sourceView sourceRect:(CGRect)sourceRect sourceBarButton:(nullable UIBarButtonItem *)barButtonItem animated:(BOOL)animated;

@end

#endif /* TTThemedAlertControllerProtocol_h */

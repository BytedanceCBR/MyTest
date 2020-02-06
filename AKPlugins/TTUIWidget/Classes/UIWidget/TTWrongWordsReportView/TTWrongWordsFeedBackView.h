//
//  TTWrongWordsFeedBackView.h
//  TTUIWidget
//
//  Created by chenbb6 on 2019/10/24.
//

#import <UIKit/UIKit.h>
#import "TTWrongWordsReportViewController.h"

#define TTIsInvalidFormatWrongWordArray(array) (!array || ![array isKindOfClass:[NSArray class]] || array.count != 3) || isEmptyString(((NSString *)[array objectAtIndex:1]))

@class TTWrongWordsFeedBackView;
@protocol TTWrongWordsFeedBackViewDelegate <NSObject>

- (void)wrongWordsFeedBackViewDidClickedConfirmButton:(TTWrongWordsFeedBackView *)feedBackView;
- (void)wrongWordsFeedBackViewDidClickedCancelButton:(TTWrongWordsFeedBackView *)feedBackView;
/// 弹窗确认展示
- (void)wrongWordsFeedBackViewDidShowAlert:(TTWrongWordsFeedBackView *)feedBackView;
/**
 * 弹窗不展示：原因：
 * 1.选中字符串长度超过18
 * 2.Kitchen kTTKitchenArticleReportTyposEnabled 下发不展示
 */
- (void)wrongWordsFeedBackViewShowAlertFailed:(TTWrongWordsFeedBackView *)feedBackView;

@end

@interface TTWrongWordsFeedBackView : UIView

@property (nonatomic,assign) BOOL isShowing;
@property (nonatomic,strong) UIWindow *backWindow;
@property (nonatomic,strong) UIWindow *originWindow;
@property (nonatomic,strong) TTWrongWordsReportViewController *rootVC;

@property (nonatomic, weak) id <TTWrongWordsFeedBackViewDelegate> delegate;

/// 展现反馈错别字弹窗
- (void)showAlert;

/// 初始化
- (instancetype)initWithModel:(TTWrongWordsReportModel *)model;

- (void)configWithModel:(TTWrongWordsReportModel *)model;

/// 根据传入进来的view，深搜遍历子view拿到wkwebview，然后注入js获取划词及其上下文
+ (void)getSelectedTextOnWebView:(id)view complete:(void(^)(NSArray *text))complete;

/// 根据传入的nativeView (UITextView)中的Text，以及当前选中的range, 构造划词及其上下文
+ (void)getSelectedTextOnNativeViewText:(NSString *)text currentSelectedRange:(NSRange)range complete:(void(^)(NSArray *result))complete;
@end

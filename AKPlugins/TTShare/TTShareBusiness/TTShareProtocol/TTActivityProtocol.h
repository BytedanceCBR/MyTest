//
//  TTActivityProtocol.h
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/1.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

@protocol TTActivityProtocol;

typedef void(^TTActivityCompletionHandler)(id <TTActivityProtocol> activity, NSError *error, NSString *desc);

@protocol TTActivityProtocol <NSObject>

@required
//注意：需要在判断内容的分享有效性后赋值
@property (nonatomic, strong) id<TTActivityContentItemProtocol> contentItem;

//分享内容的标示key，用于和contentItem的相认匹配
- (NSString *)contentItemType;

//分享type 可用于分享结果中标识分享的类型
- (NSString *)activityType;

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion;

- (NSString *)activityImageName;

- (NSString *)contentTitle;

- (NSString *)shareLabel;

@optional

/*!
 *  @brief  调起分享的入口
 *
 *  @param contentItem              contentItem
 *  @param presentingViewController 有些分享需要present新页面
 *  @param onComplete               分享结果
 */
- (void)shareWithContentItem:(id <TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController onComplete:(TTActivityCompletionHandler)onComplete;

@property (nonatomic, weak) UIViewController *presentingViewController;

@end

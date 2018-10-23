//
//  TTAuthorizeBaseObj.h
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import <Foundation/Foundation.h>
#import "TTAuthorizeModel.h"
#import "TTThemedAlertController.h"
#import "TTAuthorizeHintView.h"

@interface TTAuthorizeBaseObj : NSObject

@property(nonatomic,strong)TTAuthorizeModel *authorizeModel;

- (instancetype)initWithAuthorizeModel:(TTAuthorizeModel *)model;

/**
 *  更新当前类型弹窗显示时间
 */
- (void)updateShowTime;

- (TTThemedAlertController *)showMainTitle:(NSString *)title
                                   message:(NSString *)message
                                 imageName:(NSString *)imageName
                         cancelButtonTitle:(NSString *)cancelButtonTitle
                             okButtonTitle:(NSString *)okButtonTitle
                               cancelBlock:(TTThemedAlertActionBlock)cancelBlock
                                   okBlock:(TTThemedAlertActionBlock)okBlock;

- (TTAuthorizeHintView *)
       authorizeHintViewWithTitle:(NSString *)title
                          message:(NSString *)message
                        imageName:(NSString*)imageName
                    okButtonTitle:(NSString* )okButtonTitle
                          okBlock:(void (^)())okBlock
                      cancelBlock:(void (^)())cancelBlock;
@end

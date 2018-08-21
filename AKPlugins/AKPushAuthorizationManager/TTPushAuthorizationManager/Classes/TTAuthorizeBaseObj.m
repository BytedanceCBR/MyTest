//
//  TTAuthorizeBaseObj.m
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizeBaseObj.h"
#import "TTUIResponderHelper.h"

@implementation TTAuthorizeBaseObj

- (instancetype)initWithAuthorizeModel:(TTAuthorizeModel *)model {
    self = [self init];
    if (self) {
        self.authorizeModel = model;
    }
    return self;
}

- (void)updateShowTime {
    //need override
}

- (TTThemedAlertController *)showMainTitle:(NSString *)title
                                   message:(NSString *)message
                                 imageName:(NSString *)imageName
                         cancelButtonTitle:(NSString *)cancelButtonTitle
                             okButtonTitle:(NSString *)okButtonTitle
                               cancelBlock:(TTThemedAlertActionBlock)cancelBlock
                                   okBlock:(TTThemedAlertActionBlock)okBlock
{
    TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:title message:message preferredType:TTThemedAlertControllerTypeAlert];
    [alertController addActionWithTitle:cancelButtonTitle actionType:TTThemedAlertActionTypeCancel actionBlock:cancelBlock];
    [alertController addActionWithTitle:okButtonTitle actionType:TTThemedAlertActionTypeNormal actionBlock:okBlock];
    [alertController addTTThemedAlertControllerUIConfig:@{TTThemedTitleFontKey:@(18.0f),
                                                          TTThemedSubTitleFontKey:@(12.0f)}];
    [alertController addBannerImage:imageName];
    [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    return alertController;
}

- (TTAuthorizeHintView *)
        authorizeHintViewWithTitle:(NSString *)title
                           message:(NSString *)message
                         imageName:(NSString*)imageName
                     okButtonTitle:(NSString* )okButtonTitle
                           okBlock:(void (^)())okBlock
                       cancelBlock:(void (^)())cancelBlock{
    return [[TTAuthorizeHintView alloc]initAuthorizeHintWithImageName:imageName title:title message:message confirmBtnTitle:okButtonTitle animated:YES completed:^(TTAuthorizeHintCompleteType type) {
        if(type == TTAuthorizeHintCompleteTypeDone){
            if(okBlock){
                okBlock();
            }

        }
        else{
            if(cancelBlock){
                cancelBlock();
            }
        }
    }];
}

@end

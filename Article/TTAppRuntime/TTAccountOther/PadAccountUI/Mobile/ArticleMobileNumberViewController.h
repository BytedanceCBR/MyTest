//
//  ArticleMobileNumberViewController.h
//  Article
//
//  Created by SunJiangting on 14-7-9.
//
//

#import "ArticleMobileViewController.h"



typedef NS_ENUM(NSInteger, ArticleMobileNumberUsingType) {
    ArticleMobileNumberUsingTypeRegister,       // 注册
    ArticleMobileNumberUsingTypeRetrieve,       // 找回密码
    ArticleMobileNumberUsingTypeBind,           // 绑定手机号
};
/// 填写手机号，并且发送验证码的由于UI一致，所以都使用同一个界面
@interface ArticleMobileNumberViewController : ArticleMobileViewController

- (instancetype) initWithMobileNumberUsingType:(ArticleMobileNumberUsingType) usingType;

@property (nonatomic, readonly) ArticleMobileNumberUsingType usingType;
@property (nonatomic, strong, readonly) SSThemedTextField    *mobileField;

@end

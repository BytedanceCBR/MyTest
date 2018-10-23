//
//  TTRLogin.h
//  Article
//
//  Created by muhuai on 2017/5/21.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRLogin : TTRDynamicPlugin

TTR_EXPORT_HANDLER(login)

TTR_EXPORT_HANDLER(isLogin)
@end

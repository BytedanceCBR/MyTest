//
//  TTIconLabel+VerifyIcon.h
//  Article
//
//  Created by lizhuoli on 17/1/24.
//
//

#import "TTIconLabel.h"
#import "TTVerifyIconHelper.h"

@interface TTIconLabel (VerifyIcon)

/** 根据认证信息，添加认证图标到图标组的首位，需要传入user_auth_info */
- (void)addIconWithVerifyInfo:(NSString *)verifyInfo;

@end

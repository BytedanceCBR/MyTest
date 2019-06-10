//
//  TTRSecurity.h
//  Article
//
//  Created by muhuai on 2017/9/20.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRSecurity : TTRDynamicPlugin

TTR_EXPORT_HANDLER(encrypt)
TTR_EXPORT_HANDLER(decrypt)

@end

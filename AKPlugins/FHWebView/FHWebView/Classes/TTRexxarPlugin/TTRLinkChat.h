//
//  TTRLinkChat.h
//  FHWebView
//
//  Created by wangzhizhou on 2020/10/25.
//

#import <TTRexxar/TTRDynamicPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTRLinkChat : TTRDynamicPlugin
TTR_EXPORT_HANDLER(getUserPermission);
TTR_EXPORT_HANDLER(openPhotoLibrary);
TTR_EXPORT_HANDLER(linkchatUploadVideo);
@end

NS_ASSUME_NONNULL_END

//
//  TTRShare.h
//  Article
//
//  Created by muhuai on 2017/5/21.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRShare : TTRDynamicPlugin

TTR_EXPORT_HANDLER(share)
TTR_EXPORT_HANDLER(sharePGC)
TTR_EXPORT_HANDLER(sharePanel)
TTR_EXPORT_HANDLER(systemShare)
@end

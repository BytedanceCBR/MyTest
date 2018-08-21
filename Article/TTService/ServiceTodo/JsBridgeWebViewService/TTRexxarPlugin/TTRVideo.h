//
//  TTRVideo.h
//  Article
//
//  Created by muhuai on 2017/5/18.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRVideo : TTRDynamicPlugin

TTR_EXPORT_HANDLER(playNativeVideo)
TTR_EXPORT_HANDLER(playVideo)
TTR_EXPORT_HANDLER(pauseVideo)
@end

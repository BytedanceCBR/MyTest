//
//  TTRChannel.h
//  Article
//
//  Created by muhuai on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRChannel : TTRDynamicPlugin

TTR_EXPORT_HANDLER(addChannel)
TTR_EXPORT_HANDLER(getSubScribedChannelList)
@end

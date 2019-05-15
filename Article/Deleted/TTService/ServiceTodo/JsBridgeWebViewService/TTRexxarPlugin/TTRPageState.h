//
//  TTRPageState.h
//  Article
//
//  Created by muhuai on 2017/5/18.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRPageState : TTRDynamicPlugin

TTR_EXPORT_HANDLER(isVisible)
TTR_EXPORT_HANDLER(pageStateChange)
TTR_EXPORT_HANDLER(addEventListener)
@end

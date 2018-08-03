//
//  TTRUIWidget.h
//  Article
//
//  Created by muhuai on 2017/6/13.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRUIWidget : TTRDynamicPlugin

TTR_EXPORT_HANDLER(toast)
TTR_EXPORT_HANDLER(alert)

@end

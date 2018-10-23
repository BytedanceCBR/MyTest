//
//  TTRShortVideo.h
//  Article
//
//  Created by xushuangqing on 10/12/2017.
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

extern NSString * const TTWebviewRedpackIntroClickedNotification;

@interface TTRShortVideo : TTRDynamicPlugin

TTR_EXPORT_HANDLER(getRedPackIntro);
TTR_EXPORT_HANDLER(redpackWebIntroClicked);

@end

//
//  TTContactsRedPacketGuideViewHelper.h
//  Article
//  同步通讯录红包弹窗
//
//  Created by Jiyee Sheng on 7/31/17.
//
//

#import <Foundation/Foundation.h>
#import "TTGuideDispatchManager.h"

@interface TTContactsRedPacketGuideViewHelper : NSObject <TTGuideProtocol>

/**
 * 此次应用启动之后是否弹出过通讯录红包弹窗
 * @return
 */
+ (BOOL)hasGuideViewDisplayedAfterLaunching;

- (void)showWithContext:(id)context;

@end

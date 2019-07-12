//
//  TTActionSheetTextController.h
//  Article
//
//  Created by zhaoqin on 8/30/16.
//
//

#import <UIKit/UIKit.h>
#import "TTActionSheetConst.h"

// Copy from TTActionSheetTextController
@interface TTFeedDislikeReportTextController : UIViewController
/// cancel 对应的 message 为 nil
@property (nonatomic, copy) void (^inputFinished)(NSString *message);
/// cancel 对应的 message 为 nil
+ (void)triggerTextReportProcessCompleted:(void (^)(NSString *message))completed;
@end

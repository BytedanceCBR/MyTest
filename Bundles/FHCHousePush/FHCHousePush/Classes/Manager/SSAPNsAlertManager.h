//
//  SSAPNsAlertManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-12-26.
//
//

#import <Foundation/Foundation.h>



#define kSSAPNsAlertManagerTitleKey         @"kSSAPNsAlertManagerTitleKey"
#define kSSAPNsAlertManagerSchemaKey        @"kSSAPNsAlertManagerSchemaKey"
#define kSSAPNsAlertManagerOldApnsTypeIDKey @"kSSAPNsAlertManagerOldApnsTypeIDKey"  //老的推送方式， 如果有id， 则是推送到详情页
#define kSSAPNsAlertManagerRidKey           @"kSSAPNsAlertManagerRidKey"
#define kSSAPNsAlertManagerImportanceKey    @"kSSAPNsAlertManagerImportanceKey"     // 紧急程度
#define kSSAPNsAlertManagerAttachmentKey    @"kSSAPNsAlertManagerAttachmentKey"     // 附件


@interface SSAPNsAlertManager : NSObject

+ (SSAPNsAlertManager *)sharedManager;

- (void)showRemoteNotificationAlert:(NSDictionary *)dict;

+ (void)setCouldShowAPNsAlert:(BOOL)could;

//打开状态是否弹窗推送消息
+ (void)setCouldShowActivePushAlert:(BOOL)could;

@end

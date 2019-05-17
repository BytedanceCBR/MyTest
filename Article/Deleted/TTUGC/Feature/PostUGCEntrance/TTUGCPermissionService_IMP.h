//
//  TTUGCPermissionService_IMP.h
//  Article
//
//  Created by 王霖 on 16/10/23.
//
//

#import <Foundation/Foundation.h>
#import <TTServiceKit/TTServiceCenter.h>
#import <TTServiceProtocols/TTUGCPermissionService.h>


extern NSString * _Nonnull const kTTPostUGCTypeTextAndImage;
extern NSString * _Nonnull const kTTPostUGCTypeImage;
extern NSString * _Nonnull const kTTPostUGCTypeText;
extern NSString * _Nonnull const kTTPostUGCTypeUGCVideo;
extern NSString * _Nonnull const kTTPostUGCTypeShortVideo;
extern NSString * _Nonnull const kTTPostUGCTypeWenda;


@interface TTUGCPermissionService_IMP : NSObject <TTUGCPermissionService, TTService>

+ (nullable instancetype)sharedInstance;

@end

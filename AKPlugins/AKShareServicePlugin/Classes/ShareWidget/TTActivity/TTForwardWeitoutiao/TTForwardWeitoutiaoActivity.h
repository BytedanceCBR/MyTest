//
//  TTForwardWeitoutiaoActivity.h
//  Article
//
//  Created by 王霖 on 17/4/24.
//
//
#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTForwardWeitoutiaoContentItem.h"
#import "TTActivityPanelDefine.h"

// TTWeitoutiaoRepostIconDownloadManager不在库里，直接实现这个Protocol就好
@protocol TTWeitoutiaoRepostIconDownloadManagerInterface <NSObject>

+ (instancetype)sharedManager;
- (UIImage *)getWeitoutiaoRepostDayIcon;
- (UIImage *)getWeitoutiaoRepostNightIcon;

@end

extern NSString * const TTActivityTypeForwardWeitoutiao;
@interface TTForwardWeitoutiaoActivity : NSObject <TTActivityProtocol, TTActivityPanelActivityProtocol>

@property (nonatomic, strong) TTForwardWeitoutiaoContentItem * contentItem;

@end

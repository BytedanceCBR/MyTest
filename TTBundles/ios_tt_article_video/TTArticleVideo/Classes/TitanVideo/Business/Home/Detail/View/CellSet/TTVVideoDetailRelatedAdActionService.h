//
//  TTVVideoDetailRelatedAdActionService.h
//  Article
//
//  Created by pei yun on 2017/6/4.
//
//

#import <Foundation/Foundation.h>
#import "TTVDetailRelatedADInfoDataProtocol.h"
 #import "VideoInformation.pbobjc.h"

@interface TTVVideoDetailRelatedAdActionService : NSObject

- (void)trackRelateAdShow:(id<TTVDetailRelatedADInfoDataProtocol> )article uniqueIDStr:(NSString *)uniqueIDStr;
- (void)video_relateHandleAction:(id<TTVDetailRelatedADInfoDataProtocol> )article uniqueIDStr:(NSString *)uniqueIDStr;
- (void)videoAdCell_didSelect:(id<TTVDetailRelatedADInfoDataProtocol> )article uniqueIDStr:(NSString *)uniqueIDStr;
+ (void)trackRealTimeAd:(TTVRelatedVideoAD*)ad;
@end

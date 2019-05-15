//
//  TTVPartnerVideo+TTVVideoDetailNatantViewDataProtocolSupport.h
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import <TTVideoService/VideoInformation.pbobjc.h>
#import "TTVVideoDetailNatantVideoBannerDataProtocol.h"
#import "TTVPartnerVideo+TTVComputedProperties.h"

@interface TTVPartnerVideo (TTVVideoDetailNatantViewDataProtocolSupport) <TTVVideoDetailNatantVideoBannerDataProtocol>

@property (nonatomic, copy) NSString *appName;

@end

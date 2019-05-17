//
//  TTVVideoInformationResponse+TTVVideoDetailNatantViewDataProtocolSupport.h
//  Article
//
//  Created by pei yun on 2017/5/24.
//
//

#import <TTVideoService/VideoInformation.pbobjc.h>
#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"
#import "TTVVideoDetailNatantADView.h"
#import "TTVVideoDetailTextlinkADView.h"
#import "TTVVideoDetailNatantTagsView.h"

@interface TTVVideoInformationResponse (TTVVideoDetailNatantViewDataProtocolSupport) <TTVVideoDetailNatantADViewDataProtocol, TTVVideoDetailTextlinkADViewDataProtocol, TTVVideoDetailNatantTagsViewDataProtocol>

@end

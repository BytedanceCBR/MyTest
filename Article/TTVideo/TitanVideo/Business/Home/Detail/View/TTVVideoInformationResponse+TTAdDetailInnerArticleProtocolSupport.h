//
//  TTVVideoInformationResponse+TTAdDetailInnerArticleProtocolSupport.h
//  Article
//
//  Created by pei yun on 2017/7/25.
//
//

#import <TTVideoService/PBModelHeader.h>
#import "TTAdDetailInnerArticleProtocol.h"
#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"

@interface TTVVideoInformationResponse (TTAdDetailInnerArticleProtocolSupport) <TTAdDetailInnerArticleProtocol>

@property(nonatomic, strong, readonly) NSString *mediaID;

@end

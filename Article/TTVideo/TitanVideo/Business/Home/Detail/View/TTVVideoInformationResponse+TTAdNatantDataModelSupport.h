//
//  TTVVideoInformationResponse+TTAdNatantDataModelSupport.h
//  Article
//
//  Created by pei yun on 2017/7/25.
//
//

#import <TTVideoService/PBModelHeader.h>
#import "TTAdDetailViewDefine.h"

@interface TTVVideoInformationResponse (TTAdNatantDataModelSupport) <TTAdNatantDataModel>

- (NSDictionary *)adData;

@end

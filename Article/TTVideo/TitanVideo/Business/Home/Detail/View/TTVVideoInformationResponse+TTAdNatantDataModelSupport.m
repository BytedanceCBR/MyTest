//
//  TTVVideoInformationResponse+TTAdNatantDataModelSupport.m
//  Article
//
//  Created by pei yun on 2017/7/25.
//
//

#import "TTVVideoInformationResponse+TTAdNatantDataModelSupport.h"
#import "TTVVideoInformationResponse+TTVComputedProperties.h"

@implementation TTVVideoInformationResponse (TTAdNatantDataModelSupport)

- (NSDictionary *)adData
{
    return self.orderedInfoDict[@"ad"];
}

- (id)adNatantDataModel:(NSString *)key4Data
{
    return self.orderedInfoDict[@"ad"];
}

@end

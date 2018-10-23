//
//  TTVVideoInformationResponse+TTVComputedProperties.h
//  Article
//
//  Created by pei yun on 2017/6/8.
//
//

#import <TTVideoService/VideoInformation.pbobjc.h>
#import "TTVArticleProtocol.h"

@class TTVDetailCarCard;
@interface TTVVideoInformationResponse (TTVComputedProperties)

@property (nonatomic, strong, readonly) NSDictionary *orderedInfoDict;
@property (nonatomic, strong) id<TTVArticleProtocol> articleMiddleman;
@property (nonatomic, assign) NSTimeInterval ttv_requestTime;
@property (nonatomic, strong, readonly) NSArray<TTVDetailCarCard *> *carCardArray;

@end

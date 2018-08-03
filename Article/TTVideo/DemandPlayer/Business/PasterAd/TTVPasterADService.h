//
//  TTVPasterADService.h
//  Article
//
//  Created by lijun.thinker on 2017/3/22.
//
//

#import <Foundation/Foundation.h>
#import "TTVPasterADURLRequestInfo.h"

typedef void(^fetchPasterADInfoCompletion)(id response,NSError *error);
@interface TTVPasterADService : NSObject

- (void)fetchPasterADInfoWithRequestInfo:(TTVPasterADURLRequestInfo *)requestInfo completion:(fetchPasterADInfoCompletion)completion;

@end


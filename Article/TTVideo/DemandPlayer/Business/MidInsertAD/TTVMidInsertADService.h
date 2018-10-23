//
//  TTVMidInsertADService.h
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import <Foundation/Foundation.h>

typedef void(^fetchMidInsertADInfoCompletion)(id response,NSError *error);

@interface TTVMidInsertADService : NSObject

- (void)fetchMidInsertADInfoWithRequestInfo:(NSDictionary *)requestInfo completion:(fetchMidInsertADInfoCompletion)completion;

@end

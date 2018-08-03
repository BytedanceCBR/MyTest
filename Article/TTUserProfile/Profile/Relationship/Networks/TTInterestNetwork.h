//
//  TTInterestNetwork.h
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import <Foundation/Foundation.h>
#import "TTInterestRequestModel.h"
#import "TTInterestResponseModel.h"


@interface TTInterestNetwork : NSObject
+ (void)getInterestListWithUserID:(NSString *)uid Offset:(NSNumber *)offset completion:(void (^)(TTInterestResponseModel *aModel, NSError *error))completion;
@end

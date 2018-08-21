//
//  SSADFetchInfoManager.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-13.
//
//

#import <Foundation/Foundation.h>

@interface SSADFetchInfoManager : NSObject

+ (instancetype)shareInstance;

- (void)startFetchADInfoWithExtraParameters:(NSDictionary *)extra;

@end

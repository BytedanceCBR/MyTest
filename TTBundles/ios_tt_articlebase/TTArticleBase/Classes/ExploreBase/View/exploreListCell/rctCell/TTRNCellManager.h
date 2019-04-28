//
//  TTRNCellManager.h
//  Article
//
//  Created by yangning on 2017/9/5.
//
//

#import <Foundation/Foundation.h>

@class RNData;
@interface TTRNCellManager : NSObject

+ (instancetype)sharedManager;

- (void)startGetDataFromCellData:(RNData *)cellData
                      completion:(void(^)(RNData *cellData, NSDictionary *data, NSError *error))completion;

@end

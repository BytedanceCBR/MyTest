//
//  TTRNCellManager.m
//  Article
//
//  Created by yangning on 2017/9/5.
//
//

#import "TTRNCellManager.h"
#import "RNData.h"
#import "TTNetworkManager.h"

@implementation TTRNCellManager

+ (instancetype)sharedManager
{
    static TTRNCellManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTRNCellManager alloc] init];
    });
    return _sharedInstance;
}

- (void)startGetDataFromCellData:(RNData *)cellData
                      completion:(void(^)(RNData *cellData, NSDictionary *data, NSError *error))completion
{
    // 请求最新wap模板数据
    NSString *dataUrl = cellData.dataUrl;
    
    if (isEmptyString(dataUrl)) {
        NSError *error = [NSError errorWithDomain:@"error" code:0 userInfo:@{ NSLocalizedDescriptionKey: @"Data url is empty." }];
        if (completion) {
            completion(cellData, nil, error);
        }
        return;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:dataUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *err, id jsonObj) {
        NSError *error;
        NSDictionary *data;
        //NSLog(@"err: %@ result: %@", err, result);
        if (!err) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:jsonObj];
            [mDict setValue:@"success" forKey:@"message"];
            [cellData updateWithDataContentObj:mDict];
        } else {
            cellData.lastUpdateTime = [NSDate date];
        }
        
        if (completion) {
            completion(cellData, data, error);
        }
    }];
}

@end

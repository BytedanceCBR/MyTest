//
//  TTVFeedListWebCellService.h
//  Article
//
//  Created by pei yun on 2017/4/21.
//
//

#import <Foundation/Foundation.h>

@class TTVTopWebCell;
@interface TTVFeedListWebCellService : NSObject

- (void)startGetTemplateFromWapData:(TTVTopWebCell *)wapData completion:(void(^)(TTVTopWebCell *wapData, NSString *htmlStr, NSError *error))completion;
- (void)startGetDataFromWapData:(TTVTopWebCell *)wapData completion:(void(^)(TTVTopWebCell *wapData, NSDictionary *data, NSError *error))completion;

@end

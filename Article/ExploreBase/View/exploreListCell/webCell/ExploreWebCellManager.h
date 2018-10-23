//
//  ExploreWebCellManager.h
//  Article
//
//  Created by Chen Hong on 15/3/4.
//
//

#import <Foundation/Foundation.h>
#import "WapData.h"

@interface ExploreWebCellManager : NSObject

+ (instancetype)sharedManager;

- (void)startGetTemplateFromWapData:(WapData *)wapData completion:(void(^)(WapData *wapData, NSString *htmlStr, NSError *error))completion;

- (void)startGetDataFromWapData:(WapData *)wapData completion:(void(^)(WapData *wapData, NSDictionary *data, NSError *error))completion;


/**
 *  wapCell模板更新时，coredata置空templateContent不成功，找到原因前先用一个set来保存需要重新请求模板的wapCell
 */
//- (void)addTemplateChangedForID:(id)uniqueID;
//
//- (void)removeTemplateChangedForID:(id)uniqueID;
//
//- (BOOL)hasTemplateChangedForID:(id)uniqueID;

@end

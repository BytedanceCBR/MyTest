//
//  TTUGCBDGIFLoadManager.h
//  Article
//
//  Created by jinqiushi on 2018/1/9.
//

#import <Foundation/Foundation.h>
#import "FRImageInfoModel.h"

@interface TTUGCBDGIFLoadManager : NSObject

+ (instancetype)sharedManager;

/**
 * 目前仅支持主线程调用
 */
- (void)startDownloadGifImageModel:(FRImageInfoModel *)gifImageModel;

@end

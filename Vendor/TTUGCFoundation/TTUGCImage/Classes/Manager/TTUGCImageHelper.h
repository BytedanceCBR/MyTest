//
//  TTUGCImageHelper.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2019/2/27.
//

#import <Foundation/Foundation.h>
#import "FRImageInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kTTUGCImageSource;

@interface TTUGCImageHelper : NSObject

+ (NSString *)imageKeyForImageModel:(FRImageInfoModel *)imageModel;

@end

@interface NSURL (TTUGCSource)

@property (nonatomic, strong) NSString *ttugc_source;

@end

@interface NSString (TTUGCFeedImage)

- (NSURL *)ttugc_feedImageURL;

@end


NS_ASSUME_NONNULL_END

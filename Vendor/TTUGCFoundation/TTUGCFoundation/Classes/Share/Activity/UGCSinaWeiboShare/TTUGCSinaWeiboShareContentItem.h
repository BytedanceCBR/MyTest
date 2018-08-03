//
//  TTUGCSinaWeiboShareContentItem.h
//  Article
//
//  Created by 王霖 on 17/2/28.
//
//

#import <Foundation/Foundation.h>
#import <TTActivityContentItemProtocol.h>
#import "TTUGCShareUtil.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TTActivityContentItemTypeUGCSinaWeiboShare;

@interface TTUGCSinaWeiboShareContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy, readonly) NSString * uniqueID;
@property (nonatomic, copy, readonly, nullable) NSString * shareText;
@property (nonatomic, assign, readonly) TTUGCShareSourceType shareSourceType;

- (instancetype)initWithUniqueID:(NSString *)uniqueID
                       shareText:(nullable NSString *)shareText
                 shareSourceType:(TTUGCShareSourceType)shareSourceType NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

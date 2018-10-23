//
//  TTUGCSinaWeiboShareInputViewController.h
//  Article
//
//  Created by 王霖 on 17/2/28.
//
//

#import <SSViewControllerBase.h>
#import "TTUGCShareUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTUGCSinaWeiboShareInputViewController : SSViewControllerBase

- (instancetype)initWithUniqueID:(NSString *)uniqueID
                       shareText:(nullable NSString *)shareText
                 shareSourceType:(TTUGCShareSourceType)shareSourceType
                      completion:(void(^ _Nullable)( NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

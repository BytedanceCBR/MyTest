//
//  FHMyMAAnnotation.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/12.
//

#import <MAMapKit/MAMapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMyMAAnnotation : MAPointAnnotation
@property (nonnull, strong) NSString *type;
@end

NS_ASSUME_NONNULL_END

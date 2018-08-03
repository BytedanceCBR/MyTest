//
//  TTThreadRateOperateActivity.h
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import <Foundation/Foundation.h>
#import <TTActivityProtocol.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TTActivityTypeThreadRateOperate;

@interface TTThreadRateOperateActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong, nullable) id<TTActivityContentItemProtocol> contentItem;

@end

NS_ASSUME_NONNULL_END

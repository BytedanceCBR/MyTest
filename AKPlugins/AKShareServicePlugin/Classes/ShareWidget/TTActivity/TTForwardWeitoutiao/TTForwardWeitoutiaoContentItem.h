//
//  TTForwardWeitoutiaoContentItem.h
//  Article
//
//  Created by 王霖 on 17/4/24.
//
//
#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;


@interface TTForwardWeitoutiaoContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy) TTCustomAction customAction;
@property (nonatomic, copy) NSDictionary *repostParams;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

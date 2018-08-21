//
//  TTDirectForwardWeitoutiaoContentItem.h
//  TTShareService
//
//  Created by jinqiushi on 2018/1/17.
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeDirectForwardWeitoutiao;


@interface TTDirectForwardWeitoutiaoContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy) TTCustomAction customAction;
@property (nonatomic, copy) NSDictionary *repostParams;

@end

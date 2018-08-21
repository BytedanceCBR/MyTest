//
//  TTDirectForwardWeitoutiaoActivity.h
//  TTShareService
//
//  Created by jinqiushi on 2018/1/17.
//

#import <Foundation/Foundation.h>
#import "TTDirectForwardWeitoutiaoContentItem.h"
#import "TTActivityProtocol.h"

extern NSString * const TTActivityTypeDirectForwardWeitoutiao;


@interface TTDirectForwardWeitoutiaoActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTDirectForwardWeitoutiaoContentItem * contentItem;

@end

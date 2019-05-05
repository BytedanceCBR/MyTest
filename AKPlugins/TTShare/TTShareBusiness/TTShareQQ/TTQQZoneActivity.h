//
//  TTQQZoneActivity.h
//  Pods
//
//  Created by 张 延晋 on 16/06/03.
//
//

#import "TTActivityProtocol.h"
#import "TTQQZoneContentItem.h"

extern NSString * const TTActivityTypePostToQQZone;

@interface TTQQZoneActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTQQZoneContentItem *contentItem;

@end

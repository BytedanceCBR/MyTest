//
//  TTQQFriendActivity.h
//  Pods
//
//  Created by 张 延晋 on 16/06/03.
//
//

#import "TTActivityProtocol.h"
#import "TTQQFriendContentItem.h"

extern NSString * const TTActivityTypePostToQQFriend;

@interface TTQQFriendActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTQQFriendContentItem *contentItem;

@end

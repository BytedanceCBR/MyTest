//
//  TTFriendRelationFollowingNotifier.m
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "TTFriendRelationFollowingNotifier.h"

@implementation TTFriendRelationFollowingNotifier


- (void)notifyAllObserversValue:(NSNumber *)value {
    id keyObject = nil;
    NSEnumerator *propertyEnumerator = [self.propertyNotifyMap keyEnumerator];
    while (keyObject = [propertyEnumerator nextObject]) {
        [keyObject setValue:value forKeyPath:[self.propertyNotifyMap objectForKey:keyObject]];
    }
    
    NSEnumerator *selectorEnumerator = [self.selectorNotifyTable objectEnumerator];
    id selectorObject = nil;
    while (selectorObject = [selectorEnumerator nextObject]) {
        if ([selectorObject respondsToSelector:@selector(friendRelationChangedWithValue:)]) {
            [selectorObject friendRelationChangedWithValue:value];
        }
    }
}


@end

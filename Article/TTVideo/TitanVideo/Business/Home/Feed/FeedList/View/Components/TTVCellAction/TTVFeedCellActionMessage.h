//
//  TTVFeedCellActionMessage.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import <Foundation/Foundation.h>
#import "ExploreItemActionManager.h"
#import "TTMessageCenter.h"

@class TTVFeedListItem;
@protocol TTVFeedCellActionMessage <NSObject>
@optional
- (void)message_dislikeWithCellEntity:(TTVFeedListItem *)cellEntity filterWords:(NSArray *)filterWords dislikeAnchorFrame:(CGRect)dislikeAnchorFrame dislikeSource:(TTDislikeSourceType)dislikeSourceType;
@end


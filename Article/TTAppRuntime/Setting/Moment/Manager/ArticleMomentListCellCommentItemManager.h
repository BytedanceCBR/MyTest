//
//  ArticleMomentListCellCommentItemManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-23.
//
//

#import <Foundation/Foundation.h>
#import "ArticleMomentListCellCommentItem.h"

@interface ArticleMomentListCellCommentItemManager : NSObject

+ (ArticleMomentListCellCommentItemManager *)shareManager;

- (ArticleMomentListCellCommentItem *)dequeueReusableCommentItem;
- (void)queueReusableCommentItem:(ArticleMomentListCellCommentItem *)item;

@end

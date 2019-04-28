//
//  TTVFeedUserOpViewSyncMessage.h
//  Article
//
//  Created by pei yun on 2017/4/24.
//
//

#ifndef TTVFeedUserOpViewSyncMessage_h
#define TTVFeedUserOpViewSyncMessage_h

@class TTVFeedListItem;
@protocol TTVFeedUserOpViewSyncMessage <NSObject>

@optional
//利用KVO来更新UI，不再reloadRowsAtIndexPath
- (void)ttv_message_feedListItemChanged:(TTVFeedListItem *)feedListItem;

//配合关注触发的begainUpdate／endUpdate 动画展示最后一个cell
- (void)ttv_message_feedListItemExpendOrCollapseRecommendView:(TTVFeedListItem *)feedListItem isExpend:(BOOL) isExpend;

@end

#endif /* TTVFeedUserOpViewSyncMessage_h */

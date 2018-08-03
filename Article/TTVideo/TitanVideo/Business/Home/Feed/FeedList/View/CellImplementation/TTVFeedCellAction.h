//
//  TTVFeedCellAction.h
//  Article
//
//  Created by panxiang on 2017/4/26.
//
//

#import <Foundation/Foundation.h>
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTVFeedCellForRowContext.h"

@class TTVFeedListItem;
@class TTVFeedListCell;
@protocol TTVFeedCellAction <NSObject>

//一般情况下cell和item是一一对应的，但如果在reloadRows的时候，可能不会，从而存在cell.item=item，而item.cell=another cell的情况
- (void)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context;
- (void)willDisplayItem:(TTVFeedListItem *)item context:(TTVFeedCellWillDisplayContext *)context;
- (void)endDisplayCell:(TTVFeedListCell *)item context:(TTVFeedCellEndDisplayContext *)context;
- (void)cellForRowItem:(TTVFeedListItem *)item context:(TTVFeedCellForRowContext *)context;
//...... 其他事件，如不同的点击使用不同的打点

@end

@interface TTVFeedCellAction : NSObject<TTVFeedCellAction>

@end

@interface TTVFeedCellAdAppAction : TTVFeedCellAction

@end

@interface TTVFeedCellAdPhoneAction : TTVFeedCellAction

@end

@interface TTVFeedCellAdWebAction : TTVFeedCellAction

@end

@interface TTVFeedCellAdFormAction : TTVFeedCellAction

@end

@interface TTVFeedCellAdCounselAction : TTVFeedCellAction

@end

@interface TTVFeedCellAdNormalAction : TTVFeedCellAction

@end

@interface TTVFeedCellVideoAction : TTVFeedCellAction

@end


/**
 顶部web cell
 */
@interface TTVFeedCellWebAction : TTVFeedCellAction

@end




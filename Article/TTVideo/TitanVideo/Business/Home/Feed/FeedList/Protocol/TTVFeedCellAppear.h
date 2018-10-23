//
//  TTVFeedCellAppear.h
//  Article
//
//  Created by panxiang on 2017/4/25.
//
//

#import <Foundation/Foundation.h>

//#import "TTVFeedCellSelectContext.h"
//#import "TTVFeedCellWillDisplayContext.h"
//#import "TTVFeedCellEndDisplayContext.h"
//#import "TTVFeedCellForRowContext.h"
#import "TTVideoFeedListEnum.h"
@class TTVFeedCellSelectContext;
@class TTVFeedCellEndDisplayContext;
@class TTVFeedCellWillDisplayContext;
@class TTVFeedCellForRowContext;


@protocol TTVFeedCellAppear <NSObject>
@optional

/**
 切换category,进入详情页后,当前visibleCells 消失调用
 */
- (void)cellInListWillDisappear:(TTCellDisappearType)disappearType;

/**
 table的delagete
 */
- (void)didSelectWithContext:(TTVFeedCellSelectContext *)context;
- (void)willDisplayWithContext:(TTVFeedCellWillDisplayContext *)context;
- (void)endDisplayWithContext:(TTVFeedCellEndDisplayContext *)context;
- (void)cellForRowContext:(TTVFeedCellForRowContext *)context;

//透传controller的调用
- (void)viewWillAppear;
- (void)viewWillDisappear;

@end



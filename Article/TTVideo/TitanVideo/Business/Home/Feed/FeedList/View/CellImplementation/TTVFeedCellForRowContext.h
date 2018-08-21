//
//  TTVFeedCellForRowContext.h
//  Article
//
//  Created by panxiang on 2017/4/24.
//
//

#import <Foundation/Foundation.h>
#import "Enum.pbobjc.h"

@class TTVFeedListItem;
@class TTADEventTrackerEntity;
@interface TTVFeedCellForRowContext : NSObject
@property (nonatomic, assign) BOOL isDisplayView;
@end

#pragma mark cellSelect默认处理
@interface TTVFeedCellForRowHandler : NSObject
+ (void)defaultCardShowTracker:(TTVVideoBusinessType)type rackerEntity:(TTADEventTrackerEntity *)entity context:(TTVFeedCellForRowContext *)context;
@end

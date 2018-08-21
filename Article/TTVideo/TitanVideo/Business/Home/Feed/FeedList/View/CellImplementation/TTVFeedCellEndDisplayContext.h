//
//  TTVFeedCellEndDisplayContext.h
//  Article
//
//  Created by panxiang on 2017/4/19.
//
//

#import <Foundation/Foundation.h>
@class TTADEventTrackerEntity;
@interface TTVFeedCellEndDisplayContext : NSObject

@end


#pragma mark cellSelect默认处理
@interface TTVFeedEndDisplayHandler : NSObject
+ (void)defaultADShowOverWithEntity:(TTADEventTrackerEntity *)entity context:(TTVFeedCellEndDisplayContext *)context;
@end

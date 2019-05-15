//
//  TTVFeedCellForRowContext.m
//  Article
//
//  Created by panxiang on 2017/4/24.
//
//

#import "TTVFeedCellForRowContext.h"
#import "TTVFeedListItem.h"
#import "SSADEventTracker.h"

@implementation TTVFeedCellForRowContext

@end

@implementation TTVFeedCellForRowHandler

+ (void)defaultCardShowTracker:(TTVVideoBusinessType)type rackerEntity:(TTADEventTrackerEntity *)entity context:(TTVFeedCellForRowContext *)context
{
    if (context.isDisplayView) {
        if (type == TTVVideoBusinessType_VideoAdphone ||
            type == TTVVideoBusinessType_PicAdphone) {
        } else if (type == TTVVideoBusinessType_VideoAdapp ||
                   type == TTVVideoBusinessType_PicAdapp) {

        } else if (type == TTVVideoBusinessType_VideoAdform ||
                   type == TTVVideoBusinessType_PicAdform) {
            [[SSADEventTracker sharedManager] trackEventWithEntity:entity label:@"card_show" eventName:@"feed_form" extra:nil];
        } else if (type == TTVVideoBusinessType_VideoAdcounsel ||
                   type == TTVVideoBusinessType_VideoAdcounsel) {
            [[SSADEventTracker sharedManager] trackEventWithEntity:entity label:@"card_show" eventName:@"feed_counsel" extra:nil];
        }
    }
}

@end

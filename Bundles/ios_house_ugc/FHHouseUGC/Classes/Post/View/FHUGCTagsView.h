//
//  FHUGCTagsView.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/2/26.
//

#import <UIKit/UIKit.h>
#import "FHUGCTagAndRemarkModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface FHUGCTagsView : UIView
- (void)refreshWithTags:(NSArray<FHUGCTagModel*> *)tags;
- (NSArray<FHUGCTagModel*> *)selectedTags;
@end

NS_ASSUME_NONNULL_END

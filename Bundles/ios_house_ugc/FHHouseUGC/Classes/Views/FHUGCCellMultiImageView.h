//
//  FHUGCCellMultiImageView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import <UIKit/UIKit.h>
#import "FHFeedContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellMultiImageView : UIView

- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count;

- (void)updateImageView:(NSArray *)imageList;

@end

NS_ASSUME_NONNULL_END

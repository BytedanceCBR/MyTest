//
//  FHUGCCellMultiImageView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellMultiImageView : UIView

- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count;

- (void)updateImageView:(NSArray *)imageList largeImageList:(NSArray *)largeImageList;

@end

NS_ASSUME_NONNULL_END

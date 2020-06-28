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

+ (CGFloat)viewHeightForCount:(CGFloat)count width:(CGFloat)width;

//单图时固定尺寸
@property(nonatomic, assign) BOOL fixedSingleImage;
@property(nonatomic, assign) CGFloat viewHeight;

@property (nonatomic, assign) CGFloat useItemPadding;

@end

NS_ASSUME_NONNULL_END

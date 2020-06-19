//
//  FHHouseDetailRGCMultiImageView.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailRGCMultiImageView : UIView
- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count;

- (void)updateImageView:(NSArray *)imageList largeImageList:(NSArray *)largeImageList;

+ (CGFloat)viewHeightForCount:(CGFloat)count width:(CGFloat)width;

//单图时固定尺寸
@property(nonatomic, assign) BOOL fixedSingleImage;
@property(nonatomic, assign) CGFloat viewHeight;

@property (nonatomic, assign) CGFloat useItemPadding;
@end

NS_ASSUME_NONNULL_END

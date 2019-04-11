//
//  FHPriceValuationSelectionView.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationSelectionView : UIView

@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, strong) NSArray *valueArray;

@property(nonatomic, assign) CGFloat itemWidth;
@property(nonatomic, assign) CGFloat itemHeight;
@property(nonatomic, assign) CGFloat itemPadding;
@property(nonatomic, strong) UIColor *bgColor;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIColor *selectedBgColor;
@property(nonatomic, strong) UIColor *selectedTextColor;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, assign) CGFloat viewHeight;

//点击事件
@property(nonatomic, copy) void(^selectedBlock)(NSInteger index,NSString *name,NSString *value);

- (void)selectedItem:(NSString *)name;
- (void)clearAllSelection;

@end

NS_ASSUME_NONNULL_END

//
//  FHPriceValuationNSearchView.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 高度64
@interface FHPriceValuationNSearchView : UIView

@property (nonatomic, strong)   UITextField       *searchInput;
- (void)setSearchPlaceHolderText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

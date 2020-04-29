//
//  FHSuggestionSearchBar.h
//  FHHouseList
//
//  Created by xubinbin on 2020/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionSearchBar : UIView

@property (nonatomic, strong)   UIButton       *backBtn;
@property (nonatomic, strong)   UITextField       *searchInput;

- (void)setSearchPlaceHolderText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

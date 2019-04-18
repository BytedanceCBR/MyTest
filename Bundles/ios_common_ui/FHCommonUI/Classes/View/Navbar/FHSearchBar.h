//
//  FHSearchBar.h
//  FHCommonUI
//
//  Created by 张静 on 2019/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSearchBar : UIView

@property (nonatomic, strong)   UIButton       *backBtn;
@property (nonatomic, strong)   UITextField       *searchInput;

- (void)setSearchPlaceHolderText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END

//
//  FHSuggestionListNavBar.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionListNavBar : UIView

@property (nonatomic, strong)   UIButton       *backBtn;
@property (nonatomic, strong)   UILabel       *searchTypeLabel;
- (void)setSearchPlaceHolderText:(NSString *)text;

@end

@interface FHExtendHotAreaButton : UIButton

@property (nonatomic, assign)   BOOL       isExtend;

@end

NS_ASSUME_NONNULL_END

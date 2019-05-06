//
//  FHSearchBar.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FHSearchNavTypeDefault,
    FHSearchNavTypeSug,
} FHSearchNavType;

@interface FHSearchBar : UIView

@property (nonatomic, strong)   UIButton       *backBtn;
@property (nonatomic, strong)   UILabel       *searchTypeLabel;
@property (nonatomic, strong)   UIButton       *searchTypeBtn;
@property (nonatomic, strong)   UITextField       *searchInput;

-(instancetype)initWithType:(FHSearchNavType)type;
- (void)setSearchPlaceHolderText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

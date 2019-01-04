//
//  FHCityListLocationBar.h
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityListLocationBar : UIView

@property (nonatomic, strong)   UIButton       *cityNameBtn;
@property (nonatomic, strong)   UIButton       *reLocationBtn;

@property (nonatomic, copy)     NSString       *cityName;
@property (nonatomic, assign)   BOOL       isLocationSuccess;

@end

NS_ASSUME_NONNULL_END

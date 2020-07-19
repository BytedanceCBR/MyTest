//
//  FHRealtorDetailBottomBar.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ImAction)();
typedef void(^PhoneAction)();

@interface FHRealtorDetailBottomBar : UIView
@property (nonatomic, copy) ImAction imAction;
@property (nonatomic, copy) PhoneAction phoneAction;
@end

NS_ASSUME_NONNULL_END

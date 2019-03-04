//
//  FHHouseListBannerView.h
//  Pods
//
//  Created by 张静 on 2019/3/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListBannerItem : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, copy) NSString *iconName;
@property(nonatomic, copy) NSString *openUrl;

@end

@interface FHHouseListBannerItemView : UIView

@end

@interface FHHouseListBannerView : UIView

@property (nonatomic, copy) void(^clickedItemCallBack)(NSInteger index);

- (void)addBannerItems:(NSArray<FHHouseListBannerItem *> *)items;

@end

NS_ASSUME_NONNULL_END

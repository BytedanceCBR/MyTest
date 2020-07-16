//
//  FHHouseRealtorDetailRgcTabView.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailRgcTabView : UIView
@property (strong, nonatomic) NSArray *tabInfoArr;
@property (copy, nonatomic, readonly) NSString *selectName;
@property (copy, nonatomic, readonly) NSString *tracerName;
@property(nonatomic, copy) void (^headerItemSelectAction)(NSInteger index);
@end

NS_ASSUME_NONNULL_END

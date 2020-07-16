//
//  FHHouseRealtorDetailStatusModel.h
//  Pods
//
//  Created by liuyu on 2020/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHHouseRealtorDetailStatus <NSObject>

@end
@interface FHHouseRealtorDetailStatus : NSObject
@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) BOOL isHiddenFooterRefish;
@property (assign, nonatomic) BOOL hasMore;
@end
@interface FHHouseRealtorDetailStatusModel : NSObject
+(instancetype)sharedInstance;
@property (nonatomic ,strong) NSArray <FHHouseRealtorDetailStatus>*statusArray;
@property (nonatomic ,strong) FHHouseRealtorDetailStatus *currentRealtorDetailStatus;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) CGFloat currentCellHeight;
@end

NS_ASSUME_NONNULL_END

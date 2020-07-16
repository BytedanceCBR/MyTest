//
//  FHHouseRealtorDetailBaseCellModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailBaseCellModel : NSObject
@property (nonatomic, copy) NSString *showName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *count;

- (CGFloat)rowHeight;
@end
@interface FHHouseRealtorDetailHeaderCellModel: FHHouseRealtorDetailBaseCellModel

@end

@interface FHHouseRealtorDetailRGCCellModel: FHHouseRealtorDetailBaseCellModel
@property (strong, nonatomic) NSArray *tabDataArray;

@end

NS_ASSUME_NONNULL_END

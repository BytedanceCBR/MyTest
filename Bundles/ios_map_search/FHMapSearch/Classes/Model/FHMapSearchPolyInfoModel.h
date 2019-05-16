//
//  FHMapSearchPolyInfoModel.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchPolyInfoModel : NSObject

/*
 * 多边形，经纬度用","分割，不同点之间用";"分割。
 * 116.44417238014412,39.89371509137617;116.42774785086281,39.893496613309466
 */
@property(nonatomic , copy) NSString *coordinateEnclosure;

/*
 * 小区id
 * [123,345,567,789]
 */
@property(nonatomic , copy) NSString *neighborhoodIds;

@end

NS_ASSUME_NONNULL_END

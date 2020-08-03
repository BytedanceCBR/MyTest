//
//  FHDetailStaticMapCell.h
//  AKCommentPlugin
//
//  Created by zhulijun on 2019/11/26.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseCell.h"
#import "FHDetailStaticMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailStaticMapCenterAnnotationView : FHStaticMapAnnotationView
@property(nonatomic, strong) UIImageView *imageView;
@end

@interface FHDetailStaticMapPOIAnnotationView : FHStaticMapAnnotationView
@property(nonatomic, strong) UIImageView *backImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *arrowView;
@end

@interface FHDetailStaticMapCellModel : FHDetailBaseModel

@property(nonatomic, weak, nullable) UITableView *tableView;
@property(nonatomic, copy, nullable) NSString *gaodeLng;
@property(nonatomic, copy, nullable) NSString *gaodeLat;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *houseId;
@property(nonatomic, copy, nullable) NSString *mapCentertitle;
@property(nonatomic, copy, nullable) NSString *houseType;
@property(nonatomic, copy, nullable) NSString *score;
@property(nonatomic, strong, nullable) FHDetailGaodeImageModel *staticImage;
@property(nonatomic, assign) BOOL mapOnly;
@property(nonatomic, assign) BOOL useNativeMap; //降级控制，外部不使用
@property(nonatomic, assign) CGFloat topMargin; //小区详情页使用
@property(nonatomic, assign) CGFloat bottomMargin;

@property (nonatomic, copy, nullable) NSString *baiduPanoramaUrl;
@end

@interface FHDetailStaticMapCell : FHDetailBaseCell
@end

NS_ASSUME_NONNULL_END

//
//  FHHouseAnnotation.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import <MAMapKit/MAMapKit.h>
#import "FHMapSearchTypes.h"

typedef NS_ENUM(NSInteger , FHHouseAnnotationType) {
    FHHouseAnnotationTypeNormal = 0 ,
    FHHouseAnnotationTypeSelected ,
    FHHouseAnnotationTypeOverSelected ,
};

NS_ASSUME_NONNULL_BEGIN
@class FHMapSearchDataListModel;
@interface FHHouseAnnotation : MAPointAnnotation

@property(nonatomic , assign) FHMapSearchType searchType;
@property(nonatomic , strong) FHMapSearchDataListModel *houseData;
@property(nonatomic , assign) FHHouseAnnotationType type;

@end

NS_ASSUME_NONNULL_END

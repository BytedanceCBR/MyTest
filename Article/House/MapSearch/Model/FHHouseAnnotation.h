//
//  FHHouseAnnotation.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import <MAMapKit/MAMapKit.h>
#import "FHMapSearchTypes.h"

NS_ASSUME_NONNULL_BEGIN
@class FHMapSearchDataListModel;
@interface FHHouseAnnotation : MAPointAnnotation

@property(nonatomic , assign) FHMapSearchType searchType;
@property(nonatomic , strong) FHMapSearchDataListModel *houseData;

@end

NS_ASSUME_NONNULL_END

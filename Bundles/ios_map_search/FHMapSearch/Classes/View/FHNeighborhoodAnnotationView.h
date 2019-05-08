//
//  FHNeighborhoodAnnotationView.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import <MAMapKit/MAMapKit.h>
#import "FHHouseAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodAnnotationView : MAAnnotationView

-(void)changeSelectMode:(FHHouseAnnotationType)mode;

@end

NS_ASSUME_NONNULL_END

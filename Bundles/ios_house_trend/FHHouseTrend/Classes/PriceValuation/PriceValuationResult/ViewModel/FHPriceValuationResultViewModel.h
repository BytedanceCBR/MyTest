//
//  FHPriceValuationResultViewModel.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHPriceValuationResultView.h"
#import "FHPriceValuationResultController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationResultViewModel : NSObject

- (instancetype)initWithView:(FHPriceValuationResultView *)view controller:(FHPriceValuationResultController *)viewController;

- (void)requestData;

@end

NS_ASSUME_NONNULL_END

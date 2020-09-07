//
//  FHHouseSaleInputViewModel.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import <Foundation/Foundation.h>
#import "FHHouseSaleInputController.h"
#import "FHHouseSaleInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSaleInputViewModel : NSObject

//屏蔽TTNavigationViewController带来的键盘变化
@property(nonatomic , assign) BOOL isHideKeyBoard;

- (instancetype)initWithView:(FHHouseSaleInputView *)view controller:(FHHouseSaleInputController *)viewController;

- (void)viewWillAppear;

- (void)viewWillDisappear;

@end

NS_ASSUME_NONNULL_END

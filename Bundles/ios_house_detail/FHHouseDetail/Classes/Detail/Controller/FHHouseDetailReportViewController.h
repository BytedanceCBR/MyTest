//
//  FHHouseDetailReportViewController.h
//  FHHouseDetail
//
//  Created by wangzhizhou on 2020/10/10.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailReportViewController : FHBaseViewController
@end

@interface FHHouseDetailReportPhoneNumberInvalidTextField : UITextField
@end

@interface NSString(validateContactNumber)
- (BOOL)validateContactNumber;
@end
NS_ASSUME_NONNULL_END

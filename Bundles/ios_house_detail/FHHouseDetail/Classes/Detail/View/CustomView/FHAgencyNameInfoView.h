//
//  FHAgencyNameInfoView.h
//  FHHouseDetail
//
//  Created by 春晖 on 2019/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHDetailDataCertificateLabelsModel;
@interface FHAgencyNameInfoView : UIView

-(void)setAgencyNameInfo:(NSArray<FHDetailDataCertificateLabelsModel *> *)info;

@end

NS_ASSUME_NONNULL_END

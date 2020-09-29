//
//  FHShowVRView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/22.
//

#import "TTShowImageView.h"
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHShowVRView : TTShowImageView

@property (nonatomic, strong) FHDetailHouseVRDataModel *vrModel;
-(void)showVRIcon;
@end

NS_ASSUME_NONNULL_END

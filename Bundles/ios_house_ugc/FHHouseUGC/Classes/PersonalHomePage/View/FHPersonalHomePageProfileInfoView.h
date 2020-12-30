//
//  FHPersonalHomePageProfileInfoView.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import <UIKit/UIKit.h>
#import "FHPersonalHomePageProfileInfoModel.h"
#import "FHPersonalHomePageManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageProfileInfoView : UIView
@property(nonatomic,strong) UIImageView *shadowView;
@property(nonatomic,assign) CGFloat viewHeight;
@property(nonatomic,weak) FHPersonalHomePageManager *homePageManager;
- (void)updateWithModel:(FHPersonalHomePageProfileInfoDataModel *)model isVerifyShow:(BOOL)isVerifyShow;
@end

NS_ASSUME_NONNULL_END
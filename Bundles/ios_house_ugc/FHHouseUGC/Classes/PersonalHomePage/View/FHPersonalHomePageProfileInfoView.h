//
//  FHPersonalHomePageProfileInfoView.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import <UIKit/UIKit.h>
#import "FHPersonalHomePageProfileInfoModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHPersonalHomePageProfileInfoImageView : UIView
- (void)updateWithUrl:(NSString *)url;
@end

@interface FHPersonalHomePageProfileInfoView : UIView
@property(nonatomic,strong) FHPersonalHomePageProfileInfoImageView *shadowView;
@property(nonatomic,assign) CGFloat viewHeight;
- (void)updateWithModel:(FHPersonalHomePageProfileInfoModel *)model;
@end

NS_ASSUME_NONNULL_END

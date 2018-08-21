//
//  TTPersonalHomeHeaderInfoView.h
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "SSThemed.h"
#import "TTPersonalHomeUserInfoResponseModel.h"

@interface TTPersonalHomeHeaderInfoView : SSThemedView

@property (nonatomic, weak) SSThemedButton *spreadOutBtn;
@property (nonatomic, strong) TTPersonalHomeUserInfoDataResponseModel *infoModel;
@property (nonatomic, assign, readonly) CGFloat headerViewTopMargin;
@property (nonatomic, copy) void (^multiplePlatformFollowersInfoViewSpreadOutBlock)(BOOL spreadOut);

- (void)setupSubviewFrameWithTopMargin:(CGFloat)topMargin;

- (void)refreshUIWithMultiplePlatformFollowersInfoViewSpreadOut:(BOOL)spreadOut;

@end

//
//  TTPersonalHomeTopNavView.h
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "SSThemed.h"
#import "TTPersonalHomeUserInfoResponseModel.h"
#import "TTFollowThemeButton.h"

@protocol TTPersonalHomeTopNavViewDelegate <NSObject>

- (void)navigationViewdidSelectedFollow:(BOOL)isFollow;
- (void)navigationviewDidSelectedBack;
- (void)navigationViewDidSelectedShare;

@end

@interface TTPersonalHomeTopNavView : SSThemedView
@property (nonatomic, weak) SSThemedButton *privateMessageBtn;
@property (nonatomic, weak) TTFollowThemeButton *followBtn;
@property (nonatomic, weak) id <TTPersonalHomeTopNavViewDelegate> delegate;
- (void)updateBarTranslucentWithScale:(CGFloat)scale;
- (void)updateOtherTranslucentWithScale:(CGFloat)scale;
@property (nonatomic, strong) TTPersonalHomeUserInfoDataResponseModel *infoModel;

@end

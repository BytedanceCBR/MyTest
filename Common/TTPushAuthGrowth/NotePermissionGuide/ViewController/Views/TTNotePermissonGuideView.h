//
//  TTNotePermissonGuideView.h
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import <SSThemed.h>
#import <TTDeviceUIUtils.h>
#import <UIImageView+WebCache.h>
#import "TTNotePermissionGuideModel.h"



@protocol TTNotePermissionGuideView <NSObject>
@required
- (void)showWithAnimated:(BOOL)animated completion:(void (^)())completedHandler;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)())completedHandler;

@optional
- (void)showWithCompletion:(void (^)())completedHandler;
- (void)hideWithCompletion:(void (^)())completedHandler;
@end



@interface TTNotePermissonGuideView : SSThemedView
<
TTNotePermissionGuideView
>

@property (nonatomic, strong) SSThemedLabel *titleLabel;

@property (nonatomic, strong) SSThemedLabel *subTitleLabel;

@property (nonatomic, strong) SSThemedImageView *permissionGuideImageView;

@property (nonatomic, strong) TTNotePermissionGuideModel *dataModel;

- (void)setPermissionGuideImageWithURL:(NSURL *)urlString;

- (void)setupDismissButtons;

- (void)setupTappedTextButtons;

+ (void)openAppSystemSettings;

+ (CGFloat)viewWidth;

+ (CGFloat)viewHeight;

@end

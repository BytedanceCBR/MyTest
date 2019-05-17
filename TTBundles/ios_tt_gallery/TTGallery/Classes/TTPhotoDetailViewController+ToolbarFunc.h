//
//  TTPhotoDetailViewController+ToolbarFunc.h
//  Article
//
//  Created by yuxin on 4/19/16.
//
//

#import "TTPhotoDetailViewController.h"
#import "TTCommentWriteView.h"


@interface TTPhotoDetailViewController (ToolbarFunc) <TTCommentWriteManagerDelegate>

@property (nonatomic, strong) TTCommentWriteManager *writeCommentManager;

- (NSString *)currentShowGalleryURL;

- (void)currentGalleryShareUseActivityController;

- (void)_backActionFired:(id)sender;
- (void)_collectActionFired:(id)sender;
- (void)_moreActionFired:(id)sender;
- (void)_writeCommentActionFired:(id)sender;
- (void)_showCommentActionFired:(id)sender;
- (void)_shareActionFired:(id)sender;
- (void)orignialActionFired:(id)sender;
- (void)hiddenMoreSettingActivityView;
- (void)keyboardDidHide;

@end

//
//  TTRecordVideoViewController.h
//  Article
//
//  Created by 王霖 on 16/9/28.
//
//

#import <SSViewControllerBase.h>
//#import "TTRecordImportVideoContainerViewController.h"

@protocol TTRecordVideoViewControllerDelegate;

@interface TTRecordVideoViewController : SSViewControllerBase

//做动画用的
//@property (nonatomic, strong, readonly) UIView * cameraView;

@property (nonatomic, weak, nullable) id <TTRecordVideoViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL challengeRuleViewOpen;//挑战规则是否打开

- (nullable instancetype)initWithStyle:(TTRecordViewStyle)style postUGCEnterFrom:(TTPostUGCEnterFrom)postUGCEnterFrom templateID:(NSInteger)templateID requestRedPacketType:(TTRequestRedPacketType)requestRedPacketType musicID:(NSString *)musicID extraTrack:(NSDictionary *)extraTrack dismissBlock:(TTRecordVideoDismissBlock)dismissBlock;

- (CGFloat)challengeRuleContainerViewCenterY;

@end


@protocol TTRecordVideoViewControllerDelegate <NSObject>

/**
 完成视频录制

 @param controller 视频录制VC
 @param url 录制完视频保存的url，会在退出发布器时被清理，如果要保留则需要复制
 */
- (void)recordVideoViewController:(nonnull TTRecordVideoViewController *)controller didFinishRecordWithOutputURL:(nullable NSURL *)url musicID:(NSString *)musicID;

/**
 视频录制过程中需要展示/隐藏tabbar
 */
- (void)recordVideoViewController:(nonnull TTRecordVideoViewController *)controller needHideTabbar:(BOOL)hide;

/**
 *  切换模版
 */
- (void)recordVideoViewController:(TTRecordVideoViewController *)controller didSelectThemeID:(NSString *)themeID;

@end

//
//  TTEditVideoViewController.h
//  Article
//
//  Created by 王霖 on 16/9/28.
//
//

#import <SSViewControllerBase.h>
#import <SSThemed.h>
//#import "TTRecordImportVideoContainerViewController.h"
@class TTVideoPlayerLayerView, TTRichSpanText;

typedef void(^TTEditVideoPreviewCompletionBlock)(UIImage * _Nullable previewImage);

@interface TTEditVideoViewController : SSViewControllerBase

//暴露出来给转场动画用
@property (nonatomic, strong, readonly, nullable) SSThemedImageView *previewImageView;
@property (nonatomic, strong, readonly, nullable) UIView * videoContainerView;
@property (nonatomic, strong, readonly, nullable) UIView *fadeView;

- (nullable instancetype)initWithVideoUrl:(nonnull NSURL *)videoUrl
                              videoSource:(TTVideoSourceType)videoSource
                          recordViewStyle:(TTRecordViewStyle)recordViewStyle
                    originRecordViewStyle:(TTRecordViewStyle)originRecordViewStyle
                       durationBeforeClip:(NSTimeInterval)durationBeforClip
                               presetText:(nullable TTRichSpanText *)presetText
                         postUGCEnterFrom:(TTPostUGCEnterFrom)postUGCEnterFrom
                             needCompress:(BOOL)needCompress
                       defaultSaveToAlbum:(BOOL)defaultSaveToAlbum
                     effectApplyedThemeID:(nullable NSString *)themeID
                                  musicID:(nullable NSString *)musicID
                         challengeGroupID:(nullable NSString *)challengeGroupID
                     requestRedPacketType:(TTRequestRedPacketType)requestRedPacketType
                               extraTrack:(nullable NSDictionary *)extraTrack
                          completionBlock:(nullable TTRecordVideoCompletionBlock)completionBlock;

@end

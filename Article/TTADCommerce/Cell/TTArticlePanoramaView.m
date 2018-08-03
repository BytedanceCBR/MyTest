//
//  TTArticlePanoramaView.m
//  Article
//
//  Created by rongyingjie on 2017/7/30.
//
//

#import "TTArticlePanoramaView.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTImageInfosModel.h"
#import "TTImageView+TrafficSave.h"
#import "NetworkUtilities.h"
#import "SSUserSettingManager.h"
#import "TTDeviceHelper.h"
#import "Comment.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import "TTMotionView.h"
#import "SSSimpleCache.h"
#import "UIImage+MultiFormat.h"

#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"


@interface TTArticlePanoramaView () <TTMotionViewDelegate>

@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end

/// 图片(视频)控件
@implementation TTArticlePanoramaView
/// 框架
- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (oldFrame.size.width != self.frame.size.width || oldFrame.size.height != self.frame.size.height) {
        [self layoutPics];
    }
}

/** 初始化单个图片(视频)视图 */
- (void)initalizeImageView {
    self.motionView = [[TTMotionView alloc] initWithType:TTMotionViewTypeFullView];
    self.motionView.delegate = self;
    [self.motionView setMotionEnabled:NO];
    [self.motionView setScrollBounceEnabled:NO];
    [self addSubview:self.motionView];
}

/**
 图片(视频)控件初始化方法
 
 - parameter style: 图片(视频)控件样式
 
 - returns: 图片(视频)控件实例
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initalizeImageView];
    }
    return self;
}

// MARK: LayoutSubviews / UpdateSubviews
/** 图片(视频)控件布局 */
- (void)layoutPics {
    self.motionView.frame = CGRectMake(0, 0, self.width, self.height);
}

/**
 图片(视频)控件更新
 
 - parameter orderedData: orderedData数据
 */
- (void)updatePics:(ExploreOrderedData *)orderedData {
    self.orderedData = orderedData;
    Article *article = [orderedData article];
    Comment *comment = [orderedData comment];
    if (article || comment) {
        NSDictionary *imageInfo;
        if ([[article listGroupImgDicts] count] > 0 && [[article gallaryFlag] isEqual:@1]) {
            imageInfo = [[article listGroupImgDicts] firstObject];
        } else {
            imageInfo = [orderedData listLargeImageDict];
        }
        TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
        
        [self refreshWithModel:imageModel];
        [self.motionView setMotionEnabled:YES];
    }
    [self layoutPics];
}

- (void)refreshWithModel:(TTImageInfosModel *)model
{
    NSTimeInterval ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
    
    WeakSelf;
    TTImageView *imageView = [[TTImageView alloc] init];
    [imageView setImageWithModelInTrafficSaveMode:model
                                 placeholderImage:nil
                                          success:^(UIImage *image, BOOL cached) {
                                              StrongSelf;
                                              if (!cached) {
                                                  //首次加载记录加载时长
                                                  NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - ttTrackStartTime;
                                                  [self trackImageLoadTime:duration model:model];
                                              }
                                              if (!self.motionView.image || image != self.motionView.image) {
                                                  [self.motionView setImage:image];
                                              }
                                          }
                                     failure:^(NSError *error) {
                                         if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                             if (error.code != NSURLErrorNotConnectedToInternet &&
                                                 error.code != NSURLErrorCancelled &&
                                                 error.code != NSURLErrorTimedOut) {
                                                 NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                                                 [extra setValue:model.URI forKey:@"URI"];
                                                 [extra setValue:@(error.code) forKey:@"code"];
                                                 [[TTMonitor shareManager] trackService:@"error_picture_url" status:1 extra:extra];
                                             }
                                         }
                                     }];
}

- (void)trackImageLoadTime:(NSTimeInterval)duration model:(TTImageInfosModel *)model{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSString *url = [model urlStringAtIndex:0];
    [attributes setValue:self.orderedData.ad_id forKey:@"ad_id"];
    [attributes setValue:self.orderedData.log_extra forKey:@"log_Extra"];
    [attributes setValue:url forKey:@"url"];
    [attributes setValue:@(duration*1000.0) forKey:@"value"];
    [[TTMonitor shareManager] trackService:@"fullView_picture_load" attributes:attributes];
}

/**
 AD 图片(视频)控件更新
 
 - parameter orderedData: orderedData数据
 */
- (void)updateADPics:(ExploreOrderedData *)orderedData {
    self.orderedData = orderedData;
    TTImageInfosModel *imageModel = orderedData.listLargeImageModel;
    if (imageModel == nil) {
        id<TTAdFeedModel> adModel = orderedData.adModel;
        imageModel = [adModel imageModel];
    }
    if (imageModel) {
        //广告图片不持久化
        [self refreshWithModel:imageModel];
        [self.motionView setMotionEnabled:YES];
    } else {
        [self.motionView setImage:nil];
    }

    [self layoutPics];
}

- (TTMotionView *)animationFromView
{
    return self.motionView;
}

- (void)dealloc
{
    self.motionView.delegate = nil;
}

- (void)willDisplay
{
    [self.motionView willDisplaying];
}

- (void)didEndDisplaying
{
    [self.motionView didEndDisplaying];
}

- (void)resumeDisplay
{
    [self.motionView resumeDisplay];
}

#pragma - TTMotionViewDelegate

- (void)motionViewScrollViewDidScrollToOffset:(CGPoint)offset
{
    
}

@end

//
//  TTArticlePanorama3DView.m
//  Article
//
//  Created by rongyingjie on 2017/11/1.
//

#import "TTArticlePanorama3DView.h"

#import "Article+TTADComputedProperties.h"
#import "Comment.h"
#import "ExploreOrderedData+TTAd.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTImageInfosModel.h"
#import "TTImageView+TrafficSave.h"
#import "TTMotionView.h"
#import "UIImage+MultiFormat.h"

@interface TTArticlePanorama3DView ()

@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end

/// 图片(视频)控件
@implementation TTArticlePanorama3DView
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
    self.panoramaView = [[TTPanorama3DView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.panoramaView setTouchToPan:YES];
    [self.panoramaView setPinchToZoom:YES];
    [self.panoramaView setOrientToDevice:YES];
    [self.panoramaView setIsShowGyroTipView:YES];
    [self addSubview:self.panoramaView];
}

/**
 图片(视频)控件初始化方法
 
 - parameter style: 图片(视频)控件样式
 
 - returns: 图片(视频)控件实例
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    return self;
}

// MARK: LayoutSubviews / UpdateSubviews
/** 图片(视频)控件布局 */
- (void)layoutPics {
    if (!self.panoramaView && self.height > 44) {
        /*
         *只有当高度大于44时才认为是有效的，这时再初始化TTPanorama3DView
         *不然如果初始化后高度再变会导致图像内容设置有误，图片会无法显示
         */
        [self initalizeImageView];
    }
    self.panoramaView.frame = CGRectMake(0, 0, self.width, self.height);
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
                                              if (!self.panoramaView.image || image != self.panoramaView.image) {
                                                  // 图片加载的操作会比较耗时，判断缓存的图片不重复操作
                                                  [self.panoramaView setImage:image];
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
    id<TTAdFeedModel> adModel = [[orderedData article] adModel];
    TTImageInfosModel *model = orderedData.listLargeImageModel;
    if (adModel == nil) {
        model = [adModel imageModel];
    }
    if (adModel != nil) {
        //广告图片不持久化
        [self refreshWithModel:model];
    } else {
        [self.panoramaView setImage:nil];
    }
    
    [self layoutPics];
}

- (UIImage *)animationFromView
{
    return self.panoramaView.snapshot;
}

- (void)dealloc
{
}

- (void)willDisplay
{
    [self.panoramaView willDisplaying];
}

- (void)didEndDisplaying
{
    [self.panoramaView didEndDisplaying];
}

- (void)resumeDisplay
{
    [self.panoramaView resumeDisplay];
}

@end

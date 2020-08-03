//
//  FHEncyclopediaHeader.m
//  Pods
//
//  Created by liuyu on 2020/5/13.
//

#import "FHEncyclopediaHeader.h"
#import <Lynx/LynxView.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"
#import "FHLynxManager.h"
#import "Masonry.h"
#import "NSObject+YYModel.h"
#import "FLynxWikiHeaderBridge.h"
#import "IESGeckoKit.h"
#import "FHIESGeckoManager.h"
#import "SDWebImageManager.h"
#import "UIColor+Theme.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "TTInstallIDManager.h"
#import "HMDTTMonitor.h"

@interface FHEncyclopediaHeader()<LynxViewClient>
@property (strong, nonatomic)LynxView *segmentView;
@property(nonatomic ,strong) NSData *currentTemData;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (nonatomic, assign) NSTimeInterval loadTime; //页面加载时间
@end

@implementation FHEncyclopediaHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
}

- (LynxView *)segmentView {
    if (!_segmentView) {
                CGRect screenFrame = [UIScreen mainScreen].bounds;
             _segmentView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
                    builder.isUIRunningMode = YES;
                    builder.config = [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
//                    [builder.config registerModule:[FHLynxCoreBridge class]];
                    [builder.config registerModule:[FLynxWikiHeaderBridge class] param:self];
               }];
             _segmentView.layoutWidthMode = LynxViewSizeModeExact;
             _segmentView.layoutHeightMode = LynxViewSizeModeUndefined;
             _segmentView.preferredLayoutWidth = screenFrame.size.width;
             _segmentView.client = self;
             _segmentView.preferredMaxLayoutHeight = screenFrame.size.height;
             [_segmentView triggerLayout];
             [self addSubview:_segmentView];
        NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"ugc_encyclopedia_lynx_header" templateKey:[FHLynxManager defaultJSFileName] version:0];
              if (templateData) {
                  _loadTime = [[NSDate date] timeIntervalSince1970];
                   if (templateData != self.currentTemData) {
                       self.currentTemData = templateData;
                      [self.segmentView loadTemplate:templateData withURL:@"local"];
                   }
               }
    }
    return _segmentView;
}

- (void)updateModel:(EncyclopediaConfigDataModel *)model {
    NSString *lynxData = [model yy_modelToJSONString];
    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"ugc_encyclopedia_lynx_header" templateKey:[FHLynxManager defaultJSFileName] version:0];
    LynxTemplateData *data = [[LynxTemplateData alloc]initWithJson:lynxData];
          if (templateData) {
               if (templateData != self.currentTemData) {
                   self.currentTemData = templateData;
                   [self.segmentView loadTemplate:templateData withURL:@"loca" initData:data];
//                  [self.segmentView loadTemplate:templateData withURL:@"local"];
               }
           }
    [_segmentView updateDataWithString:lynxData];
    
}

-(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage *)placeholderImage {
    if (!_placeholderImage) {
        UIImage *placeholderImage = [self createImageWithColor:[UIColor themeGray6]];
        _placeholderImage = placeholderImage;
    }
    return _placeholderImage;
}

- (void)lynxViewDidFirstScreen:(LynxView*)view{
    NSTimeInterval costTime = [[NSDate date] timeIntervalSince1970] - _loadTime;
    [self sendCostTimeEvent:costTime andService:@"lynx_page_duration"];
}

- (void)sendCostTimeEvent:(NSTimeInterval)time andService:(NSString *)sevice
{
    NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
    [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
     NSMutableDictionary *uploadParams = [NSMutableDictionary new];
    NSString *eventServie = [NSString stringWithFormat:@"lynx_page_duration_%@",@"ugc_encyclopedia_lynx_header"];
    if (time < 15) {
        [uploadParams setValue:@(time * 1000) forKey:@"duration"];
        [[HMDTTMonitor defaultManager] hmdTrackService:eventServie metric:uploadParams category:nil extra:paramsExtra];
    }
}

- (void)lynxView:(LynxView*)view didReceiveFirstLoadPerf:(LynxPerformance*)perf{
    
    NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
    [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
     NSMutableDictionary *uploadParams = [NSMutableDictionary new];
    if (perf && [[perf toDictionary] isKindOfClass:[NSDictionary class]]) {
        [uploadParams addEntriesFromDictionary:[perf toDictionary]];
    }
    NSString *eventServie = [NSString stringWithFormat:@"lynx_page_info_%@",@"ugc_encyclopedia_lynx_header"];
    [[HMDTTMonitor defaultManager] hmdTrackService:eventServie metric:uploadParams category:nil extra:paramsExtra];
    
}

- (void)lynxView:(LynxView*)view didReceiveUpdatePerf:(LynxPerformance*)perf{
    NSLog(@"perf=%@",[perf toDictionary]);
}



- (void)loadImageWithURL:(nonnull NSURL*)url
                    size:(CGSize)targetSize
              completion:(nonnull LynxImageLoadCompletionBlock)completionBlock {
    completionBlock(self.placeholderImage,nil,nil);
    if([url.absoluteString containsString:@"gecko:"]){
        NSString * imageStr = url.absoluteString;
        NSString *imageRootPath = [IESGeckoKit rootDirForAccessKey:[FHIESGeckoManager getGeckoKey] channel:nil];
        NSString *imageUrlPath = [imageStr substringFromIndex:8];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",imageRootPath,imageUrlPath];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        [[SDWebImageManager sharedManager] loadImageWithURL:fileURL
                                                    options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL* _Nullable targetURL) {
            
        }
                                                  completed:^(UIImage* _Nullable image, NSData* _Nullable data, NSError* _Nullable error,
                                                              SDImageCacheType cacheType, BOOL finished, NSURL* _Nullable imageURL) {
            if (error) {
                completionBlock(self.placeholderImage, nil, url);
            }else{
                completionBlock(image, error, url);
            }
        }];
    }else {
        [[SDWebImageManager sharedManager] loadImageWithURL:url
            options:0
            progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL* _Nullable targetURL) {

            }
            completed:^(UIImage* _Nullable image, NSData* _Nullable data, NSError* _Nullable error,
                        SDImageCacheType cacheType, BOOL finished, NSURL* _Nullable imageURL) {
              completionBlock(image, error, url);
            }];
    }
}

- (void)onSelectChange:(id )param {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectSegmentWithData:)]){
        [self.delegate selectSegmentWithData:param];
    }
}
@end

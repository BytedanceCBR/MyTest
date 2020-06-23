//
//  FHLynxView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxView.h"
#import <mach/mach_time.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxManager.h"
#import <Lynx/LynxView.h>
#import <mach/mach_time.h>
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"
#import <SDWebImage/SDWebImageManager.h>
#import "UIDevice+BTDAdditions.h"
#import "IESGeckoKit.h"
#import <FHHouseBase/FHIESGeckoManager.h>
#import "FHLynxPageBridge.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "BDWebViewBlankDetect.h"

@implementation FHLynxViewBaseParams
@end

@interface FHLynxView()
@property (nonatomic, assign) CGRect lynxViewFrame;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, assign) NSTimeInterval loadTime; //页面加载时间

@end


@implementation FHLynxView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lynxViewFrame = frame;
    }
    return self;
}

#pragma mark - load methods
- (void)loadLynxBaseParams:(FHLynxViewBaseParams *)params
{
    id templateData = nil;
    if (params.initialProperties) {
        if ([params.initialProperties isKindOfClass:[NSString class]]) {
            templateData = [[LynxTemplateData alloc] initWithJson:params.initialProperties];
        } else if ([params.initialProperties isKindOfClass:[NSDictionary class]]) {
            templateData = [[LynxTemplateData alloc] initWithDictionary:params.initialProperties];
        }
        LynxTemplateData *initialData = [[LynxTemplateData alloc] initWithDictionary:templateData];
        [self.lynxView loadTemplate:self.data withURL:params.sourceUrl initData:initialData];
    } else {
        [self.lynxView loadTemplate:self.data withURL:params.sourceUrl];
    }
}

- (void)loadLynxWithParams:(FHLynxViewBaseParams *)params {
    if (!params) return;
    self.params = params;
    
    if (params.channel) {
        self.channel = params.channel;
    }
    
    [self addSubview:self.lynxView];
    
    NSData *tempLateData = [[FHLynxManager sharedInstance] lynxDataForChannel:self.channel templateKey:[FHLynxManager defaultJSFileName] version:0];
    [self.lynxView loadTemplate:tempLateData withURL:@"local"];
}

#pragma mark - reload Lynx
- (void)reloadWithBaseParams:(FHLynxViewBaseParams *)params data:(NSData *)data
{
    _params = params;
    [self.lynxView setHidden:NO];
    if (data) {
        _data = data;
        [self loadLynxBaseParams:params];
    }
}

- (void)reload
{
    [self reloadWithBaseParams:self.params data:self.data];
}

- (void)updateData:(NSDictionary *)dict
{
    if (!dict) return;
    NSError *error = nil;
    [_lynxView updateDataWithString:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding]];
}

#pragma mark - Bridge Handler
- (void)registerHandler:(FHLynxViewBridgeHandler)handler forMethod:(NSString *)method
{
//    [self.lynxView.bridge registerHandler:^(LynxView * _Nonnull lynxView, NSString * _Nonnull name, NSDictionary * _Nullable params, void (^ _Nonnull callback)(BDLynxBridgeStatusCode, NSDictionary * _Nullable)) {
//        handler(lynxView, name, params, callback);
//    } forMethod:method];
}

#pragma mark - BDLynxClientLifeCycleDelegate
- (void)viewDidChangeIntrinsicContentSize:(CGSize)size
{
    if ([self.lynxDelegate respondsToSelector:@selector(viewDidChangeIntrinsicContentSize:)]) {
        [self.lynxDelegate viewDidChangeIntrinsicContentSize:size];
    }
}

#pragma mark - Accessors
- (LynxView *)lynxView
{
    if (!_lynxView) {
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        __weak typeof(self) weakSelf = self;
        _lynxView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
               builder.isUIRunningMode = YES;
               builder.config = [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
               [builder.config registerModule:[FHLynxCoreBridge class]];
               if(weakSelf.params.clsPrivate){
                  [builder.config registerModule:weakSelf.params.clsPrivate param:weakSelf.params.bridgePrivate];
               }
          }];
        _lynxView.layoutWidthMode = LynxViewSizeModeExact;
        _lynxView.layoutHeightMode = LynxViewSizeModeUndefined;
        _lynxView.preferredLayoutWidth = _lynxViewFrame.size.width;
        _lynxView.preferredMaxLayoutWidth = _lynxViewFrame.size.width;
        _lynxView.preferredLayoutHeight = _lynxViewFrame.size.height;
        _lynxView.preferredMaxLayoutHeight = _lynxViewFrame.size.height;
        _lynxView.client = self;
        [_lynxView triggerLayout];
        _lynxView.frame = CGRectMake(0, 0, _lynxView.intrinsicContentSize.width, _lynxView.intrinsicContentSize.height);
    }
    return _lynxView;
}

#pragma mark - LynxClient
- (void)lynxViewDidFirstScreen:(LynxView*)view{
    NSTimeInterval costTime = [[NSDate date] timeIntervalSince1970] - _loadTime;
    [self sendCostTimeEvent:costTime andService:@"lynx_page_duration"];
    [self sendEvent:@"0" andError:nil];
    
    [BDWebViewBlankDetect detectBlankByOldSnapshotWithView:view CompleteBlock:^(BOOL isBlank, UIImage * _Nonnull image, NSError * _Nonnull error) {
        if (isBlank) {
            NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
            [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
            NSMutableDictionary *uploadParams = [NSMutableDictionary new];
            [uploadParams setValue:error.description forKey:@"error"];
            [uploadParams setValue:self.channel forKey:@"channel"];
            [[HMDTTMonitor defaultManager] hmdTrackService:@"lynx_template_black_error" metric:uploadParams category:nil extra:paramsExtra];
        }
    }];
}

- (void)lynxView:(LynxView *)view didRecieveError:(NSError *)error{
    [self sendEvent:@"1" andError:error];

}

- (void)lynxView:(LynxView *)view didLoadFailedWithUrl:(NSString *)url error:(NSError *)error{
    [self sendEvent:@"2" andError:error];
}

- (void)sendEvent:(NSString *)statusStr andError:(NSError *)error
{
    NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
    [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    NSMutableDictionary *uploadParams = [NSMutableDictionary new];
    [uploadParams setValue:error.description forKey:@"error"];
    [uploadParams setValue:statusStr forKey:@"status"];
    [[HMDTTMonitor defaultManager] hmdTrackService:@"lynx_template_data_error" metric:uploadParams category:nil extra:paramsExtra];
}

- (void)sendCostTimeEvent:(NSTimeInterval)time andService:(NSString *)sevice
{
    NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
    [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
     NSMutableDictionary *uploadParams = [NSMutableDictionary new];
     [uploadParams setValue:@(time) forKey:@"lynx_page_duration"];
    [[HMDTTMonitor defaultManager] hmdTrackService:sevice metric:uploadParams category:nil extra:paramsExtra];
}


//这里接收TTLynxViewClient抛上来的sizeChange事件
- (void)lynxViewDidChangeIntrinsicContentSize:(LynxView*)view {
    
}

- (NSURL*)shouldRedirectImageUrl:(NSURL*)url {
  return url;
}

- (void)loadImageWithURL:(nonnull NSURL*)url
                    size:(CGSize)targetSize
              completion:(nonnull LynxImageLoadCompletionBlock)completionBlock {
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
                UIImage *imagePlaceholder = [UIImage imageNamed:@"house_cell_placeholder"];
                if (imagePlaceholder) {
                    completionBlock(imagePlaceholder, nil, url);
                }
            }else{
                completionBlock(image, error, url);
            }
        }];
    }else{
        [[SDWebImageManager sharedManager] loadImageWithURL:url
          options:0
          progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL* _Nullable targetURL) {

          }
          completed:^(UIImage* _Nullable image, NSData* _Nullable data, NSError* _Nullable error,
                      SDImageCacheType cacheType, BOOL finished, NSURL* _Nullable imageURL) {
            if (error) {
                UIImage *imagePlaceholder = [UIImage imageNamed:@"house_cell_placeholder"];
                if (imagePlaceholder) {
                    completionBlock(imagePlaceholder, nil, url);
                }
            }else{
                completionBlock(image, error, url);
            }
        }];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

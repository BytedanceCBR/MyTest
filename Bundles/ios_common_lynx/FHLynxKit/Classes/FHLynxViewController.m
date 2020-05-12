//
//  FHLynxViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/5/11.
//

#import "FHLynxViewController.h"

#import <Lynx/LynxView.h>
#import <mach/mach_time.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"
#import "FHLynxManager.h"
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"
#import <SDWebImage/SDWebImageManager.h>
#import "UIDevice+BTDAdditions.h"

@interface FHLynxViewController ()<LynxViewClient>
@property (nonatomic, assign) NSTimeInterval loadTime; //页面加载时间
@property(nonatomic ,strong) NSData *currentTemData;
@property(nonatomic ,strong) NSString *titleStr;

@end

@implementation FHLynxViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
      
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        
        CGFloat top = 0;
         if (@available(iOS 13.0 , *)) {
           top = 44.f + [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
         } else if (@available(iOS 11.0 , *)) {
           top = MAX(65, self.view.safeAreaInsets.top);
         } else {
           top = 65;
         }
        
        if (!_lynxView) {
          _lynxView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
                 builder.isUIRunningMode = YES;
                 builder.config = [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
                 [builder.config registerModule:[FHLynxCoreBridge class]];
                 builder.frame = CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - top);

            }];
          _lynxView.layoutWidthMode = LynxViewSizeModeExact;
          _lynxView.layoutHeightMode = LynxViewSizeModeUndefined;
          _lynxView.preferredLayoutWidth = screenFrame.size.width;
          _lynxView.client = self;
          _lynxView.preferredMaxLayoutHeight = screenFrame.size.height - top;
          [_lynxView triggerLayout];
                       
          _titleStr = paramObj.allParams[@"title"];
          NSString *channelName = paramObj.allParams[@"channel_name"];
            
          NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:channelName templateKey:[FHLynxManager defaultJSFileName] version:0];
//          templateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.95.249.250:30334/common_question/template.js?1589254996582"]];
            
          
          NSMutableDictionary *dataParams = [NSMutableDictionary new];
          NSMutableDictionary *dataCommonparmas = [NSMutableDictionary new];
          [dataCommonparmas setValue:@(screenFrame.size.height - top) forKey:@"display_height"];
          [dataCommonparmas setValue:@(screenFrame.size.width) forKey:@"display_width"];
          [dataCommonparmas setValue:@([UIDevice btd_isIPhoneXSeries]) forKey:@"iOS_iPhoneXSeries"];
          [dataParams setValue:dataCommonparmas forKey:@"common_params"];
            
          if (paramObj.allParams) {
              [dataParams addEntriesFromDictionary:paramObj.allParams];
          }
          
          if (templateData) {
                if (templateData != self.currentTemData) {
                   NSNumber *costTime = @(0);
                   _loadTime = [[NSDate date] timeIntervalSince1970];
                    self.currentTemData = templateData;
                   [self.lynxView loadTemplate:templateData withURL:@"local"];
              
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataParams options:0 error:0];
                    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [self.lynxView updateDataWithString:dataStr];
                }
          }
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:_lynxView];

    [self setupDefaultNavBar:YES];
    
    self.title = _titleStr;
    
 
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.lynxView onEnterForeground];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.lynxView onEnterBackground];
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
        [self.lynxView loadTemplate:self.currentTemData withURL:params.sourceUrl initData:initialData];
    } else {
        [self.lynxView loadTemplate:self.currentTemData withURL:params.sourceUrl];
    }
}

- (void)updateData:(NSDictionary *)dict
{
    if (!dict) return;
    NSError *error = nil;
    [_lynxView updateDataWithString:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding]];
}

- (NSDictionary *)elementHouseShowUpload
{
    return @{};
}

- (void)vc_viewDidAppear:(BOOL)animated {
    
}

- (void)vc_viewDidDisappear:(BOOL)animated {
   
      
}

- (void)fh_willDisplayCell {
    
}

- (void)fh_didEndDisplayingCell{

}

#pragma mark - LynxClient
- (void)lynxViewDidFirstScreen:(LynxView*)view{
    NSTimeInterval costTime = [[NSDate date] timeIntervalSince1970] - _loadTime;
    [self sendCostTimeEvent:costTime andService:@"lynx_page_duration"];
    [self sendEvent:@"0" andError:nil];
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
    
//    if(url.host && [url.host isEqualToString:@"gecko"]){
//        
//    }

  [[SDWebImageManager sharedManager] loadImageWithURL:url
      options:0
      progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL* _Nullable targetURL) {

      }
      completed:^(UIImage* _Nullable image, NSData* _Nullable data, NSError* _Nullable error,
                  SDImageCacheType cacheType, BOOL finished, NSURL* _Nullable imageURL) {
        completionBlock(image, error, url);
      }];
}
//
//- (dispatch_block_t)loadImageWithURL:(NSURL*)url
//       size:(CGSize)targetSize
//contextInfo:(nullable NSDictionary*)contextInfo
//                          completion:(LynxImageLoadCompletionBlock)completionBlock{
//    return nil;
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

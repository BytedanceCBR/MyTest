//
//  FHLynxDebugVC.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxDebugVC.h"
#import "FHLynxModule.h"
#import "LynxView.h"
#import "LynxViewClient.h"
#import "UIImageView+WebCache.h"

#import <mach/mach_time.h>

@interface DemoLynxViewClient : NSObject <LynxViewClient>

@end

@implementation DemoLynxViewClient

- (NSURL*)shouldRedirectImageUrl:(NSURL*)url {
  return url;
}

- (void)loadImageWithURL:(nonnull NSURL*)url
                    size:(CGSize)targetSize
              completion:(nonnull LynxImageLoadCompletionBlock)completionBlock {
  [[SDWebImageManager sharedManager] loadImageWithURL:url
      options:0
      progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL* _Nullable targetURL) {

      }
      completed:^(UIImage* _Nullable image, NSData* _Nullable data, NSError* _Nullable error,
                  SDImageCacheType cacheType, BOOL finished, NSURL* _Nullable imageURL) {
        completionBlock(image, error, url);
      }];
}

- (void)lynxViewDidUpdate:(LynxView*)view {
  NSLog(@"lynx_client%@", @"lynxViewDidUpdate");
}

- (void)lynxViewDidFirstScreen:(LynxView*)view {
  NSLog(@"lynx_client%@", @"lynxViewDidFirstScreen");
}

@end

@interface FHLynxDebugVC ()

@end

@implementation FHLynxDebugVC{
  LynxView* _lynxView;
  CGRect _lynxViewFrame;
  DemoLynxViewClient* _delegate;
  LynxGroup* _group;
}

- (void)viewDidLoad {
  // app启动或者app从后台进入前台都会调用这个方法
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(notifyApplicationBecomeActive)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];

  // 添加检测app进入后台的观察者
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(notifyApplicationEnterBackground)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];

  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  UILabel* titleLabel = [[UILabel alloc] initWithFrame:self.navigationItem.accessibilityFrame];
  titleLabel.text = @"Demo";
  titleLabel.textColor = [UIColor blackColor];
  self.navigationItem.titleView = titleLabel;
  self.navigationController.navigationBar.tintColor = [UIColor blackColor];

  UIBarButtonItem* rightItem =
      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RefreshIcon"]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(reloadTemplate)];
  rightItem.accessibilityHint = @"Reload";
  rightItem.accessibilityValue = @"Reload";
  rightItem.tintColor = [UIColor blackColor];
  self.navigationItem.rightBarButtonItem = rightItem;

  CGRect screenFrame = [UIScreen mainScreen].bounds;
  _lynxViewFrame = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height);
  _group = [[LynxGroup alloc] initWithName:@"debug"];
  [self reloadTemplate];
  [[self view] insertSubview:_lynxView atIndex:0];
}

- (void)reloadTemplate {
  if (!_lynxView) {
    _lynxView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
      builder.isUIRunningMode = YES;
      builder.config =
          [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
      [builder.config registerModule:FHLynxModule.class];
      builder.group = self->_group;
      builder.frame = self->_lynxViewFrame;
    }];
    [[self view] insertSubview:_lynxView atIndex:0];
    _delegate = [DemoLynxViewClient new];
    _lynxView.client = _delegate;
  }
  if (self.data) {
    [_lynxView loadTemplate:self.data withURL:@"local"];
  } else if (self.url) {
    // Add params to url for reload url from remote without cache
    BOOL hasParams = [self.url rangeOfString:@"?"].location != NSNotFound;
    NSString* seperator = hasParams ? @"&" : @"?";
    NSString* url = [self.url stringByAppendingFormat:@"%@t=%llu", seperator, mach_absolute_time()];
    [_lynxView loadTemplateFromURL:url];
  } else {
    NSAssert(false, @"url or data should set for DemoViewController");
  }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"crowd":@"21223万",@"content": @"权健真相123123123：调查组进驻调查！线上销售已全面遭到“封禁..."} options:0 error:0];
    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    LynxTemplateData *data = [[LynxTemplateData alloc] initWithJson:dataStr];
    [_lynxView updateDataWithTemplateData:data];

  //  __weak LynxView* weakLynxView = _lynxView;
  //  double delayInSeconds = 5.0;
  //  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  //  dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
  //    [weakLynxView updateDataWithString:@"{\"isNew\": false}"];
  //  });
}

- (void)notifyApplicationBecomeActive {
  [_lynxView onEnterForeground];
}

- (void)notifyApplicationEnterBackground {
  [_lynxView onEnterBackground];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

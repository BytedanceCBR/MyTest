//
//  FHLynxScanVC.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxScanVC.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FHLynxDebugVC.h"

static NSString* kScanHistoryKey = @"scan_history";
static NSString* kUrlInTextFieldKey = @"url_in_text_field";

@implementation History

+ (void)recordScanResult:(NSString*)url {
  NSMutableArray* history =
      [[[NSUserDefaults standardUserDefaults] objectForKey:kScanHistoryKey] mutableCopy];
  if (!history) {
    history = [NSMutableArray new];
  }
  if ([history containsObject:url]) {
    [history removeObject:url];
  }
  if ([history count] >= 10) {
    [history removeLastObject];
  }
  [history insertObject:url atIndex:0];
  [[NSUserDefaults standardUserDefaults] setObject:history forKey:kScanHistoryKey];
}

+ (NSArray<NSString*>*)getScanHistory {
  return [[[NSUserDefaults standardUserDefaults] objectForKey:kScanHistoryKey] mutableCopy];
}

+ (void)recordUrlInTextField:(NSString*)url {
  [[NSUserDefaults standardUserDefaults] setObject:url forKey:kUrlInTextFieldKey];
}

+ (NSString*)getHistoryUrlInTextField {
  return [[[NSUserDefaults standardUserDefaults] objectForKey:kUrlInTextFieldKey] mutableCopy];
}

@end

@interface FHLynxScanVC ()

@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;
@property(nonatomic, strong) UIView *sanFrameView;
@end

@implementation FHLynxScanVC

- (void)viewDidLoad {
  [super viewDidLoad];
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.navigationItem.title = @"Scan";

  // Right btn of navigation item
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"history"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(pushScanHistoryVC)];
  rightItem.accessibilityHint = @"Scan History";
  rightItem.accessibilityValue = @"Scan History";
  rightItem.tintColor = [UIColor blackColor];
  self.navigationItem.rightBarButtonItem = rightItem;

  [self prepareForScan];
}

- (void)prepareForScan {
#if !(TARGET_IPHONE_SIMULATOR)
  _captureSession = [[AVCaptureSession alloc] init];
  [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
  AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
  if (output && input && device) {
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_captureSession addInput:input];
    [_captureSession addOutput:output];
    output.metadataObjectTypes = @[
      AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code,
      AVMetadataObjectTypeCode128Code
    ];
  }

  _captureLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
  _captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  _captureLayer.frame = self.view.layer.bounds;
#endif
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:NO];
  [self.view.layer addSublayer:_captureLayer];
  [_captureSession startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  [_captureLayer removeFromSuperlayer];
  [_captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
    didOutputMetadataObjects:(NSArray *)metadataObjects
              fromConnection:(AVCaptureConnection *)connection {
  [_captureLayer removeFromSuperlayer];
  [_captureSession stopRunning];
  if (metadataObjects.count > 0) {
    AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
    [self pushDemoVCWithUrl:metadataObject.stringValue];
  }
}

- (void)pushDemoVCWithUrl:(NSString *)url {
  [History recordScanResult:url];
  FHLynxDebugVC *demoVC = [FHLynxDebugVC new];
  demoVC.url = @"local";
  demoVC.data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
  [[self navigationController] pushViewController:demoVC animated:YES];
}

- (void)pushScanHistoryVC {
//  ScanHistoryViewController *historyVC = [ScanHistoryViewController new];
//  [[self navigationController] pushViewController:historyVC animated:YES];
}

- (NSString *)processUrl:(NSString *)url {
  url = [self decodeFromPercentEscapeString:url];
  if ([url hasPrefix:@"sslocal://lynxview?"]) {
    NSArray<NSString *> *array = [url componentsSeparatedByString:@"?"];
    if ([array count] > 1) {
      url = [array objectAtIndex:1];
    }
  }
  return url;
}

- (NSString *)decodeFromPercentEscapeString:(NSString *)string {
  return [string stringByRemovingPercentEncoding];
}

@end

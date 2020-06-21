//
//  FHLynxCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxCell.h"

#import <Lynx/LynxView.h>
#import <mach/mach_time.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"
#import "FHLynxManager.h"
#import "SDWebImageManager.h"

@interface FHLynxCell()<LynxViewClient>

@end

@implementation FHLynxCell

+ (Class)cellViewClass
{
    return [self class];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        if (!_lynxView) {
          _lynxView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
                 builder.isUIRunningMode = YES;
                 builder.config = [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
                 [builder.config registerModule:[FHLynxCoreBridge class]];
            }];
          _lynxView.layoutWidthMode = LynxViewSizeModeExact;
          _lynxView.layoutHeightMode = LynxViewSizeModeUndefined;
          _lynxView.preferredLayoutWidth = screenFrame.size.width;
          _lynxView.client = self;
          _lynxView.preferredMaxLayoutHeight = screenFrame.size.height;
          [_lynxView triggerLayout];
          self.contentView.backgroundColor = [UIColor whiteColor];
          [self.contentView addSubview:_lynxView];
        }
    }
    return self;
}

- (void)refreshWithData:(id)data {
    
//    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"test_ios" templateKey:[FHLynxManager defaultJSFileName] version:0];
//
//    // sub implements.........
////    NSString *instr = [NSString stringWithFormat:@"%ld", 0];
////    NSString *prifix = @"recycler";
////    NSString *path = [prifix stringByAppendingString:instr];
////    NSString *templatePath = [[NSBundle mainBundle] pathForResource:path ofType:@"js"];
////    NSData *templateData = [NSData dataWithContentsOfFile:templatePath];
////    [self.lynxView loadTemplate:templateData withURL:@"local"];
//    NSData *dataTemp = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://192.168.1.2:30334/operation/template.js?1587737161908"]];
//
////    [self.lynxView loadTemplateFromURL:@"http://10.95.249.250:30334/card1/template.js?1587635520991"];
//    [self.lynxView loadTemplate:dataTemp withURL:@"local"];
//     self.lynxView.client = self;
//
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"crowd":@"21223万",@"content": @"权健真相123123123：调查组进驻调查！线上销售已全面遭到“封禁...调查组进驻调查！线上销售已全面遭到“封禁...调查组进驻调查！线上销售已全面遭到“封禁...调查组进驻调查！线上销售已全面遭到“封禁..."} options:0 error:0];
//    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    LynxTemplateData *dataItem = [[LynxTemplateData alloc] initWithJson:dataStr];
//    [_lynxView updateDataWithTemplateData:dataItem];
    
//      NSData *dataTemp = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://172.20.10.5:30334/operation/template.js?1587740635541"]];
//        
//    //    [self.lynxView loadTemplateFromURL:@"http://10.95.249.250:30334/card1/template.js?1587635520991"];
//        [self.lynxView loadTemplate:dataTemp withURL:@"local"];
//         self.lynxView.client = self;
//        
//                
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"img_url":@"http://p9.pstatp.com//origin//321b70007ed31a86a98cb",@"img_height":@(58),@"img_width":@(400),@"jump_url":@"xxx"} options:0 error:0];
//        NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        LynxTemplateData *dataItem = [[LynxTemplateData alloc] initWithJson:dataStr];
//        [self.lynxView updateDataWithTemplateData:dataItem];
}

#pragma mark - reload Lynx
- (void)reloadWithBaseParams:(FHLynxViewBaseParams *)params data:(NSData *)data
{
    _params = params;
    [self.lynxView setHidden:NO];
    if (data) {
        [self loadLynxBaseParams:params];
    }
}

- (void)reload
{
    [self reloadWithBaseParams:self.params data:self.currentData];
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
        [self.lynxView loadTemplate:self.currentData withURL:params.sourceUrl initData:initialData];
    } else {
        [self.lynxView loadTemplate:self.currentData withURL:params.sourceUrl];
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

//这里接收TTLynxViewClient抛上来的sizeChange事件
- (void)lynxViewDidChangeIntrinsicContentSize:(LynxView*)view {
    if (CGSizeEqualToSize(self.cacheSize, view.frame.size)) {
        return;
    }

    self.cacheSize = view.frame.size;
    UITableView *tableView = self.tableView;
    if ([tableView isKindOfClass:[UITableView class]]) {
        NSIndexPath *indexPath = [tableView indexPathForCell:self];
        if (indexPath) {
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

            [CATransaction commit];
        }
    }
}

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

+ (CGFloat)heightForData:(id)data {
    //默认返回cell的默认值44;
    return 44;
}

@end

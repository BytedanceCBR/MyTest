//
//  FHUGCLynxBannerCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/24.
//

#import "FHUGCLynxBannerCell.h"
#import <Lynx/LynxView.h>

#import <mach/mach_time.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"
#import "FHLynxManager.h"

@interface FHUGCLynxBannerCell()<LynxViewLifecycle,LynxViewClient>

@property(nonatomic ,strong) UIView *bottomSepView;

@end

@implementation FHUGCLynxBannerCell
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
            [_lynxView addLifecycleClient:self];
          _lynxView.preferredMaxLayoutHeight = screenFrame.size.height;
          [_lynxView triggerLayout];
          self.contentView.backgroundColor = [UIColor whiteColor];
          [self.contentView addSubview:_lynxView];
            
          self.bottomSepView = [[UIView alloc] init];
          _bottomSepView.backgroundColor = [UIColor themeGray7];
          [self.contentView addSubview:_bottomSepView];
            
        }
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;

    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:kFHLynxUGCOperationChannel templateKey:[FHLynxManager defaultJSFileName] version:0];
        
//    NSData *dataTemp = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://192.168.1.2:30334/operation/template.js?1587745910470"]];
        
    //  [self.lynxView loadTemplateFromURL:@"http://10.95.249.250:30334/card1/template.js?1587635520991"];
    if (templateData) {
        [self.lynxView loadTemplate:templateData withURL:@"local"];

        NSMutableDictionary *dataJson = [NSMutableDictionary new];
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        if (imageModel.url) {
            [dataJson setValue:imageModel.url forKey:@"img_url"];
        }
        
        [dataJson setValue:cellModel.openUrl forKey:@"jump_url"];
        CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width - 40;
        [dataJson setValue:@(imageWidth * 58.0/335.0) forKey:@"img_height"];
        [dataJson setValue:@(imageWidth) forKey:@"img_width"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataJson options:0 error:0];
        NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        LynxTemplateData *dataItem = [[LynxTemplateData alloc] initWithJson:dataStr];
        [self.lynxView updateDataWithTemplateData:dataItem];
    }
}

#pragma mark - reload Lynx
- (void)reloadWithBaseParams:(FHLynxViewBaseParams *)params data:(NSData *)data
{
//    _params = params;
//    [self.lynxView setHidden:NO];
//    if (data) {
//        [self loadLynxBaseParams:params];
//    }
}

- (void)reload
{
//    [self reloadWithBaseParams:self.params data:self.currentData];
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
    
    self.bottomSepView.frame = CGRectMake(0.0f,self.lynxView.frame.origin.y + view.frame.size.height, [UIScreen mainScreen].bounds.size.height, 5);
    
    if (CGSizeEqualToSize(self.cacheSize, view.frame.size)) {
        return;
    }

    self.cacheSize = view.frame.size;

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
    
    CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width - 40;
    CGFloat imageHeight = imageWidth * 58.0/335.0;
   __block CGFloat height = imageHeight + 20 + 25;
    
    if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
        FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
        if ([model.cell isKindOfClass:[FHUGCLynxBannerCell class]]) {
            height =  [((FHUGCLynxBannerCell *)model.cell).lynxView intrinsicContentSize].height + 5;
        }
     
    }
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end

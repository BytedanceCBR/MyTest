//
//  FHUGCLynxCommonCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/5/6.
//

#import "FHUGCLynxCommonCell.h"

#import <Lynx/LynxView.h>
#import <mach/mach_time.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"
#import "FHLynxManager.h"
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"
@interface FHUGCLynxCommonCell()<LynxViewClient>

@property(nonatomic ,strong) UIView *bottomSepView;
@property (nonatomic, assign) NSTimeInterval loadTime; //页面加载时间
@property (nonatomic, strong) NSString *currentReuseIdentifier;
@end

@implementation FHUGCLynxCommonCell
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
            
          self.bottomSepView = [[UIView alloc] init];
          _bottomSepView.backgroundColor = [UIColor themeGray7];
          [self.contentView addSubview:_bottomSepView];
        
           NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:reuseIdentifier templateKey:[FHLynxManager defaultJSFileName] version:0];
            
           if (templateData) {
                if (templateData != self.currentTemData) {
                   NSNumber *costTime = @(0);
                   _loadTime = [[NSDate date] timeIntervalSince1970];
                    self.currentTemData = templateData;
                    self.currentReuseIdentifier = reuseIdentifier;
                   [self.lynxView loadTemplate:templateData withURL:@"local"];
                }
            }
        }
    }
    return self;
}

- (void)refreshWithData:(id)data {
    
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    if (self.currentData == data) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    NSDictionary *lynxData = cellModel.lynxData;
    
    if (!self.currentTemData) {
        NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:self.currentReuseIdentifier templateKey:[FHLynxManager defaultJSFileName] version:0];
        if (!templateData) {
            return;
        }
        self.currentTemData = templateData;
        NSNumber *costTime = @(0);
        _loadTime = [[NSDate date] timeIntervalSince1970];
    
        [self.lynxView loadTemplate:templateData withURL:@"local"];
    }
    
    NSMutableDictionary *dataJson = [NSMutableDictionary new];

    if([lynxData isKindOfClass:[NSDictionary class]]){
        [dataJson addEntriesFromDictionary:lynxData];
    }
    
    if (cellModel.tracerDic) {
        NSMutableDictionary *reprotPamrams = [NSMutableDictionary new];
        if ([cellModel.tracerDic isKindOfClass:[NSDictionary class]])  {
            [reprotPamrams addEntriesFromDictionary:cellModel.tracerDic];
        }
        reprotPamrams[@"description"] = cellModel.desc;
        reprotPamrams[@"item_title"] = cellModel.title;
        reprotPamrams[@"item_id"] = cellModel.groupId;
        [dataJson setValue:reprotPamrams forKey:@"report_params"];
    }
    
    if (dataJson) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataJson options:0 error:0];
        NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        LynxTemplateData *dataItem = [[LynxTemplateData alloc] initWithJson:dataStr];
        [self.lynxView updateDataWithTemplateData:dataItem];
    }

    
    self.currentData = data;
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
    
    CGFloat imageHeight = 0;
    CGFloat height = imageHeight + 5;

    if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
        FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
        if ([model.cell isKindOfClass:[FHUGCLynxCommonCell class]]) {
            height =  [((FHUGCLynxCommonCell *)model.cell).lynxView intrinsicContentSize].height + 5;
        }
    }
    
    if (height == 5) {
        height = 0;
    }
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        if ([self.currentData isKindOfClass:[FHFeedUGCCellModel class]]) {
            FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
            [self.delegate deleteCell:cellModel];
        }
    }
}

@end

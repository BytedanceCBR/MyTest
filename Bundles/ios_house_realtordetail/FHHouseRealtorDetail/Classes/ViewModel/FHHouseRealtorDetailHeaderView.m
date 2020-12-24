//
//  FHHouseRealtorDetailHeaderView.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/14.
//

#import "FHHouseRealtorDetailHeaderView.h"
#import <Lynx/LynxView.h>
#import "Masonry.h"
#import "FLynxWikiHeaderBridge.h"
#import "FHLynxManager.h"
#import "NSObject+YYModel.h"
#import "IESGeckoKit.h"
#import "FHIESGeckoManager.h"
#import "SDWebImageManager.h"
#import "UIColor+Theme.h"
#import "LynxEnv.h"
#import "FHCommonDefines.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseRealtorDetailInfoModel.h"
#import "UIDevice+BTDAdditions.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "HMDTTMonitor.h"


@interface FHHouseRealtorDetailHeaderView ()
@property (weak, nonatomic)LynxView *realtorInfoView;
@property(nonatomic ,strong) NSData *currentTemData;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (weak, nonatomic) UIImageView *headerIma;
@property (weak, nonatomic) UIView *headerMaskView;
@property (assign, nonatomic) CGFloat navHeight;
@property (nonatomic, assign) NSTimeInterval loadTime; //页面加载时间
@property (nonatomic, assign) BOOL isHeightScoreRealtor; //是否为高分经纪人
@property(nonatomic) CGFloat headerBackHeight;

@end
@implementation FHHouseRealtorDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.navHeight =   ((![[UIApplication sharedApplication] isStatusBarHidden]) ? [[UIApplication sharedApplication] statusBarFrame].size.height : ([UIDevice btd_isIPhoneXSeries]?44.f:20.f));
        self.isHeightScoreRealtor = NO;
        [self createUI];
        self.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
    }
    return self;
}


- (void)createUI {
    self.headerBackHeight = 164;
    [self headerIma];
    [self titleImage];
    [self.headerMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.headerIma);
    }];
    [self.realtorInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self).offset(self.navHeight+44);
    }];
}

- (UIImageView *)titleImage {
    if (!_titleImage) {
        UIImageView *titleImage = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH -305)/2, 64+self.navHeight, 305, 23)];
        titleImage.image = [UIImage imageNamed:@"image_title"];
        titleImage.clipsToBounds = YES;
        titleImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:titleImage];
        titleImage.hidden = YES;
        _titleImage = titleImage;
    }
    return _titleImage;
}

- (void)updateWhenScrolledWithContentOffset:(CGFloat)offset isScrollTop:(BOOL)isScrollTop scrollView:(UIScrollView *)scrollView {
    
    if (self.isHeightScoreRealtor) {
        self.titleImage.frame = CGRectMake((SCREEN_WIDTH -305)/2,64 + offset+self.navHeight, 305, 23);
        self.titleImage.hidden = offset > 0;
    }
        if (offset < 0 && offset>= -150) {
            CGFloat height = SCREEN_WIDTH - offset;
            self.headerIma.frame = CGRectMake(0,-(SCREEN_WIDTH-self.headerBackHeight) + offset, SCREEN_WIDTH, height);
        }else if( offset< -150 && offset >= -(SCREEN_WIDTH-self.headerBackHeight)) {
            CGFloat height = SCREEN_WIDTH + 150;
            self.headerIma.frame = CGRectMake(0, -(SCREEN_WIDTH-self.headerBackHeight) - 150 - (offset + 150)*0.1    , SCREEN_WIDTH, height);
        }else if ( offset < -(SCREEN_WIDTH-self.headerBackHeight)){
            CGFloat height = SCREEN_WIDTH + 150;
            self.headerIma.frame = CGRectMake(0, -(SCREEN_WIDTH-self.headerBackHeight) - 150 - (offset + 150)*0.1 + (offset+(SCREEN_WIDTH-self.headerBackHeight)), SCREEN_WIDTH, height);
        } else {
            self.headerIma.frame = CGRectMake(0, -(SCREEN_WIDTH-self.headerBackHeight), SCREEN_WIDTH, SCREEN_WIDTH);
        }
    
}

- (void)updateRealtorWithHeightScore {
    self.isHeightScoreRealtor = YES;
    self.headerIma.image = [UIImage imageNamed:@"realtor_bac"];
}

- (LynxView *)realtorInfoView {
    if (!_realtorInfoView) {
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        LynxView *realtorInfoView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
            builder.isUIRunningMode = YES;
            builder.config = [[LynxConfig alloc] initWithProvider:[LynxEnv sharedInstance].config.templateProvider];
            [builder.config registerModule:[FHLynxCoreBridge class] param:self];
        }];
        realtorInfoView.layoutWidthMode = LynxViewSizeModeExact;
        realtorInfoView.layoutHeightMode = LynxViewSizeModeUndefined;
        realtorInfoView.preferredLayoutWidth = screenFrame.size.width;
        realtorInfoView.client = self;
        realtorInfoView.preferredMaxLayoutHeight = screenFrame.size.height;
        [realtorInfoView triggerLayout];
        [self addSubview:realtorInfoView];
        _realtorInfoView = realtorInfoView;
    }
    return _realtorInfoView;
}

- (UIView *)headerMaskView {
    if (!_headerMaskView) {
        UIView *headerMaskView = [[UIView alloc]init];
        headerMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
        [self.headerIma addSubview:headerMaskView];
        _headerMaskView = headerMaskView;
    }
    return _headerMaskView;
}
- (void)updateModel:(FHHouseRealtorDetailInfoModel *)model {
    NSString *lynxData = [model yy_modelToJSONString];
    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:_channel templateKey:[FHLynxManager defaultJSFileName] version:0];
    if (templateData) {
        if (templateData != self.currentTemData) {
            self.currentTemData = templateData;
            _loadTime = [[NSDate date] timeIntervalSince1970];
            LynxTemplateData *tem = [[LynxTemplateData alloc]initWithJson:lynxData];
            [self.realtorInfoView loadTemplate:templateData withURL:@"local" initData:tem];
            //使用segments时小数触发计算错误
            self.viewHeight = ceil([self.realtorInfoView intrinsicContentSize].height + self.navHeight + ([_channel isEqualToString:@"lynx_realtor_detail_header"] ?32:44));
        }
    }
}

- (UIImageView *)headerIma {
    if (!_headerIma) {
        UIImageView *headerIma = [[UIImageView alloc]initWithFrame:CGRectMake(0,-(SCREEN_WIDTH-self.headerBackHeight), SCREEN_WIDTH, SCREEN_WIDTH)];
        headerIma.image = [UIImage imageNamed:@"realtor_detail"];
        headerIma.clipsToBounds = YES;
        headerIma.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:headerIma];
        _headerIma = headerIma;
    }
    return _headerIma;
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


#pragma mark - LynxClient
- (void)lynxViewDidFirstScreen:(LynxView*)view{
    NSTimeInterval costTime = [[NSDate date] timeIntervalSince1970] - _loadTime;
    [self sendCostTimeEvent:costTime andService:@"lynx_page_duration"];
}

- (void)sendCostTimeEvent:(NSTimeInterval)time andService:(NSString *)sevice
{
    NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
    [paramsExtra setValue:[BDTrackerProtocol deviceID] forKey:@"device_id"];
    NSMutableDictionary *uploadParams = [NSMutableDictionary new];
    NSString *eventServie = [NSString stringWithFormat:@"lynx_page_duration_%@",_channel];
    if (time < 15) {
        [uploadParams setValue:@(time * 1000) forKey:@"duration"];
        [[HMDTTMonitor defaultManager] hmdTrackService:eventServie metric:uploadParams category:nil extra:paramsExtra];
    }
}

- (void)lynxView:(LynxView*)view didReceiveFirstLoadPerf:(LynxPerformance*)perf{
    
    NSMutableDictionary * paramsExtra = [NSMutableDictionary new];
    [paramsExtra setValue:[BDTrackerProtocol deviceID] forKey:@"device_id"];
    NSMutableDictionary *uploadParams = [NSMutableDictionary new];
    if (perf && [[perf toDictionary] isKindOfClass:[NSDictionary class]]) {
        [uploadParams addEntriesFromDictionary:[perf toDictionary]];
    }
    NSString *eventServie = [NSString stringWithFormat:@"lynx_page_info_%@",_channel];
    [[HMDTTMonitor defaultManager] hmdTrackService:eventServie metric:uploadParams category:nil extra:paramsExtra];
    
}
- (void)lynxView:(LynxView*)view didReceiveUpdatePerf:(LynxPerformance*)perf{
}

- (void)loadImageWithURL:(nonnull NSURL*)url
                    size:(CGSize)targetSize
              completion:(nonnull LynxImageLoadCompletionBlock)completionBlock {
    completionBlock(self.placeholderImage,nil,nil);
    if([url.absoluteString containsString:@"gecko:"]){
        NSString * imageStr = url.absoluteString;
        NSString *imageRootPath = [IESGeckoKit rootDirForAccessKey:[FHIESGeckoManager getGeckoKey] channel:@""];
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

- (void)setChannel:(NSString *)channel {
    _channel = channel;
    if ([_channel isEqualToString:@"lynx_realtor_detail_header"]) {
        self.headerMaskView.hidden = YES;
    }else {
        [self.realtorInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(self.navHeight+56);
        }];
        self.headerMaskView.hidden = NO;
    }
}

- (void)setBacImageName:(NSString *)bacImageName {
    _bacImageName = bacImageName;
    self.headerIma.image = [UIImage imageNamed:_bacImageName];
}

- (void)setBacImageUrl:(NSString *)bacImageUrl {
    _bacImageUrl = bacImageUrl;
    [self.headerIma bd_setImageWithURL:[NSURL URLWithString:bacImageUrl]];
}

- (void)reloadDataWithDic:(NSDictionary *)dic {
    NSString *lynxData = [dic yy_modelToJSONString];
    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:_channel templateKey:[FHLynxManager defaultJSFileName] version:0];
    if (templateData) {
        if (templateData != self.currentTemData) {
            self.currentTemData = templateData;
            LynxTemplateData *tem = [[LynxTemplateData alloc]initWithJson:lynxData];
            [self.realtorInfoView loadTemplate:templateData withURL:@"local" initData:tem];
        }
        
        self.viewHeight = ceil([self.realtorInfoView intrinsicContentSize].height + self.navHeight + ([_channel isEqualToString:@"lynx_realtor_detail_header"] ?32:44));
    }
}
@end

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
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseRealtorDetailInfoModel.h"
#import "UIDevice+BTDAdditions.h"
@interface FHHouseRealtorDetailHeaderView ()
@property (weak, nonatomic)LynxView *realtorInfoView;
@property(nonatomic ,strong) NSData *currentTemData;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (weak, nonatomic) UIImageView *headerIma;
@end
@implementation FHHouseRealtorDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self createUI];
        self.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
    }
    return self;
}


- (void)createUI {
    
    CGFloat statusBarHeight =  ((![[UIApplication sharedApplication] isStatusBarHidden]) ? [[UIApplication sharedApplication] statusBarFrame].size.height : ([UIDevice btd_isIPhoneXSeries]?44.f:20.f));
    [self.headerIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_offset(164);
    }];
    [self.realtorInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self).offset(statusBarHeight+44);
    }];
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

- (void)updateModel:(FHHouseRealtorDetailInfoModel *)model {
    NSString *lynxData = [model yy_modelToJSONString];
    [_realtorInfoView updateDataWithString:lynxData];
    
}

- (UIImageView *)headerIma {
    if (!_headerIma) {
        UIImageView *headerIma = [[UIImageView alloc]init];
        headerIma.image = [UIImage imageNamed:@"realtor_detail"];
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

- (void)setChannel:(NSString *)channel {
    _channel = channel;
    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:_channel templateKey:[FHLynxManager defaultJSFileName] version:0];
//            NSData *templateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_channel]];
    if (templateData) {
        if (templateData != self.currentTemData) {
            self.currentTemData = templateData;
            [self.realtorInfoView loadTemplate:templateData withURL:@"local"];
        }
        
        CGFloat statusBarHeight =  ((![[UIApplication sharedApplication] isStatusBarHidden]) ? [[UIApplication sharedApplication] statusBarFrame].size.height : ([UIDevice btd_isIPhoneXSeries]?44.f:20.f));
        self.viewHeight = [self.realtorInfoView intrinsicContentSize].height + statusBarHeight + 44;
    }
}

- (void)lynxView:(LynxView*)view didLoadFinishedWithUrl:(NSString*)url {
    CGFloat statusBarHeight =  ((![[UIApplication sharedApplication] isStatusBarHidden]) ? [[UIApplication sharedApplication] statusBarFrame].size.height : ([UIDevice btd_isIPhoneXSeries]?44.f:20.f));
    self.viewHeight = [self.realtorInfoView intrinsicContentSize].height + statusBarHeight + 44;
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
    [_realtorInfoView updateDataWithString:lynxData];
}
@end

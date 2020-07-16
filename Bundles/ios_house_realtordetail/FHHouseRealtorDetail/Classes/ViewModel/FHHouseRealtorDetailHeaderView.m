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
@interface FHHouseRealtorDetailHeaderView ()
@property (weak, nonatomic)LynxView *realtorInfoView;
@property(nonatomic ,strong) NSData *currentTemData;
@property (strong, nonatomic) UIImage *placeholderImage;
@end
@implementation FHHouseRealtorDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
//        [self createUI];
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)createUI {
    [self.realtorInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
}

- (LynxView *)realtorInfoView {
    if (!_realtorInfoView) {
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        LynxView *realtorInfoView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
            builder.isUIRunningMode = YES;
            builder.config = [[LynxConfig alloc] initWithProvider:[LynxEnv sharedInstance].config.templateProvider];
            [builder.config registerModule:[FLynxWikiHeaderBridge class] param:self];
        }];
        realtorInfoView.layoutWidthMode = LynxViewSizeModeExact;
        realtorInfoView.layoutHeightMode = LynxViewSizeModeUndefined;
        realtorInfoView.preferredLayoutWidth = screenFrame.size.width;
        realtorInfoView.client = self;
        realtorInfoView.preferredMaxLayoutHeight = screenFrame.size.height;
        [realtorInfoView triggerLayout];
        [self addSubview:realtorInfoView];
        NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"lynx_realtor_detail_header" templateKey:[FHLynxManager defaultJSFileName] version:0];
        if (templateData) {
            if (templateData != self.currentTemData) {
                self.currentTemData = templateData;
                [realtorInfoView loadTemplate:templateData withURL:@"local"];
            }
        }
        _realtorInfoView = realtorInfoView;
    }
    return _realtorInfoView;
}

- (void)updateModel:(FHHouseRealtorDetailInfoModel *)model {
    NSString *lynxData = [model yy_modelToJSONString];
    [_realtorInfoView updateDataWithString:lynxData];
    
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
@end

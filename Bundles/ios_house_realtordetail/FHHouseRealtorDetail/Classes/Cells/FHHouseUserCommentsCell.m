//
//  FHHouseUserCommentsCell.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHHouseUserCommentsCell.h"
#import <Lynx/LynxView.h>
#import "Masonry.h"
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
#import "FLynxWikiHeaderBridge.h"
@interface FHHouseUserCommentsCell()
@property (weak, nonatomic)LynxView *infoView;
@property(nonatomic ,strong) NSData *currentTemData;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (weak, nonatomic) UIImageView *headerIma;
@end
@implementation FHHouseUserCommentsCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}
- (void)createUI {
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data ) {
        return;
    }
    self.currentData = data;
    [self updateModel:data];
}
- (LynxView *)infoView {
    if (!_infoView) {
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        LynxView *infoView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
            builder.isUIRunningMode = YES;
            builder.config = [[LynxConfig alloc] initWithProvider:[LynxEnv sharedInstance].config.templateProvider];
            [builder.config registerModule:[FHLynxCoreBridge class] param:self];
        }];
        infoView.layoutWidthMode = LynxViewSizeModeExact;
        infoView.layoutHeightMode = LynxViewSizeModeUndefined;
        infoView.preferredLayoutWidth = screenFrame.size.width;
        infoView.client = self;
        infoView.preferredMaxLayoutHeight = screenFrame.size.height;
        [infoView triggerLayout];
        [self addSubview:infoView];
        NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"lynx_evaluation_item" templateKey:[FHLynxManager defaultJSFileName] version:0];
        //        NSData *templateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.95.248.194:30334/realtor_detail_header/template.js?1594963282405"]];
        if (templateData) {
            if (templateData != self.currentTemData) {
                self.currentTemData = templateData;
                [infoView loadTemplate:templateData withURL:@"local"];
            }
        }
        _infoView = infoView;
    }
    return _infoView;
}


- (void)updateModel:(NSDictionary *)dic {
    NSString *lynxData = [dic yy_modelToJSONString];
    [_infoView updateDataWithString:lynxData];
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
@end
@implementation FHHouseUserCommentsModel

@end

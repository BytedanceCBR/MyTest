//
//  FHUGCEncyclopediaLynxCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/18.
//

#import "FHUGCEncyclopediaLynxCell.h"
#import "EncyclopediaModel.h"
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"
#import "FHLynxManager.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <Lynx/LynxView.h>
#import "JSONModel.h"
#import "NSObject+YYModel.h"
#import "FHLynxPageBridge.h"
#import "FHHouseDislikeView.h"
#import "NSDictionary+TTAdditions.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHLynxManager.h"
#import "IESGeckoKit.h"
#import "FHIESGeckoManager.h"
@interface FHUGCEncyclopediaLynxCell()<LynxViewClient>
//@property (weak, nonatomic) UILabel *content;
//@property (weak, nonatomic) UIImageView *icon;
//@property (weak, nonatomic) UILabel *subDes;
//@property (weak, nonatomic) UIButton *closeBtn;
//@property (strong, nonatomic) EncyclopediaItemModel *itemModel;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) LynxView *contentLynxView;

@end

@implementation FHUGCEncyclopediaLynxCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return  self;
}

- (void)initUI {
    [self.contentLynxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.contentView);
    }];
}

- (UIImage *)placeholderImage {
    if (!_placeholderImage) {
        UIImage *placeholderImage = [self createImageWithColor:[UIColor themeGray6]];
        _placeholderImage = placeholderImage;
    }
    return _placeholderImage;
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

- (LynxView *)contentLynxView {
    if (!_contentLynxView) {
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        _contentLynxView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
            builder.isUIRunningMode = YES;
            builder.config = [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
            //            [builder.config registerModule:[FHLynxCoreBridge class]];
            [builder.config registerModule:[FHLynxPageBridge class] param:self];
        }];
        _contentLynxView.layoutWidthMode = LynxViewSizeModeExact;
        _contentLynxView.layoutHeightMode = LynxViewSizeModeUndefined;
        _contentLynxView.preferredLayoutWidth = screenFrame.size.width;
        _contentLynxView.client = self;
        _contentLynxView.preferredMaxLayoutHeight = screenFrame.size.height;
        [_contentLynxView triggerLayout];
        [self.contentView addSubview:_contentLynxView];
        NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"ugc_encyclopedia_lynx_item" templateKey:[FHLynxManager defaultJSFileName] version:0];
        [_contentLynxView loadTemplate:templateData withURL:@"local"];
        if (templateData) {
            [self.contentLynxView loadTemplate:templateData withURL:@"local"];
        }
    }
    return _contentLynxView;
}


- (void)tapClose:(UIButton *)sender {
    
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if(self.currentData == data){
        return;
    }
    self.currentData = data;
    NSMutableDictionary *exDic = [[NSMutableDictionary alloc]initWithDictionary:data];
    [exDic setValue:@([UIScreen mainScreen].bounds.size.width) forKey:@"screen_width"];
    NSString *lynxData = [exDic yy_modelToJSONString];
    [_contentLynxView updateDataWithString:lynxData];
}

- (void)disLike:(id)param {
    NSDictionary *item = [self dictionaryWithJsonString:param];
    CGPoint point = CGPointMake([item[@"x"] floatValue], [item[@"y"] floatValue]);
    point = [self.contentView convertPoint:point toView:[self superview]];
    __weak typeof(self) wself = self;
    FHHouseDislikeView *dislikeView = [[FHHouseDislikeView alloc] init];
    FHHouseDislikeViewModel *viewModel = [[FHHouseDislikeViewModel alloc] init];
    NSArray *dislikeInfo = (NSDictionary *)self.currentData[@"filter_words"];
    
    NSMutableArray *keywords = [NSMutableArray array];
    for (NSDictionary *filterWordsDic in dislikeInfo) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if(filterWordsDic[@"id"]){
            [dic setObject:filterWordsDic[@"id"] forKey:@""];
        }
        if(filterWordsDic[@"name"]){
            [dic setObject:filterWordsDic[@"name"] forKey:@"name"];
        }
        [keywords addObject:dic];
    }
    
    viewModel.keywords = keywords;
    [dislikeView refreshWithModel:viewModel];
    [dislikeView showAtPoint:point
                    fromView:self
             didDislikeBlock:^(FHHouseDislikeView * _Nonnull view) {
        [wself dislikeConfirm:view];
    }];
}
- (void)dislikeConfirm:(FHHouseDislikeView *)view {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    NSMutableArray *dislikeInfo = [NSMutableArray array];
    for (FHHouseDislikeWord *word in view.dislikeWords) {
        if(word.isSelected){
            [dislikeInfo addObject:@([word.ID integerValue])];
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(dislikeConfirm:cell:)] && self.currentData){
        [self.delegate dislikeConfirm:self.currentData cell:self];
    }
    //    //发起请求
    //    [FHHomeRequestAPI requestHomeHouseDislike:self.homeItemModel.idx houseType:[self.homeItemModel.houseType integerValue] dislikeInfo:dislikeInfo completion:^(bool success, NSError * _Nonnull error) {
    //        if(success){
    //            [[ToastManager manager] showToast:@"感谢反馈，将减少推荐类似房源"];
    //            //代理
    //            if(self.delegate && [self.delegate respondsToSelector:@selector(dislikeConfirm:cell:)] && self.homeItemModel){
    //                [self.delegate dislikeConfirm:self.homeItemModel cell:self];
    //            }
    //        }else{
    //            [[ToastManager manager] showToast:@"反馈失败"];
    //        }
    //    }];
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)tapFHEncyclopediaAction:(NSDictionary *)dic {
    if(self.delegate && [self.delegate respondsToSelector:@selector(tapCellAction:)] && self.currentData){
        [self.delegate tapCellAction:self.currentData];
    }
}
@end

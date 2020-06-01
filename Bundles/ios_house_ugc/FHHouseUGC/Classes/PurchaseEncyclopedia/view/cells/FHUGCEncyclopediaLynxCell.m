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
@interface FHUGCEncyclopediaLynxCell()<LynxViewClient>
//@property (weak, nonatomic) UILabel *content;
//@property (weak, nonatomic) UIImageView *icon;
//@property (weak, nonatomic) UILabel *subDes;
//@property (weak, nonatomic) UIButton *closeBtn;
//@property (strong, nonatomic) EncyclopediaItemModel *itemModel;
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
        
//        NSData *templateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.95.248.197:30334/feedarticlesingleimage/template.js?1590031888301"]];
        NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"ugc_encyclopedia_lynx_item" templateKey:[FHLynxManager defaultJSFileName] version:0];


        [_contentLynxView loadTemplate:templateData withURL:@"local"];
        //        [_contentView loadTemplateFromURL:@"http://10.95.248.197:30334/card2/template.js?1589371322410"];
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
//           if(infoModel.mutualExclusiveIds){
//               [dic setObject:infoModel.mutualExclusiveIds forKey:@"mutual_exclusive_ids"];
//           }
           [keywords addObject:dic];
       }
       
       viewModel.keywords = keywords;
//       viewModel.groupID = self.cellModel.houseId;
//       viewModel.extrasDict = self.homeItemModel.tracerDict;
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

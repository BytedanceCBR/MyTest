//
//  FHNeighborhoodDetailStrategyArticleCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailStrategyArticleCell.h"
#import "UIImageView+BDWebImage.h"
#import <TTBaseMacro.h>
#import "UIDevice+BTDAdditions.h"
#import <UILabel+BTDAdditions.h>


#import "FHLynxView.h"
#import "Masonry.h"
#import "LynxView.h"
#import "NSDictionary+BTDAdditions.h"
@interface FHNeighborhoodDetailStrategyArticleCell ()<FHLynxClientViewDelegate>
@property (nonatomic, strong) UIView *cardBac;
@property (nonatomic, strong) FHLynxView *articleCardView;
@end

@implementation FHNeighborhoodDetailStrategyArticleCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 198);
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.currentData = data;
    NSDictionary *dic = (NSDictionary *)data;
    if (dic) {
        [self reloadDataWithDic:dic];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIs];
    }
    return self;
}

- (void)initUIs {
    [self initViews];
//    [self initConstraints];
}

- (void)initViews {
    self.cardBac = [[UIView alloc]init];
    self.cardBac.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.cardBac];
        [self.cardBac mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(12);
            make.right.equalTo(self.contentView.mas_right).offset(-12);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-12);
        }];
    self.articleCardView = [[FHLynxView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 42, 0)];
    self.articleCardView.lynxDelegate = self;
    [self.cardBac addSubview:self.articleCardView];

}

//- (void)initConstraints {
//    [self.articleCardView mas_makeConstraints:^(MASConstraintMaker *make) {
//          make.edges.equalTo(self.contentView);
//      }];
//}

- (void)reloadDataWithDic:(NSDictionary *)dic {
    FHLynxViewBaseParams *baesparmas = [[FHLynxViewBaseParams alloc] init];
    baesparmas.channel = @"community_evaluation";
    baesparmas.bridgePrivate = self;
    [self.articleCardView loadLynxWithParams:baesparmas];
    NSMutableDictionary *dics = [dic mutableCopy];
    CGFloat height = ceil(([UIScreen mainScreen].bounds.size.width - 42)*(140.0f/332.0f) + 34);
    [dics setObject:@{@"display_height":@(height),@"display_width":@([UIScreen mainScreen].bounds.size.width - 42)}  forKey:@"common_params"];
//    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"search_agency_card" templateKey:[FHLynxManager defaultJSFileName] version:0];
//    NSData *templateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.95.172.166:3344/community_evaluation/template.js"]];
//    NSString *lynxData = [dics btd_jsonStringEncoded];
//    LynxTemplateData *data = [[LynxTemplateData alloc]initWithJson:lynxData];
//    [self.articleCardView.lynxView loadTemplate:templateData withURL:@"local" initData:data];
    if (dics && self.articleCardView) {
        [self.articleCardView updateData:dics];
    }

}

- (void)viewDidChangeIntrinsicContentSize:(CGSize)size {
    if (self.lynxEndLoadBlock) {
        CGFloat cellHeight =  size.height + 24;
        self.lynxEndLoadBlock(cellHeight);
    }
}

@end

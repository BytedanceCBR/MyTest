//
//  FHNewHouseDetailAssessCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/10.
//

#import "FHNewHouseDetailAssessCollectionCell.h"
#import "FHCardSliderView.h"

@interface FHNewHouseDetailAssessCollectionCell ()

@property(nonatomic , strong) FHCardSliderView *cardSliderView;

@end

@implementation FHNewHouseDetailAssessCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    CGFloat height = [FHCardSliderView getViewHeight];
    height += 15;
    return CGSizeMake(width, height);
}

- (NSString *)elementType {
    [self.cardSliderView trackCardShow];
    return @"guide";
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.cardSliderView = [[FHCardSliderView alloc] initWithFrame:CGRectZero type:FHCardSliderViewTypeHorizontal];
        self.cardSliderView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.cardSliderView];
        [self.cardSliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo([FHCardSliderView getViewHeight]);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailAssessCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHNewHouseDetailAssessCellModel *cellModel = (FHNewHouseDetailAssessCellModel *)data;
    
//    FHDetailNeighborhoodDataStrategyModel *strategy = cellModel.strategy;
    _cardSliderView.tracerDic = cellModel.tracerDic;
    [_cardSliderView setCardListData:cellModel.cards];
}

@end

@implementation FHNewHouseDetailAssessCellModel

- (void)setStrategy:(FHDetailNeighborhoodDataStrategyModel *)strategy {
    _strategy = strategy;

    NSMutableArray *cards = [NSMutableArray array];
    for (FHDetailNeighborhoodDataStrategyArticleListModel *model in strategy.articleList) {
        FHCardSliderCellModel *cellModel = [[FHCardSliderCellModel alloc] init];
        cellModel.title = model.title;
        cellModel.desc = model.desc;
        cellModel.imageUrl = model.picture;
        cellModel.schema = model.schema;
        cellModel.type = model.articleType;
        cellModel.groupId = model.groupId;
        NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
        if(model.logPb){
            tracerDic[@"log_pb"] = model.logPb;
        }
        cellModel.tracer = tracerDic;
        [cards addObject:cellModel];
    }
    _cards = cards;
}

@end

//
//  FHHouseItemFeedCell.m
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "FHHouseItemFeedCell.h"
#import "TTRoute.h"
#import "FHExploreHouseItemData.h"
#import "ExploreOrderedData+TTBusiness.h"

@implementation FHHouseItemFeedCell

+ (Class)cellViewClass {
    return [FHHouseItemFeedCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@interface FHHouseItemFeedCellView ()

@property (nonatomic, strong) UITableView *houseTableView;

@end


@implementation FHHouseItemFeedCellView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildupView];
    }
    return self;
}

- (void)buildupView {

    // add by zjing for test
    self.backgroundColor = [UIColor redColor];
}

- (void)refreshWithData:(ExploreOrderedData *)data {
    NSParameterAssert([data isKindOfClass:[ExploreOrderedData class]]);
    
    self.orderedData = data;

    
}

- (void)willAppear {

}

- (void)didDisappear {
    
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    
//    TTExploreLoadMoreTipData *model = self.orderedData.loadmoreTipData;
//    if (model == nil || ![model isKindOfClass:[TTExploreLoadMoreTipData class]]) {
//        return;
//    }
//    NSURL *openURL = [NSURL URLWithString:model.openURL];
//    [[TTRoute sharedRoute] openURLByViewController:openURL userInfo:nil];
    

}


+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    return 65.0f + 105 * 3 + 48.f;
}

@end


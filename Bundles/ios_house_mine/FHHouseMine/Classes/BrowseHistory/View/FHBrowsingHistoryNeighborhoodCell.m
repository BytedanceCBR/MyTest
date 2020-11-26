//
//  FHBrowsingHistoryNeighborhoodCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/4.
//

#import "FHBrowsingHistoryNeighborhoodCell.h"
#import "Masonry.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "UIColor+Theme.h"

@interface FHBrowsingHistoryNeighborhoodCell()

@end

@implementation FHBrowsingHistoryNeighborhoodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (FHHouseNeighborhoodCardView *)cardView {
    if (!_cardView) {
        _cardView = [[FHBrowsingHistoryNeighborhoodCardView alloc] init];
        _cardView.layer.cornerRadius = 10;
        _cardView.layer.masksToBounds = YES;
        _cardView.backgroundColor = [UIColor whiteColor];
    }
    return _cardView;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    if ([viewModel isKindOfClass:[FHHouseNeighborhoodCardViewModel class]]) {
        self.cardView.viewModel = (FHHouseNeighborhoodCardViewModel *)viewModel;
    }
}

@end

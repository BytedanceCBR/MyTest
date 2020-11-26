//
//  FHBrowsingHistoryNeighborhoodCardView.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHBrowsingHistoryNeighborhoodCardView.h"
#import "FHHouseOffShelfView.h"
#import "Masonry.h"

@interface FHBrowsingHistoryNeighborhoodCardView()

@property (nonatomic, strong) FHHouseOffShelfView *offShelfView;

@end

@implementation FHBrowsingHistoryNeighborhoodCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.offShelfView = [[FHHouseOffShelfView alloc] init];
        [self addSubview:self.offShelfView];
        [self.offShelfView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(15);
            make.width.height.mas_equalTo(84);
        }];
    }
    return self;
}

- (FHHouseNeighborhoodCardViewModel *)cardViewModel {
    if (![self.viewModel isKindOfClass:FHBrowsingHistoryNeighborhoodCardViewModel.class]) return nil;
    return (FHBrowsingHistoryNeighborhoodCardViewModel *)self.viewModel;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    self.offShelfView.hidden = !self.cardViewModel.isOffShelf;
}

@end

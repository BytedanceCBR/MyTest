//
//  FHBrowsingHistorySecondCardView.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHBrowsingHistorySecondCardView.h"
#import "FHHouseOffShelfView.h"
#import "Masonry.h"
#import "FHHouseSecondCardViewModel+addtion.h"

@interface FHBrowsingHistorySecondCardView()

@property (nonatomic, strong) FHHouseOffShelfView *offShelfView;

@end

@implementation FHBrowsingHistorySecondCardView

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

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseSecondCardViewModel *secondViewModel = (FHHouseSecondCardViewModel *)viewModel;
    self.offShelfView.hidden = !secondViewModel.isOffShelf;
}
@end

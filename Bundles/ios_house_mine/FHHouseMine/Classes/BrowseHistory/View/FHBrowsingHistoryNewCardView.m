//
//  FHBrowsingHistoryNewCardView.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHBrowsingHistoryNewCardView.h"
#import "FHHouseOffShelfView.h"
#import "Masonry.h"
#import "FHHouseNewCardViewModel+addtion.h"

@interface FHBrowsingHistoryNewCardView()

@property (nonatomic, strong) FHHouseOffShelfView *offShelfView;

@end

@implementation FHBrowsingHistoryNewCardView

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
    FHHouseNewCardViewModel *newViewModel = (FHHouseNewCardViewModel *)viewModel;
    self.offShelfView.hidden = !newViewModel.isOffShelf;
}


@end

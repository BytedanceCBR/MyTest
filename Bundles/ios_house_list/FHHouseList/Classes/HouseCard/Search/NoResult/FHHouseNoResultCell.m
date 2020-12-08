//
//  FHHouseNoResultCell.m
//  ABRInterface
//
//  Created by bytedance on 2020/12/8.
//

#import "FHHouseNoResultCell.h"
#import "FHErrorView.h"
#import "Masonry.h"
#import "FHHouseNoResultViewModel.h"

@interface FHHouseNoResultCell()
@property (nonatomic, strong) FHErrorView *errorView;
@end

@implementation FHHouseNoResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.errorView];
        [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(60);
            make.bottom.left.right.mas_equalTo(self.contentView);
        }];
        [self.errorView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (FHErrorView *)errorView {
    if(!_errorView){
        _errorView = [[FHErrorView alloc ] init];
        _errorView.backgroundColor = [UIColor clearColor];
    }
    return _errorView;
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseNoResultViewModel.class]) return 0.0f;
    FHHouseNoResultViewModel *cardViewModel = (FHHouseNoResultViewModel *)viewModel;
    return cardViewModel.viewHeight;
}

@end

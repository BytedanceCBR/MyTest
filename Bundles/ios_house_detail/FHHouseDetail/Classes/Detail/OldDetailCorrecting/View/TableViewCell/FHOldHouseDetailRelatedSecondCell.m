//
//  FHOldHouseDetailRelatedSecondCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/11/9.
//

#import "FHOldHouseDetailRelatedSecondCell.h"
#import "FHHouseSecondCardView.h"
#import "FHHouseSecondCardViewModel.h"
#import "Masonry.h"

@interface FHOldHouseDetailRelatedSecondCell()

@property (nonatomic, strong) FHHouseSecondCardView *cardView;

@property (nonatomic, strong) UIView *line;

@end

@implementation FHOldHouseDetailRelatedSecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)initUI {
    self.cardView = [[FHHouseSecondCardView alloc] init];
    [self.contentView addSubview:self.cardView];
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-4);
    }];
    
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data withLast:(BOOL)isLast {
    self.line.hidden = isLast;
    if ([data isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        self.cardView.viewModel = data;
    }
}

+ (CGFloat)heightForData:(id)data {
    if ([data isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        return [FHHouseSecondCardView viewHeightWithViewModel:data] + 4;
    }
    return 0;
}

@end

//
//  FHHouseOffShelfView.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/25.
//

#import "FHHouseOffShelfView.h"
#import "Masonry.h"
#import "UIFont+House.h"

@interface FHHouseOffShelfView()

@property (nonatomic, strong) UIView *maskView; //蒙层
@property (nonatomic, strong) UILabel *offShelfLabel; //下架

@end

@implementation FHHouseOffShelfView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.maskView = [[UIView alloc] init];
    [self.maskView setBackgroundColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:0.8]];
    self.maskView.layer.shadowOffset = CGSizeMake(4, 6);
    self.maskView.layer.cornerRadius = 4;
    self.maskView.clipsToBounds = YES;
    self.maskView.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor];
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    self.offShelfLabel = [[UILabel alloc] init];
    self.offShelfLabel.text = @"已下架";
    self.offShelfLabel.font = [UIFont themeFontSemibold:14];
    self.offShelfLabel.textColor = [UIColor whiteColor];
    [self addSubview:_offShelfLabel];
    [self.offShelfLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    NSString *houseStatus = self.viewModel;
    self.hidden = (houseStatus.integerValue == 0) ? YES : NO;
}

@end

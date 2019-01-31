//
//  FHTest2Cell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHTest2Cell.h"


@interface FHTest2Cell ()

@property (nonatomic, strong)   UIView       *foldView;
@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UILabel       *label2;

@end

@implementation FHTest2Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    CGFloat height = 200;
    if ([data isKindOfClass:[FHDetailTest2Model class]]) {
        FHDetailTest2Model *test = (FHDetailTest2Model *)data;
//        test.isExpand = !test.isExpand;
        if (test.isExpand) {
            height = 200;
        } else {
            height = 80;
        }
    }
    [_foldView mas_updateConstraints:^(MASConstraintMaker *make) {
       make.height.mas_equalTo(height);
    }];
    
//    [self updateConstraintsIfNeeded];
}

- (void)setupUI {
    // foldView
    _foldView = [[UIView alloc] init];
    [self.contentView addSubview:_foldView];
    [_foldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
        make.height.mas_equalTo(200);
    }];
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"猜你想搜2";
    _label.font = [UIFont themeFontMedium:14];
    _label.textColor = [UIColor themeBlue1];
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    // label2
    _label2 = [[UILabel alloc] init];
    _label2.text = @"123456789";
    _label2.font = [UIFont themeFontMedium:14];
    _label2.textColor = [UIColor themeBlue1];
    [self.contentView addSubview:_label2];
    [_label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(20);
    }];
}


@end

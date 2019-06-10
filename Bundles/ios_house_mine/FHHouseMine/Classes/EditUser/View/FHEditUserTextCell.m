//
//  FHEditUserTextCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/21.
//

#import "FHEditUserTextCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTUserProfileCheckingView.h"

@interface FHEditUserTextCell()

@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* contentLabel;
@property (nonatomic, strong) UIImageView* indicatorView;
@property (nonatomic, strong) TTUserProfileCheckingView *checkingView; //审核中

@end

@implementation FHEditUserTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.indicatorView = [[UIImageView alloc] init];
    [self.contentView addSubview:_indicatorView];
    _indicatorView.image = [UIImage imageNamed:@"setting-arrow"];
    
    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor themeGray1];
    _nameLabel.font = [UIFont themeFontRegular:16];
    [self.contentView addSubview:_nameLabel];
    
    self.contentLabel = [[UILabel alloc] init];
    _contentLabel.textColor = [UIColor themeGray3];
    _contentLabel.font = [UIFont themeFontRegular:16];
    _contentLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_contentLabel];
    
    self.checkingView = [[TTUserProfileCheckingView alloc] init];
    _checkingView.hidden = YES;
    [self.contentView addSubview:_checkingView];
    
}

- (void)initConstraints {
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-24);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(80);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.checkingView.mas_right).offset(15);
        make.right.mas_equalTo(self.indicatorView.mas_left).offset(-10);
    }];
    
    CGSize size = [self.checkingView sizeForFit];
    [self.checkingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(-35);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(size);
    }];
}

- (void)updateCell:(NSDictionary *)dic {
    self.nameLabel.text = dic[@"name"];
    self.contentLabel.text = dic[@"content"];
    
    if(dic[@"isAuditing"]){
        self.checkingView.hidden = ![dic[@"isAuditing"] boolValue];
    }
}

@end

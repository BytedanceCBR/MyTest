//
//  FHHomePlaceHolderCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/23.
//

#import "FHHomePlaceHolderCell.h"
#import <Masonry.h>
#import "UIColor+Theme.h"

#define HOR_MARGIN 20

@interface FHHomePlaceHolderCell ()

@property(nonatomic , strong) UIImageView *placeHolderImageView;

@property(nonatomic , strong) UIView *view1;
@property(nonatomic , strong) UIView *view2;
@property(nonatomic , strong) UIView *view3;
@property(nonatomic , strong) UIView *view4;

@end

@implementation FHHomePlaceHolderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage *image = [UIImage imageNamed:@"house_cell_placeholder"];
        _placeHolderImageView = [[UIImageView alloc] initWithImage:image];
        
        [self.contentView addSubview:_placeHolderImageView];
        
        [self.contentView addSubview:self.view1];
        [self.contentView addSubview:self.view2];
        [self.contentView addSubview:self.view3];
        
        [_placeHolderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(HOR_MARGIN);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(54);
            make.top.mas_equalTo(20);
            make.bottom.mas_equalTo(self.contentView);
        }];
        
        [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.placeHolderImageView.mas_right).mas_offset(10);
            make.right.mas_equalTo(-HOR_MARGIN);
            make.top.mas_equalTo(self.placeHolderImageView).offset(2);
            make.height.mas_equalTo(10);
        }];
        
        [self.view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view1);
            make.right.mas_equalTo(-20 - 44);
            make.top.mas_equalTo(self.view1.mas_bottom).mas_offset(10);
            make.height.mas_equalTo(10);
        }];
        
        [self.view3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view1);
            make.right.mas_equalTo(self.view2.mas_centerX).mas_offset(10);
            make.top.mas_equalTo(self.view2.mas_bottom).mas_offset(10);
            make.height.mas_equalTo(10);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setTopOffset:(CGFloat)topOffset {
    _topOffset = topOffset;
    [_placeHolderImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topOffset);
    }];
}

-(UIView *)view1 {
    
    if (!_view1) {
        _view1 = [[UIView alloc]init];
        _view1.backgroundColor = [UIColor themeGray7];
    }
    return _view1;
}

-(UIView *)view2 {
    
    if (!_view2) {
        _view2 = [[UIView alloc]init];
        _view2.backgroundColor = [UIColor themeGray7];
    }
    return _view2;
}

-(UIView *)view3 {
    
    if (!_view3) {
        _view3 = [[UIView alloc]init];
        _view3.backgroundColor = [UIColor themeGray7];
    }
    return _view3;
}

-(UIView *)view4 {
    
    if (!_view4) {
        _view4 = [[UIView alloc]init];
        _view4.backgroundColor = [UIColor themeGray7];
    }
    return _view4;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

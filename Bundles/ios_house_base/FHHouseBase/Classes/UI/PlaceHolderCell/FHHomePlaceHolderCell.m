//
//  FHHomePlaceHolderCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/23.
//

#import "FHHomePlaceHolderCell.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <TTBaseLib/UIViewAdditions.h>

#define HOR_MARGIN 15


@interface FHHomePlaceHolderCell ()
@property(nonatomic , strong) UIView *bacView;
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
//        UIImage *image = [UIImage imageNamed:@"house_cell_placeholder"];
        
        self.contentView.backgroundColor = [UIColor themeGray7];
        [self.contentView addSubview:self.bacView];
        
        _placeHolderImageView = [[UIImageView alloc] initWithImage:nil];
        
        [self.bacView addSubview:_placeHolderImageView];
        
        [self.bacView addSubview:self.view1];
        [self.bacView addSubview:self.view2];
        [self.bacView addSubview:self.view3];
        [self.bacView addSubview:self.view4];
        
        _bacView.frame = CGRectMake(HOR_MARGIN, 5, SCREEN_WIDTH - 2*HOR_MARGIN, 114);
        
        CGFloat vleft = HOR_MARGIN+84+10;
        CGFloat vWidth = (SCREEN_WIDTH - vleft - HOR_MARGIN*3);
        _placeHolderImageView.frame = CGRectMake(HOR_MARGIN, 15, 84, 84);
        _view1.frame = CGRectMake(vleft, 15, vWidth, 14);
        _view2.frame = CGRectMake(vleft, _view1.bottom + 7, vWidth-44, 16);
        _view3.frame = CGRectMake(vleft, _view2.bottom + 7, _view2.centerX - vleft + 10 , 16);
        _view4.frame = CGRectMake(vleft, _view3.bottom + 7, _view3.centerX - vleft + 10 , 16);
                
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setTopOffset:(CGFloat)topOffset {
    _topOffset = topOffset;
    _bacView.top = topOffset;
    _placeHolderImageView.top = topOffset + 10;
    _view1.top = topOffset + 10;
    _view2.top = _view1.bottom + 7;
    _view3.top = _view2.bottom + 7;
    _view4.top = _view3.bottom + 7;
}

-(UIView *)bacView {
    
    if (!_bacView) {
        _bacView = [[UIView alloc]init];
        _bacView.backgroundColor = [UIColor whiteColor];
        _bacView.layer.cornerRadius = 10;
        _bacView.clipsToBounds = YES;
    }
    return _bacView;
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

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(newSuperview && !_placeHolderImageView.image){
        _placeHolderImageView.image = [UIImage imageNamed:@"house_cell_placeholder_square"];
    }
}


@end

@implementation FHHomePlaceHolderCellModel



@end

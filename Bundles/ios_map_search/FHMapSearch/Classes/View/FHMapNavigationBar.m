//
//  FHMapNavigationBar.m
//  Article
//
//  Created by 谷春晖 on 2018/11/8.
//

#import "FHMapNavigationBar.h"
#import "UIFont+House.h"
#import <Masonry.h>

@interface FHMapNavigationBar ()

@property(nonatomic , strong) UIButton *backButton;
@property(nonatomic , strong) UIButton *listButton;
@property(nonatomic , strong) UIButton *mapButton;
@property(nonatomic , strong) UILabel *titleLabel;

@end

@implementation FHMapNavigationBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImage *img = [UIImage imageNamed:@"icon-return"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:img forState:UIControlStateNormal];
        [backButton setImage:img forState:UIControlStateHighlighted];
        backButton.frame = CGRectMake(0, 0, 44, 44);
        _backButton = backButton;
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        
        img = [UIImage imageNamed:@"mapsearch_nav_list"];
        _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_listButton setImage:img forState:UIControlStateNormal];
        _listButton.frame  = CGRectMake(0, 0, 44, 44);
        [_listButton addTarget:self action:@selector(listAction) forControlEvents:UIControlEventTouchUpInside];
        
        img =[UIImage imageNamed:@"navbar_showmap"];
        _mapButton= [UIButton buttonWithType:UIButtonTypeCustom];
        [_mapButton setImage:img forState:UIControlStateNormal];
        _mapButton.frame = CGRectMake(0, 0, 44, 44);
        [_mapButton addTarget:self action:@selector(mapAction) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont themeFontMedium:16];
        
        [self addSubview:_backButton];
        [self addSubview:_listButton];
        [self addSubview:_mapButton];
        [self addSubview:_titleLabel];
        
        _mapButton.hidden = YES;
        
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.bottom.mas_equalTo(self);
            make.left.mas_equalTo(10);
        }];
        [_listButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.bottom.mas_equalTo(self);
            make.right.mas_equalTo(self).offset(-10);
        }];
        [_mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_listButton);
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_backButton);
            make.left.mas_equalTo(70);
            make.right.mas_equalTo(self).offset(-70);
        }];
        
    }
    return self;
}



-(void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
//    [self.titleLabel sizeToFit];
//    NSLog(@"title is: %@  view is: %@",self.titleLabel,self);
//    if (self.titleLabel.width > self.width - 120) {
//        self.titleLabel.width = self.width - 120;
//    }
//    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.width/2);
//        make.width.mas_equalTo(self.titleLabel.width);
//    }];
}

-(void)showRightMode:(FHMapNavigationBarRightMode)mode
{
    switch (mode) {
        case FHMapNavigationBarRightModeNone:
            self.mapButton.hidden = YES;
            self.listButton.hidden = YES;
            break;
        case FHMapNavigationBarRightModeMap:
            self.mapButton.hidden = NO;
            self.listButton.hidden = YES;
            break;
        case FHMapNavigationBarRightModeList:
            self.mapButton.hidden = YES;
            self.listButton.hidden = NO;
            break;
        default:
            break;
    }
}


-(void)backAction
{
    if (_backActionBlock) {
        _backActionBlock();
    }
}

-(void)mapAction
{
    if (_mapActionBlock) {
        _mapActionBlock();
    }
}

-(void)listAction
{
    if (_listActionBlock) {
        _listActionBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

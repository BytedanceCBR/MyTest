//
//  FHDistrictAreaAnnotationView.m
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHDistrictAreaAnnotationView.h"
#import <UIViewAdditions.h>
#import "UIColor+Theme.h"
#import <FHHouseBase/FHCommonDefines.h>

#define RGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a) * 1.f]

#define MAX_WIDTH 66

@interface FHDistrictAreaAnnotationView ()

@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) UILabel *descLabel;
@property(nonatomic , strong) UIImageView *upDownImageView;

@end

@implementation FHDistrictAreaAnnotationView


-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        
        int width = 80;
        
        self.frame = CGRectMake(0, 0, width, width);
        UIImage *bgImg = SYS_IMG(@"mapsearch_area_bg");
        self.layer.contents = (id)[bgImg CGImage];
        
        UIFont *font = [UIFont systemFontOfSize:12];
        UIColor *textColor = [UIColor themeGray1];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 21, MAX_WIDTH, 17)];
        _nameLabel.font = font;
        _nameLabel.textColor = textColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;

        _descLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 38, MAX_WIDTH, 17)];
        _descLabel.font = font;
        _descLabel.textColor = textColor;
        _descLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_nameLabel];
        [self addSubview:_descLabel];
        
    }
    return self;
    
}

-(void)setAnnotation:(id<MAAnnotation>)annotation
{
    [super setAnnotation:annotation];
    _nameLabel.text = annotation.title;
    _descLabel.text = annotation.subtitle;
//    
//    UIImage *arrow = YES ? [UIImage imageNamed:@"mapsearch_arrow_up"] : [UIImage imageNamed:@"mapsearch_arrow_down"];
//    self.upDownImageView.image = arrow;
//    
//    [_descLabel sizeToFit];
//    if (_descLabel.width + _upDownImageView.width > MAX_WIDTH) {
//        _descLabel.width = MAX_WIDTH - _upDownImageView.width;
//    }
//    
//    _descLabel.left = (MAX_WIDTH -_upDownImageView.width - _descLabel.width)/2;
//    _upDownImageView.left = _descLabel.right;
//    _upDownImageView.centerY = _descLabel.centerY;
}

//-(void)willMoveToSuperview:(UIView *)newSuperview
//{
//    if (newSuperview) {
//        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
//        [UIView animateWithDuration:0.25 animations:^{
//            self.transform = CGAffineTransformIdentity;
//        }];
//    }
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

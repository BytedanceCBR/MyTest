//
//  FHDistrictAreaAnnotationView.m
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHDistrictAreaAnnotationView.h"

#define RGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a) * 1.f]

@interface FHDistrictAreaAnnotationView ()

@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) UILabel *descLabel;

@end

@implementation FHDistrictAreaAnnotationView


-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        
        int width = 64;
        
        self.frame = CGRectMake(0, 0, width, width);
        self.layer.cornerRadius = width/2;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RGBA(41,156,255,0.9);
        
        UIFont *font = [UIFont systemFontOfSize:12];
        UIColor *textColor = [UIColor whiteColor];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 16, 60, 17)];
        _nameLabel.font = font;
        _nameLabel.textColor = textColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;

        _descLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 32, 60, 17)];
        _descLabel.font = font;
        _descLabel.textColor = textColor;
        _descLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_nameLabel];
        [self addSubview:_descLabel];
        
        _nameLabel.text = annotation.title;
        _descLabel.text = annotation.subtitle;
    }
    return self;
    
}

-(void)setAnnotation:(id<MAAnnotation>)annotation
{
    [super setAnnotation:annotation];
    _nameLabel.text = annotation.title;
    _descLabel.text = annotation.subtitle;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  FHMapStationAnnotationView.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/27.
//

#import "FHMapStationAnnotationView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import "FHHouseAnnotation.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHCommonDefines.h>


@interface FHMapStationAnnotationView ()

@property(nonatomic , strong) UIImageView *backgroundView;
@property(nonatomic , strong) UIImageView *arrowView;
@property(nonatomic , strong) UIImageView *stationView;
@property(nonatomic , strong) UILabel *contentLabel;

@end

@implementation FHMapStationAnnotationView

-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
 
        UIImage *bgImage = [UIImage imageNamed:@"mapsearch_annotation_bg"];
        bgImage = [self resizeableImage:bgImage];
        UIImage *arrowImage = [UIImage imageNamed:@"mapsearch_annotation_arrow"];
        _backgroundView = [[UIImageView alloc] initWithImage:bgImage];
        _arrowView = [[UIImageView alloc] initWithImage:arrowImage];
        
        _stationView = [[UIImageView alloc] initWithImage:SYS_IMG(@"mapsearch_train")];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [UIColor themeGray1];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_backgroundView];
        [self addSubview:_arrowView];
        [self addSubview:_stationView];
        [self addSubview:_contentLabel];
        
        [self updateStyle];
        [self updateWithAnnotation:annotation];
    }
    return self;
}

-(UIImage *)resizeableImage:(UIImage *)img
{
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 19, 30)];
}

-(void)updateWithAnnotation:(id<MAAnnotation>) annotation
{
    _contentLabel.text = annotation.title;
    [_contentLabel sizeToFit];
    
    CGFloat maxWidth = MIN(_contentLabel.width, 171);
    CGRect frame = self.frame;
    frame.size = CGSizeMake(maxWidth+34, 38);
    self.frame = frame;
    
//    [self changeSelectMode:[(FHHouseAnnotation *)annotation type]];
}

-(void)updateStyle
{
    if ([self.annotation isKindOfClass:[FHHouseAnnotation class]]) {
        
        FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)self.annotation;
        houseAnnotation.type = FHHouseAnnotationTypeSelected;
        
        NSString *bgImageName = @"mapsearch_annotation_bg_red";
        NSString *arrowImageName = @"mapsearch_annotation_arrow_red";
        UIColor *textColor = [UIColor whiteColor];
        
        UIImage *img = [UIImage imageNamed:bgImageName];
        img = [self resizeableImage:img];
        _backgroundView.image = img;
        _arrowView.image = [UIImage imageNamed:arrowImageName];
        _contentLabel.textColor = textColor;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
    CGFloat arrowWidth = 7;
    self.arrowView.frame = CGRectMake(self.width/2-arrowWidth/2, 30-arrowWidth/2, arrowWidth, arrowWidth);
    self.contentLabel.frame = CGRectMake(24, 8, self.width-34, 17);
    self.stationView.frame = CGRectMake(10, 8, 10, 11);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

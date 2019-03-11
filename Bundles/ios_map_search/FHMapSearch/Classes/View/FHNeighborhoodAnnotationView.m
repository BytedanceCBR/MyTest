//
//  FHNeighborhoodAnnotationView.m
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHNeighborhoodAnnotationView.h"
#import "UIColor+Theme.h"
#import "FHHouseAnnotation.h"
#import <UIViewAdditions.h>


@interface FHNeighborhoodAnnotationView ()

@property(nonatomic , strong) UIImageView *backgroundView;
@property(nonatomic , strong) UIImageView *arrowView;
@property(nonatomic , strong) UILabel *contentLabel;

@end

@implementation FHNeighborhoodAnnotationView

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
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [UIColor themeGray1];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.textAlignment = NSTextAlignmentCenter;

        [self addSubview:_backgroundView];
        [self addSubview:_arrowView];
        [self addSubview:_contentLabel];
        
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
    NSString *content = [NSString stringWithFormat:@"%@ %@",annotation.title,annotation.subtitle];
    _contentLabel.text = content;
    [_contentLabel sizeToFit];
    
    CGFloat maxWidth = MIN(_contentLabel.width, 171);
    CGRect frame = self.frame;
    frame.size = CGSizeMake(maxWidth+30, 35);
    self.frame = frame;
    
    [self changeSelectMode:[(FHHouseAnnotation *)annotation type]];
}


-(void)setAnnotation:(id<MAAnnotation>)annotation
{
    [super setAnnotation:annotation];
    [self updateWithAnnotation:annotation];
}

-(void)changeSelectMode:(FHHouseAnnotationType)type
{
    if ([self.annotation isKindOfClass:[FHHouseAnnotation class]]) {
        
        FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)self.annotation;
        houseAnnotation.type = type;
        
        NSString *bgImageName = nil;
        NSString *arrowImageName = nil;
        UIColor *textColor = nil;
        
        switch (houseAnnotation.type) {
            case FHHouseAnnotationTypeSelected:
            {
                bgImageName = @"mapsearch_annotation_bg_red";
                arrowImageName = @"mapsearch_annotation_arrow_red";
                textColor = [UIColor whiteColor];
            }
                break;
            case FHHouseAnnotationTypeOverSelected:
            {
                bgImageName = @"mapsearch_annotation_bg_grayRed";
                arrowImageName = @"mapsearch_annotation_arrow_grayRed";
                textColor = [UIColor whiteColor];
            }
                break;
                
            default:
            {
                bgImageName = @"mapsearch_annotation_bg";
                arrowImageName = @"mapsearch_annotation_arrow";
                textColor = [UIColor themeGray1];
            }
                break;
        }
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
    self.arrowView.frame = CGRectMake(self.width/2-arrowWidth/2, 29-arrowWidth/2, arrowWidth, arrowWidth);
    self.contentLabel.frame = CGRectMake(15, 8, self.width-30, 17);
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

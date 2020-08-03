//
//  FHMyItemAnnView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/7/30.
//

#import "FHMyItemAnnView.h"

@implementation FHMyItemAnnView
-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)setAnnotation:(id<MAAnnotation>)annotation
{
    [super setAnnotation:annotation];
    CGRect frame = self.frame;
    frame.size = CGSizeMake(self.annotation.title.length * 16 + 5, 30);
    self.frame = frame;
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.annotation.title.length * 16 + 5, 30);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//   return YES;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end

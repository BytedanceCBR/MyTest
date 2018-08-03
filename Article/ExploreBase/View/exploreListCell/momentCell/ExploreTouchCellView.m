//
//  ExploreTouchCellView.m
//  Article
//
//  Created by Chen Hong on 15/1/20.
//
//

#import "ExploreTouchCellView.h"

@implementation ExploreTouchCellView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)updateViewWithNormalColor {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)updateViewWithHighlightColor {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4Highlighted];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateViewWithHighlightColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateViewWithNormalColor];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateViewWithNormalColor];
}

- (void)viewDidTapped {
    //override
}

- (void)handleTapGestureRecognizer:(id)sender
{
    [self updateViewWithHighlightColor];
    [self performSelector:@selector(updateViewWithNormalColor) withObject:nil afterDelay:0.25];
    [self viewDidTapped];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];    
    [self updateViewWithNormalColor];
}

- (NSDictionary *)buildClickEvent:(NSDictionary *)data {
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:data];
    [dict setValue:@"umeng" forKey:@"category"];
    
    NSString *label = dict[@"label"];
    if ([label rangeOfString:@"__all__"].location != NSNotFound) {
        label = [label stringByReplacingOccurrencesOfString:@"__all__" withString:@"headline"];
        [dict setValue:label forKey:@"label"];
    }
    
    if (self.isCardSubCellView) {
        NSString *cardIndexStr = [NSString stringWithFormat:@"%ld", (long)self.cardSubCellIndex];
        [dict setValue:self.cardId forKey:@"card_id"];
        [dict setValue:cardIndexStr forKey:@"card_position"];
    }
    
//    [SSTracker eventData:dict];
    return dict;
}

@end

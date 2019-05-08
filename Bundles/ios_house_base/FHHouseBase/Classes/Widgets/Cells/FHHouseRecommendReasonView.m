//
//  FHHouseRecommendReasonView.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/3/5.
//

#import "FHHouseRecommendReasonView.h"
#import "FHSearchHouseModel.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>

@interface FHHouseRecommendReasonView()

@property(nonatomic , strong) NSMutableArray *views;
@property(nonatomic , strong) NSArray <FHSearchHouseDataItemsRecommendReasonsModel *> *recReasons;

@end

@implementation FHHouseRecommendReasonView

-(NSMutableArray *)views
{
    if (!_views) {
        _views = [NSMutableArray new];
    }
    return _views;
}

-(UILabel *)labelAtIndex:(NSInteger)index
{
    UILabel *label = nil;
    if (index >= self.views.count) {
        label = [[UILabel alloc] init];
        [self.views addObject:label];
    }else{
        label = self.views[index];
    }
    label.hidden = NO;
    return label;
}

-(void)setReasons:(NSArray <FHSearchHouseDataItemsRecommendReasonsModel *> *)reasons
{
    
    if (self.recReasons == reasons) {
        return;
    }
    self.recReasons = reasons;
        
    NSInteger index = 0;
    for (FHSearchHouseDataItemsRecommendReasonsModel *model in reasons) {
        
        if (model.text.length == 0) {
            continue;
        }
        
        UILabel *label = [self labelAtIndex:index++];
        CGFloat alpha = (model.iconBackgroundAlpha.floatValue/255.0);
        label.layer.cornerRadius = 2;
        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor colorWithHexString:model.iconBackgroundColor alpha:alpha];//?:[];
        label.text = [NSString stringWithFormat:@" %@ ",model.iconText];
        alpha = model.iconTextAlpha.floatValue/255.0;
        label.textColor = [UIColor colorWithHexString:model.iconTextColor alpha:alpha];
        label.font = [UIFont themeFontRegular:9];
        [label sizeToFit];
        if (label.bounds.size.height < 14) {
            CGRect bounds = label.bounds;
            bounds.size.height = 14;
            label.bounds = bounds;
        }
        [self addSubview:label];
        
        alpha = model.backgroundAlpha.floatValue/255.0;
        label = [self labelAtIndex:index++];
        label.layer.cornerRadius = 0;
        label.text = model.text;
        label.backgroundColor = [UIColor colorWithHexString:model.backgroundColor alpha:alpha];
        label.font = [UIFont themeFontRegular:12];
        alpha = model.textAlpha.floatValue/255.0;
        label.textColor = [UIColor colorWithHexString:model.textColor alpha:alpha];
        [self addSubview:label];
        [label sizeToFit];
    }
    
    for (; index < _views.count ; index++) {
        UILabel *l = _views[index];
        l.hidden = YES;
    }
    
    [self setNeedsLayout];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = 0;
    BOOL needHidden = NO;
    for (UILabel *l in _views) {
        
        if (l.hidden) {
            return;
        }
        if (needHidden) {
            return;
        }
        
        CGRect frame = l.frame;
        frame.origin = CGPointMake(left, (self.bounds.size.height - CGRectGetHeight(frame))/2);
        
        if (CGRectGetMaxX(frame) > self.frame.size.width) {
            frame.size.width = self.frame.size.width - CGRectGetMinX(frame);
            needHidden = YES;
            if (frame.size.width < 15) { //[榜]字完全不显示
                frame.size.width = 0;
            }
        }
        
        l.frame = frame;        
        left = CGRectGetMaxX(frame) + 6;
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

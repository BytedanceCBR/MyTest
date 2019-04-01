//
//  FHCommuteChooseView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import "FHCommuteChooseView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import "FHCommuteSlider.h"


#define THUMB_IMAGE_WIDTH 48
#define SLIDER_TOP_TIP    10
#define TIME_HOR_MARGIN   30
#define TIME_ITEM_WIDTH   17


@interface FHCommuteChooseView()

@property(nonatomic , strong) FHCommuteSlider *slider;
@property(nonatomic , assign) FHCommuteType type;
@property(nonatomic , copy) NSArray  *items;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , assign) NSInteger currentIndex;

@end

@implementation FHCommuteChooseView


-(instancetype)initWithFrame:(CGRect)frame type:(FHCommuteType)type durationItems:(NSArray<NSString *>*)items
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _type = type;
        _items = items;
                
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.text = @"期望通勤时长/分钟";
        [_titleLabel sizeToFit];
        CGRect labelFrame = _titleLabel.frame;
        labelFrame.origin.x = HOR_MARGIN;
        _titleLabel.frame = labelFrame;
        
        _slider = [[FHCommuteSlider  alloc] initWithFrame:CGRectMake(HOR_MARGIN, 0, SCREEN_WIDTH - 2*HOR_MARGIN, THUMB_IMAGE_WIDTH)];
        _slider.maxValue = 100;
        _slider.minValue = 0;
        _slider.type = type;
        __weak typeof(self) wself = self;
        _slider.updateValue = ^(CGFloat value, BOOL draging) {
            [wself valueChanged:draging];
        };
        
        [self addSubview:_titleLabel];
        [self addSubview:_slider];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self initConstraints];
    }
    
    return self;
    
}


-(void)initConstraints
{
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.right.mas_lessThanOrEqualTo(self).offset(-HOR_MARGIN);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(24);
    }];
    
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(SLIDER_TOP_TIP);
        make.left.mas_equalTo(HOR_MARGIN);
        make.right.mas_equalTo(self).offset(-HOR_MARGIN);
        make.height.mas_equalTo(THUMB_IMAGE_WIDTH);
    }];
}

-(UIImage *)thumbForType:(FHCommuteType)type
{
 
    NSString *name = nil;
    switch (type) {
            case FHCommuteTypeBus:
            name = @"commute_bus";
            break;
            case FHCommuteTypeRide:
            name = @"commute_ride";
            break;
            case FHCommuteTypeWalk:
            name = @"commute_walk";
            break;
            
        default:
            name = @"commute_drive";
    }
    
    return [UIImage imageNamed:name];
    
}

-(void)valueChanged:(BOOL)isDragging
{
    if (isDragging) {
        NSInteger value = (NSInteger)( _slider.value/(100.0/_items.count));
        if (value < 0 || value >= _items.count) {
            return;
        }
        if (value != _currentIndex) {
            _currentIndex = value;
            _chooseTime = _items[_currentIndex];
            [self setNeedsDisplay];
        }
    }else{
        CGFloat width = (CGRectGetWidth(self.bounds) - 2*TIME_HOR_MARGIN - TIME_ITEM_WIDTH*_items.count)/(_items.count - 1) + TIME_ITEM_WIDTH;
        
        CGFloat offset = TIME_HOR_MARGIN+width*_currentIndex+TIME_ITEM_WIDTH/2;
        CGPoint sliderOffset = [_slider convertPoint:CGPointMake(offset, 0) fromView:self];
        
        _slider.value = sliderOffset.x / _slider.frame.size.width * _slider.maxValue;
    }

}


-(void)setChooseTime:(NSString *)chooseTime
{
    NSInteger index = [_items indexOfObject:chooseTime];
    if (index >= 0 && index < _items.count) {
        _chooseTime = chooseTime;
        _currentIndex = index;
        [self setNeedsDisplay];
        [self valueChanged:NO];
    }
}

-(void)chooseType:(FHCommuteType)type
{
    _slider.type = type;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    if (_items.count < 1) {
        return;
    }
    
    CGFloat width = (CGRectGetWidth(rect) - 2*TIME_HOR_MARGIN - TIME_ITEM_WIDTH*_items.count)/(_items.count - 1);
    
    NSDictionary *attr = @{
                           NSFontAttributeName:[UIFont themeFontRegular:14],
                           NSForegroundColorAttributeName:[UIColor themeGray1]
                           };
    NSDictionary *hattr = @{
                            NSFontAttributeName:[UIFont themeFontRegular:14],
                            NSForegroundColorAttributeName:[UIColor themeRed1]
                            };
    
    for (NSInteger i = 0 ; i < _items.count ; i++) {
        NSString *item = _items[i];
        [item drawAtPoint:CGPointMake(TIME_HOR_MARGIN+(width+TIME_ITEM_WIDTH)*i, CGRectGetHeight(rect)-20) withAttributes:(i == _currentIndex)?hattr:attr];
    }
    
}


@end


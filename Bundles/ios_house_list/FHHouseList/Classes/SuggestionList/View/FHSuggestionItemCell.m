//
//  FHSuggestionItemCell.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import "FHSuggestionItemCell.h"

@implementation FHSuggestionItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end

// --
@implementation FHSuggestionNewHouseItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end

// --

@implementation FHSuggectionTableView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.handleTouch) {
        self.handleTouch();
    }
}

@end

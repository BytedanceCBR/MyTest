//
//  FHHouseTagViewModel.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseTagViewModel.h"
#import "UIFont+House.h"
#import "FHSearchHouseModel.h"
#import "FHHomeHouseModel.h"
#import "UIColor+Theme.h"
#import "NSString+BTDAdditions.h"

@interface FHHouseTagViewModel()
@property (nonatomic, strong) id model;
@end

@implementation FHHouseTagViewModel

- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (UIFont *)textFont {
    return [UIFont themeFontMedium:10];
}

- (CGFloat)tagHeight {
    return 16.0f;
}

- (CGFloat)tagWidth {
    if (_tagWidth < 0.01) {
        _tagWidth = [self.text btd_widthWithFont:self.textFont height:self.tagHeight] + 3 * 2;
    }
    return _tagWidth;
}

- (NSString *)text {
    if ([self.model isKindOfClass:FHSearchHouseItemTitleTagModel.class]) {
        return [(FHSearchHouseItemTitleTagModel *)self.model text];
    } else if ([self.model isKindOfClass:FHHomeHouseItemTitleTagModel.class]) {
        return [(FHHomeHouseItemTitleTagModel *)self.model text];
    }
    
    return nil;
}

- (UIColor *)textColor {
    NSString *textColor = nil;
    if ([self.model isKindOfClass:FHSearchHouseItemTitleTagModel.class]) {
        textColor = [(FHSearchHouseItemTitleTagModel *)self.model textColor];
    } else if ([self.model isKindOfClass:FHHomeHouseItemTitleTagModel.class]) {
        textColor = [(FHHomeHouseItemTitleTagModel *)self.model textColor];
    }
    
    return textColor.length > 0 ? [UIColor colorWithHexStr:textColor] : nil;
}

- (UIColor *)backgroundColor {
    NSString *textColor = nil;
    if ([self.model isKindOfClass:FHSearchHouseItemTitleTagModel.class]) {
        textColor = [(FHSearchHouseItemTitleTagModel *)self.model backgroundColor];
    } else if ([self.model isKindOfClass:FHHomeHouseItemTitleTagModel.class]) {
        textColor = [(FHHomeHouseItemTitleTagModel *)self.model backgroundColor];
    }
    
    return textColor.length > 0 ? [UIColor colorWithHexStr:textColor] : nil;
}

- (UIColor *)topBackgroundColor {
    NSString *textColor = nil;
    if ([self.model isKindOfClass:FHSearchHouseItemTitleTagModel.class]) {
        textColor = [(FHSearchHouseItemTitleTagModel *)self.model topBackgroundColor];
    } else if ([self.model isKindOfClass:FHHomeHouseItemTitleTagModel.class]) {
        textColor = [(FHHomeHouseItemTitleTagModel *)self.model topBackgroundColor];
    }
    
    return textColor.length > 0 ? [UIColor colorWithHexStr:textColor] : nil;
}

- (UIColor *)bottomBackgroundColor {
    NSString *textColor = nil;
    if ([self.model isKindOfClass:FHSearchHouseItemTitleTagModel.class]) {
        textColor = [(FHSearchHouseItemTitleTagModel *)self.model bottomBackgroundColor];
    } else if ([self.model isKindOfClass:FHHomeHouseItemTitleTagModel.class]) {
        textColor = [(FHHomeHouseItemTitleTagModel *)self.model bottomBackgroundColor];
    }
    
    return textColor.length > 0 ? [UIColor colorWithHexStr:textColor] : nil;
}

- (BOOL)isGradient {
    BOOL isGradient = NO;
    if ([self.model isKindOfClass:FHSearchHouseItemTitleTagModel.class]) {
        isGradient = [(FHSearchHouseItemTitleTagModel *)self.model isGradient];
    } else if ([self.model isKindOfClass:FHHomeHouseItemTitleTagModel.class]) {
        isGradient = [(FHHomeHouseItemTitleTagModel *)self.model bottomBackgroundColor];
    }
    
    return isGradient;
}


@end

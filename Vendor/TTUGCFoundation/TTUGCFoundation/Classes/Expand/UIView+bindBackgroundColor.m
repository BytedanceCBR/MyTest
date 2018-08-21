//
//  UIView+bindBackgroundColor.m
//  Article
//
//  Created by SongChai on 2017/4/19.
//
//

#import "UIView+bindBackgroundColor.h"
#import <objc/runtime.h>

@interface UIView ()

@property(nonatomic, strong) NSHashTable* tt_bindBackgroundColorViews;

@end

@implementation UIView (bindBackgroundColor)

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setBackgroundColor:)), class_getInstanceMethod(self, @selector(tt_setBackgroundColor:)));
}

- (void)tt_setBackgroundColor:(UIColor *)backgroundColor {
    [self tt_setBackgroundColor:backgroundColor];
    for (UIView* bindView in self.tt_bindBackgroundColorViews) {
        if (bindView) {
            bindView.backgroundColor = backgroundColor;
        }
    }
}

- (void)setTt_bindBackgroundColorViews:(NSHashTable *)views {
    objc_setAssociatedObject(self, @selector(tt_bindBackgroundColorViews), views, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSHashTable *)tt_bindBackgroundColorViews {
    NSHashTable* table = (NSHashTable *)objc_getAssociatedObject(self, @selector(tt_bindBackgroundColorViews));
    if (table == nil) {
        table = [NSHashTable weakObjectsHashTable];
        self.tt_bindBackgroundColorViews = table;
    }
    return table;
}

- (void)tt_backgroundColorBindView:(UIView *)view {
    if (view && ![self.tt_bindBackgroundColorViews containsObject:view]) {
        [self.tt_bindBackgroundColorViews addObject:view];
        view.backgroundColor = self.backgroundColor;
    }
}

- (void)tt_backgroundColorUnBindView:(UIView *)view {
    if (view && [self.tt_bindBackgroundColorViews containsObject:view]) {
        [self.tt_bindBackgroundColorViews removeObject:view];
    }
}

- (void)tt_backgroundColorBindViews:(UIView *)view, ... {
    if (view) {
        NSHashTable* table = self.tt_bindBackgroundColorViews;
        [table addObject:view];
        view.backgroundColor = self.backgroundColor;
        view.layer.masksToBounds = YES;
        va_list args;
        va_start(args, view);
        UIView *eachView;
        while ((eachView = va_arg(args, UIView *))) {
            [table addObject:eachView];
            eachView.backgroundColor = self.backgroundColor;
            eachView.layer.masksToBounds = YES;
        }
        va_end(args);
    }
}

@end

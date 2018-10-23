//
//  TTVFrameBasedLinearLayoutView.m
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import "TTVFrameBasedLinearLayoutView.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TTVFrameBasedLinearLayoutView ()

@property (nonatomic, strong) NSMutableArray<id<TTVFrameBasedLinearLayoutItem>> *items;

@end

@implementation TTVFrameBasedLinearLayoutView

- (void)addSubview:(UIView *)view withEdgeInsets:(UIEdgeInsets)edgeInsets {
    [self addItem:[TTVFrameBasedLinearLayoutItemSimpleContainer containerWithView:view withEdgeInsets:edgeInsets]];
}

- (void)addSubview:(UIView *)view withTopMargin:(CGFloat)topMargin {
    [self addItem:[TTVFrameBasedLinearLayoutItemSimpleContainer containerWithView:view withTopMargin:topMargin]];
}

- (id<TTVFrameBasedLinearLayoutItem>)itemWithView:(UIView *)view {
    for (id<TTVFrameBasedLinearLayoutItem> item in _items) {
        if ([item view] == view) {
            return item;
        }
    }
    return nil;
}

- (NSArray<id<TTVFrameBasedLinearLayoutItem>> *)allItems {
    if (!_items) {
        return nil;
    }
    return [NSArray arrayWithArray:_items];
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)removeItem:(id<TTVFrameBasedLinearLayoutItem>)item {
    id<TTVFrameBasedLinearLayoutItem> oldItem = [self itemWithView:[item view]];
    if (oldItem) {
        [[oldItem view] removeFromSuperview];
        [_items removeObject:oldItem];
        [self setNeedsLayout];
    }
}

- (void)addItem:(id<TTVFrameBasedLinearLayoutItem>)item {
    [self insertItem:item atIndex:[_items count]];
}

- (void)insertItem:(id<TTVFrameBasedLinearLayoutItem>)item atIndex:(NSUInteger)index {
    [self removeItem:item];
    if (index >= [self.items count]) {
        [self.items addObject:item];
    }
    else {
        [self.items insertObject:item atIndex:index];
    }
    [self addSubview:[item view]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat y = 0;
    for (id<TTVFrameBasedLinearLayoutItem> item in _items) {
        UIView *view = [item view];
        UIEdgeInsets edgeInsets = [item respondsToSelector:@selector(edgeInsets)] ? [item edgeInsets] : UIEdgeInsetsZero;
        if (view.superview == self) {
            if (view.hidden || view.height == 0) {
                continue;
            }
            view.top = y + edgeInsets.top;
            view.width = self.width - edgeInsets.left - edgeInsets.right;
            view.left = edgeInsets.left;
            y = view.bottom + edgeInsets.bottom;
        }
        else {
            y = y + edgeInsets.top + view.height + edgeInsets.bottom;
        }
    }
    self.height = y;
}

@end

@interface TTVFrameBasedLinearLayoutScrollView ()
@property (nonatomic, strong) TTVFrameBasedLinearLayoutView *contentView;
@end

@implementation TTVFrameBasedLinearLayoutScrollView

- (TTVFrameBasedLinearLayoutView *)contentView {
    if (!_contentView) {
        _contentView = [[TTVFrameBasedLinearLayoutView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        self.bounces = YES;
        [self addSubview:_contentView];
        @weakify(self);
        [[[RACObserve(self.contentView, frame) map:^id(NSValue *value) {
            return @([value CGRectValue].size.height);
        }] distinctUntilChanged] subscribeNext:^(id x) {
            @strongify(self);
            CGSize contentSize =  self.contentView.bounds.size;
            contentSize.height = MAX(self.height - self.contentInset.bottom - self.contentInset.top, contentSize.height);
            self.contentSize = contentSize;
        }];
    }
    return _contentView;
}

- (NSArray<id<TTVFrameBasedLinearLayoutItem>> *)allItems {
    return [_contentView allItems];
}

- (void)addSubview:(UIView *)view withEdgeInsets:(UIEdgeInsets)edgeInsets {
    [self.contentView addSubview:view withEdgeInsets:edgeInsets];
}

- (void)addSubview:(UIView *)view withTopMargin:(CGFloat)topMargin {
    [self.contentView addSubview:view withTopMargin:topMargin];
}

- (void)addItem:(id<TTVFrameBasedLinearLayoutItem>)item {
    [self.contentView addItem:item];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setAutoScrollTextFieldToVisible:(BOOL)autoScroll {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if (autoScroll) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowNotification:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillHideNotification:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
}

- (UITextField *)firstResponderTextFieldInView:(UIView *)view {
    if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
        return (UITextField *)view;
    }
    for (UIView *subview in view.subviews) {
        UITextField *textField = [self firstResponderTextFieldInView:subview];
        if (textField) {
            return textField;
        }
    }
    return nil;
}

#pragma mark keyboard notification

- (void)handleKeyboardWillShowNotification:(NSNotification *)notification {
    UITextField *textField = [self firstResponderTextFieldInView:self.contentView];
    if (textField) {
        CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        UIWindow *textFieldWindow = textField.window;
        CGFloat textFieldBottomInWindow = [textField.superview convertPoint:textField.center toView:textFieldWindow].y + textField.height / 2;
        //判断textField底部(textFieldBottomInWindow)距离键盘顶部(textFieldWindow.height - keyboardSize.height)的距离
        //为了美观，再10的间距
        if (textFieldBottomInWindow + 10 > textFieldWindow.height - keyboardSize.height) {
            CGFloat offset = textFieldBottomInWindow + 10 - textFieldWindow.height + keyboardSize.height + self.contentOffset.y;
            /**
             *  当`UITextField`被遮挡时, runloop会调用`scrollTextFieldToVisible`进而触发对`setContentOffset:animated:`设置
             *  导致在当前`runloop`设置失效.故而将`offset`设置放到下下一个`runloop`.
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setContentOffset:CGPointMake(0, offset) animated:YES];
            });
        }
    }
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification {
    CGFloat maxOffset = self.contentSize.height + self.contentInset.bottom - self.height ;
    CGFloat offset = MIN(maxOffset, self.contentOffset.y);
    [self setContentOffset:CGPointMake(0, offset) animated:YES];
}

@end

@implementation TTVFrameBasedLinearLayoutItemSimpleContainer

- (UIView *)view {
    if ([_item isKindOfClass:[UIView class]]) {
        return _item;
    }
    else if ([_item isKindOfClass:[UIViewController class]]) {
        return [_item view];
    }
    return nil;
}

+ (id<TTVFrameBasedLinearLayoutItem>)containerWithView:(UIView *)view withEdgeInsets:(UIEdgeInsets)edgeInsets {
    TTVFrameBasedLinearLayoutItemSimpleContainer *container = [TTVFrameBasedLinearLayoutItemSimpleContainer new];
    container.item = view;
    container.edgeInsets = edgeInsets;
    return container;
}

+ (id<TTVFrameBasedLinearLayoutItem>)containerWithView:(UIView *)view withTopMargin:(CGFloat)topMargin {
    TTVFrameBasedLinearLayoutItemSimpleContainer *container = [TTVFrameBasedLinearLayoutItemSimpleContainer new];
    container.item = view;
    container.edgeInsets = UIEdgeInsetsMake(topMargin, 0, 0, 0);
    return container;
}

@end

@implementation TTVFrameBasedLinearLayoutItemView

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.width, self.height);
}

- (UIView *)view {
    return self;
}

- (UIEdgeInsets)edgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setFrame:(CGRect)frame {
    BOOL heightChanged = frame.size.height != self.frame.size.height;
    [super setFrame:frame];
    if (heightChanged) {
        [self.superview setNeedsLayout];
    }
}

@end

//
//  FHIndexSectionView.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/9.
//

#import "FHIndexSectionView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"

#define kFHIndexViewWidth  28.0

@interface FHIndexSectionView ()

@property (nonatomic) NSUInteger currentSection;
@property (nonatomic, assign)   CGFloat       kContentHeight;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, assign)   CGFloat       kIndexRowHeight;

@end

@implementation FHIndexSectionView

- (id)initWithTitles:(NSArray *)titles topOffset:(CGFloat)topOffset {
    if (titles.count <= 0) {
        return nil;
    }
    if (self = [super init]) {
        CGFloat kScreenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        CGFloat kScreenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        self.kIndexRowHeight = 20.0; // 行距，或者说是行高
        self.kContentHeight = titles.count * _kIndexRowHeight; // 总高度
        CGFloat bottomOffset = 20.0;
        if (topOffset + _kContentHeight + bottomOffset > kScreenHeight) {
            _kContentHeight = kScreenHeight - topOffset - bottomOffset;
            _kIndexRowHeight = _kContentHeight / titles.count;
        }
        self.frame = CGRectMake(kScreenWidth-kFHIndexViewWidth, topOffset, kFHIndexViewWidth, self.kContentHeight);
        _numberOfSections = titles.count;
        _titleArray = titles;
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews {
    if (self.titleArray.count <= 0) {
        return;
    }
    CGFloat labelH = _kIndexRowHeight;
    for (NSUInteger i = 0; i < self.titleArray.count; i++) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, i*labelH, kFHIndexViewWidth, _kIndexRowHeight)];
        label.text = self.titleArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:@"#081f33"];
        label.font = [UIFont themeFontMedium:12];
        [self addSubview:label];
    }
}

- (void)moveToSection:(NSInteger)section {
    if (section != _currentSection) {
        _currentSection = section;
        if (section < _numberOfSections && section >= 0) {
            if (_delegate) {
                [_delegate indexSectionView:self didSelecteedTitle:self.titleArray[_currentSection] atSectoin:_currentSection];
            }
        }
    }
}

#pragma mark - UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGFloat ratio = location.y / self.bounds.size.height;
    if (_delegate) {
        [_delegate indexSectionViewTouchesBegin];
    }
    NSUInteger newSection = ratio*_numberOfSections;
    [self moveToSection:newSection];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGFloat ratio = location.y / self.bounds.size.height;
    
    NSUInteger newSection = ratio*_numberOfSections;
    [self moveToSection:newSection];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (_delegate) {
        [_delegate indexSectionViewTouchesEnd];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_delegate) {
        [_delegate indexSectionViewTouchesEnd];
    }
}

@end

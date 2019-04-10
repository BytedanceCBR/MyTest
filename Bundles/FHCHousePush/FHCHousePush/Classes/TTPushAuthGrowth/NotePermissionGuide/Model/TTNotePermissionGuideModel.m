//
//  TTNotePermissionGuideModel.m
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import "TTNotePermissionGuideModel.h"




@implementation TTNotePermissionGuideModel

+ (instancetype)modelWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
                         image:(id)imageObject
                       buttons:(NSArray<NSString *> *)buttonTexts
{
    return [[self alloc] initWithTitle:title subTitle:subTitle image:imageObject buttons:buttonTexts];
}

- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                        image:(id)imageObject
                      buttons:(NSArray<NSString *> *)buttonTexts
{
    if ((self = [super init])) {
        _titleString = title;
        _subTitleString = subTitle;
        if ([imageObject isKindOfClass:[UIImage class]]) {
            _image = (UIImage *)imageObject;
        } else if ([imageObject isKindOfClass:[NSString class]]) {
            _imageURLString = (NSString *)imageObject;
        } else if ([imageObject isKindOfClass:[NSURL class]]) {
            _imageURLString = [(NSURL *)imageObject absoluteString];
        }
        _buttonTexts = buttonTexts;
    }
    return self;
}

- (BOOL)containsImage
{
    if (_image) return YES;
    if ([_imageURLString length] > 0) return YES;
    return NO;
}

- (CGSize)sizeForButtonTextIndex:(NSInteger)idx
{
    return CGSizeZero;
}

- (NSInteger)numberOfButtons
{
    return [_buttonTexts count];
}

+ (NSArray<NSString *> *)defaultStyle1ButtonText
{
    return @[@"再用用看", @"现在开启"];
}

+ (NSArray<NSString *> *)defaultStyle2ButtonText
{
    return @[@"现在开启"];
}

@end


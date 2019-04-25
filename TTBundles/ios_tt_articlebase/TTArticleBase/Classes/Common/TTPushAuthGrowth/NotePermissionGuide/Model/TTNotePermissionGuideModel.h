//
//  TTNotePermissionGuideModel.h
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import <Foundation/Foundation.h>



@interface TTNotePermissionGuideModel : NSObject
@property (nonatomic,   copy) NSString *titleString;
@property (nonatomic,   copy) NSString *subTitleString;
@property (nonatomic, strong) UIImage  *image;
@property (nonatomic,   copy) NSString  *imageURLString;
@property (nonatomic, strong) NSArray<NSString *> *buttonTexts;

+ (instancetype)modelWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
                         image:(id)imageObject
                       buttons:(NSArray<NSString *> *)buttonTexts;

- (BOOL)containsImage;

- (NSInteger)numberOfButtons;

- (CGSize)sizeForButtonTextIndex:(NSInteger)idx;

+ (NSArray<NSString *> *)defaultStyle1ButtonText;

+ (NSArray<NSString *> *)defaultStyle2ButtonText;

@end

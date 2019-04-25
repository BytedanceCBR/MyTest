//
//  TTVideoFloatActionButton.h
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import "SSThemed.h"
#import "TTVideoFloatProtocol.h"

@interface TTVideoFloatActionButton : SSThemedView<TTStatusButtonDelegate>
- (_Nonnull instancetype)initWithImageName:( NSString * _Nullable )imageName
                      highlightedImageName:( NSString * _Nullable )highlightedImageName;
@property (nonatomic, copy,nonnull) NSString *title;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL seleted;
@property (nonatomic, copy ,nonnull) NSString *seletedImageName;
@property (nonatomic, copy ,nonnull) NSString *seletedImageNameHighlighted;
- ( UIImageView * _Nonnull )iconImageView;
- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end

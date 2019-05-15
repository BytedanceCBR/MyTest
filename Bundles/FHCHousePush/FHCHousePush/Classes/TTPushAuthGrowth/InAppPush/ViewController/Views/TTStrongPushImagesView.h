//
//  TTStrongPushImagesView.h
//  Article
//
//  Created by liuzuopeng on 03/07/2017.
//
//

#import <SSThemed.h>



@interface TTStrongPushImagesView : SSThemedView

@property (nonatomic, strong) NSArray<id/** NSString NSURL UIImage */> *images;

- (BOOL)containsImage;

- (NSInteger)numberOfImages;

@end

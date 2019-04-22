//
//  ExploreDetailSaveImageManager.h
//  Article
//
//  Created by 王双华 on 15/11/6.
//
//

#import <Foundation/Foundation.h>
#import "TTSaveImageAlertView.h"

@interface ExploreDetailSaveImageManager : NSObject
@property (nonatomic, copy)NSString *imageUrl;

- (void)showOnWindowFromViewController:(UIViewController<TTSaveImageAlertViewDelegate> *)viewController;
- (void)saveImageData;
- (void)saveImageToAlbum;
- (void)destructSaveAlert;
@end

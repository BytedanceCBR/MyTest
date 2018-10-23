//
//  SSShowImageView.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-12.
//
//

#import <UIKit/UIKit.h>
//#import "SSViewBase.h"
#import "SSImageInfosModel.h"

@protocol SSShowImageViewDelegate;

@interface SSShowImageView : UIView

@property(nonatomic, retain)NSString * largeImageURLString;
@property(nonatomic, retain)SSImageInfosModel * imageInfosModel;
@property(nonatomic, assign)id<SSShowImageViewDelegate>delegate;

- (void)resetZoom;
- (void)refreshUI;
@end

@protocol SSShowImageViewDelegate<NSObject>
@optional

- (void)showImageViewOnceTap:(SSShowImageView *)imageView;
- (void)showImageViewDoubleTap:(SSShowImageView *)imageView;



@end

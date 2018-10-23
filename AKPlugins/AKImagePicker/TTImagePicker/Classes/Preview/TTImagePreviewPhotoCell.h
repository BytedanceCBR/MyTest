//
//  TTImagePreviewPhotoCell.h
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import <UIKit/UIKit.h>
#import "TTAssetModel.h"
#import "TTImagePreviewPhotoView.h"
@class TTImagePreviewViewController;

@interface TTImagePreviewBaseCell : UICollectionViewCell

@property (nonatomic, strong) TTAssetModel *model;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) TTImagePreviewViewController *myVC;

@property (nonatomic, copy) void (^singleTapGestureBlock)(TTImagePreviewBaseCell* cell);

- (void) willDisplay;
- (void) didDisplay;
@end

@interface TTImagePreviewPhotoCell : TTImagePreviewBaseCell

@property (nonatomic, strong) TTImagePreviewPhotoView *previewView;

@end

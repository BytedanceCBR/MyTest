//
//  TTImagePreviewVideoCell.h
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import <UIKit/UIKit.h>

#import "TTImagePreviewPhotoCell.h"

#import "TTImagePreviewVideoManager.h"

@interface TTImagePreviewVideoCell : TTImagePreviewBaseCell

@property(nonatomic, weak) TTImagePreviewVideoManager* videoManager;
@property(nonatomic, strong, readonly) TTImagePreviewVideoView* videoView;

@end

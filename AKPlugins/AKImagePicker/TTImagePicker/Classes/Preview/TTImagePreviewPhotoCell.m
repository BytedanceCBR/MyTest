//
//  TTImagePreviewPhotoCell.m
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import "TTImagePreviewPhotoCell.h"
#import "TTImagePickerTrackManager.h"

@implementation TTImagePreviewBaseCell

- (void)willDisplay {

}

- (void)didDisplay {

}

@end


@implementation TTImagePreviewPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.previewView = [[TTImagePreviewPhotoView alloc] initWithFrame:self.bounds];
        __weak typeof(self) weakSelf = self;
        [self.previewView setSingleTapGestureBlock:^{
            if (weakSelf.singleTapGestureBlock) {
                weakSelf.singleTapGestureBlock(weakSelf);
            }
        }];
       
        [self addSubview:self.previewView];
    }
    return self;
}

- (void)setModel:(TTAssetModel *)model {
    [super setModel:model];
    _previewView.myVC = self.myVC;
    _previewView.model = model;
}

- (void)willDisplay {
    [_previewView recoverSubviews];
}

- (void)didDisplay {
    
    [_previewView photoViewDidDisplay];
}
@end

//
//  TTVFeedContainerBaseView.h
//  Article
//
//  Created by panxiang on 2017/4/25.
//
//

#import <Foundation/Foundation.h>
#import "TTVideoFeedListEnum.h"
#import "TTVFeedCellAppear.h"
#import "SSThemed.h"

@class TTVFeedCellSelectContext;
@class TTVFeedCellEndDisplayContext;
@class TTVFeedCellWillDisplayContext;
@class TTVFeedCellForRowContext;

@interface TTVFeedContainerBaseView : SSThemedView<TTVFeedCellAppear>
@end

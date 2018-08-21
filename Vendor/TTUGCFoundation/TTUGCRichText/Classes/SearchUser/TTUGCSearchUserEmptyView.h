//
//  TTUGCSearchUserEmptyView.h
//  Article
//
//  Created by Jiyee Sheng on 15/09/2017.
//
//

#import "SSThemed.h"
#import "UIViewController+Refresh_ErrorHandler.h"


@interface TTUGCSearchUserEmptyView : SSThemedView <ErrorViewProtocal>

@property (nonatomic, strong) SSThemedLabel *errorMsg;
@property (nonatomic, strong) SSThemedImageView *errorImage;
@property (nonatomic, assign) TTFullScreenErrorViewType viewType;

@end

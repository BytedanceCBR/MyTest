//
//  DetailImageViewController.h
//  SSAppsUI
//
//  Created by Dianwei on 13-9-5.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface DetailImageViewController : MWPhotoBrowser
- (void)refreshWithDetailID:(NSString*)detailID;
@end

//
//  TFDetailViewController.h
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-29.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFAppInfosModel.h"

@interface TFDetailViewController : UIViewController

- (id)initWithTFAppInfosModel:(TFAppInfosModel *)model infoIndex:(NSUInteger)index;

@end

//
//  SSPhotoScrollViewController.h
//  Article
//
//  Created by Zhang Leonardo on 12-12-4.
//
//

#import <UIKit/UIKit.h>
#import "SSImageInfosModel.h"

@interface SSPhotoScrollViewController : UIViewController

@property(nonatomic, assign, readonly)NSInteger currentIndex;
@property(nonatomic, assign)NSInteger startWithIndex;
@property(nonatomic, assign, readonly)NSInteger photoCount;

@property(nonatomic, retain)NSArray * imageURLs;
//@property(nonatomic, retain)NSArray * imageURLWithHeaders;//every item also is array, and it contains url and header infos
@property(nonatomic, retain)NSArray * imageInfosModels;


@end

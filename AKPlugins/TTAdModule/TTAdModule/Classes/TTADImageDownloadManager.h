//
//  TTADImageDownloadManager.h
//  Article
//
//  Created by ranny_90 on 2017/3/21.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"

@interface TTADImageDownloadManager : NSObject

+ (instancetype)sharedManager;

-(void)startDownloadImageWithImageInfoModel:(TTImageInfosModel *)imageInfoModel;

@end

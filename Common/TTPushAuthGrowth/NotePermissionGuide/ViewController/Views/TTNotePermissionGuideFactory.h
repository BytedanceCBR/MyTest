//
//  TTNotePermissionGuideFactory.h
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTNotePermissonGuideView.h"



typedef NS_ENUM(NSInteger, TTNotePermissionGuideStyle) {
    TTNotePermissionGuideUnsupported,
    TTNotePermissionGuideStyle1,
    TTNotePermissionGuideStyle2,
};

@interface TTNotePermissionGuideFactory : NSObject

+ (TTNotePermissonGuideView *)permissionGuideViewForStyle:(TTNotePermissionGuideStyle)style;

@end

//
//  UIView+UGCAdditions.h
//  Article
//
//  Created by SongChai on 2017/4/23.
//
//

#import <UIKit/UIKit.h>

@interface UIView (UGCAdditions)
- (id) ugc_addSubviewWithClass:(Class)viewClass;
- (id) ugc_addSubviewWithClass:(Class)viewClass frame:(CGRect)frame;
- (id) ugc_addSubviewWithClass:(Class)viewClass themePath:(NSString*) themePath;
@end

//
//  AKProfileHeaderViewInfoView.h
//  Article
//
//  Created by chenjiesheng on 2018/3/5.
//

#import <UIKit/UIKit.h>

@interface AKProfileHeaderInfoView : UIView

- (void)setupUserName:(NSString *)name;
- (void)setupAvatorImageWithImageURL:(NSString *)url;
- (void)setupUserName:(NSString *)name avatorImage:(NSString *)imageURL;
@end

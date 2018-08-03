//
//  TTAvatarDecoratorView.m
//  TTAvatar
//
//  Created by lipeilun on 2018/1/4.
//

#import "TTAvatarDecoratorView.h"
#import "TTThemeManager.h"
#import "TTAvatarDecoratorManager.h"
#import <NSDictionary+TTAdditions.h>

@interface TTAvatarDecoratorView()
@property (nonatomic, copy) NSString *innerUrl;
@end

@implementation TTAvatarDecoratorView

- (void)showAvatarDecorator {
    [self refreshDecoratorImage];
}

- (void)hideAvatarDecorator {
    self.hidden = YES;
}

- (void)refreshDecoratorFrame:(CGRect)frame {
    self.frame = CGRectMake(kDecoratorOriginFactor * frame.size.width, kDecoratorOriginFactor * frame.size.height, kDecoratorSizeFactor * frame.size.width, kDecoratorSizeFactor * frame.size.height);
    [self showAvatarDecorator];
}

- (void)themeChanged:(NSNotification *)notification{
    if (!self.hidden) {
        [self refreshDecoratorImage];
    }
}

- (void)refreshDecoratorImage {
    if (!isEmptyString(_innerUrl)) {
        [[TTAvatarDecoratorManager sharedManager] setupDecoratorWithUrl:_innerUrl nightMode:!_disableNightCover completion:^(UIImage *img) {
            if (img) {
                self.image = img;
                self.hidden = NO;
            } else {
                [self refreshUserDecorator];
            }
        }];
    } else {
        [self refreshUserDecorator];
    }
}

- (void)refreshUserDecorator {
    if (!isEmptyString(_userID)) {
        [[TTAvatarDecoratorManager sharedManager] setupDecoratorWithUserID:_userID nightMode:!_disableNightCover completion:^(UIImage *img) {
            if (img) {
                self.image = img;
                self.hidden = NO;
            } else {
                self.hidden = YES;
            }
        }];
    } else {
        self.hidden = YES;
    }
}

- (void)setDecoratorInfoString:(NSString *)decoratorInfoString {
    if (![decoratorInfoString isKindOfClass:[NSString class]]) {
	_innerUrl = nil;
        return;
    }
    
    _decoratorInfoString = decoratorInfoString;
    if (!isEmptyString(decoratorInfoString)) {
        NSData *data = [decoratorInfoString dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSError *error = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            _innerUrl = [dict tt_stringValueForKey:@"url"];
        } else {
            _innerUrl = nil;
        }
    } else {
        _innerUrl = nil;
    }
}

@end

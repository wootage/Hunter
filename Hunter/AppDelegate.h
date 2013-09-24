#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    int time;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSTimer *timer;

@end

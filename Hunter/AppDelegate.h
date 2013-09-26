#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    int time;
    int delay;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UILocalNotification *notif;

@end

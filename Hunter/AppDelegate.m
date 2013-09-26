#import "AppDelegate.h"
#import "ApiCalls.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _notif = [[UILocalNotification alloc]init];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    time = 10;
    UIBackgroundTaskIdentifier bgTask = 0;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(prepareToHunt)
                                                 name: @"prepareToHunt"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sessionExpired:)
                                                 name: @"sessionExpired"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sessionExpired:)
                                                 name: @"connectionFailed"
                                               object: nil];
    [self hunt];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] cancelLocalNotification:_notif];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"prepareToHunt" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionExpired" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionFailed" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [_timer invalidate];
}

- (void)prepareToHunt {
    
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *isLogged = [saved objectForKey:@"isLogged"];
    int remining = [[saved objectForKey:@"timeRemining"]intValue];
    
    if ([isLogged isEqualToString:@"false"]) {
        [_timer invalidate];
    }else {
        
        time = remining + arc4random_uniform(30) + 30;
        //NSLog(@"time remining : %d",remining);
        //NSLog(@"%d",time);
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(hunt) userInfo:nil repeats:NO];
    }
}

- (void)hunt {
    [[ApiCalls sharedClient]hunt];
}

- (void) sessionExpired: (NSNotification *)notification {

    NSString *name = [notification name];
    
    if ([name isEqualToString:@"connectionFailed"]) {
        [_notif setAlertBody:@"Internet connection failed"];
    }else {
        [_notif setAlertBody:@"Please login"];
    }
    
    [_notif setSoundName:UILocalNotificationDefaultSoundName];
    
    [_notif setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [_notif setTimeZone:[NSTimeZone defaultTimeZone]];
    
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:_notif]];
}


@end

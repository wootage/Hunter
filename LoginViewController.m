#import "LoginViewController.h"
#import "MainMenuViewController.h"
#import "ECSlidingViewController.h"
#import "ApiCalls.h"
#import "Alert.h"

@interface LoginViewController () {
    
    __weak IBOutlet UITextField *txtPassword;
    __weak IBOutlet UITextField *txtUsername;
    
    __weak IBOutlet UILabel *lblLog;
    __weak IBOutlet UILabel *lblDelay;
    __weak IBOutlet UISegmentedControl *segment;
    
    __weak NSUserDefaults *saved;
    
}
- (IBAction)btnMenuClicked:(id)sender;
- (IBAction)btnLoginClicked:(id)sender;
- (IBAction)modeChanged:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (![self.slidingViewController.underLeftViewController isKindOfClass:[MainMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    saved = [NSUserDefaults standardUserDefaults];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"background.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(resignAll)];
    
    [self.view addGestureRecognizer:tap];
    
    [self selectSegment];
    [self setLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(gameVersionSuccess:)
                                                 name: @"getGameVersionSuccess"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameVersionFail:)
                                                 name:@"getGameVersionFail"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginSuccess:)
                                                 name: @"loginSuccess"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginFail:)
                                                 name: @"loginFail"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(huntSuccess:)
                                                 name: @"huntSuccess"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(huntFail:)
                                                 name: @"huntFail"
                                               object: nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGameVersionSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGameVersionFail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginFail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"huntSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"huntFail" object:nil];
}

#pragma mark - Buttons

- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)btnLoginClicked:(id)sender {
    [[ApiCalls sharedClient]getGameVersion];
}

- (IBAction)modeChanged:(id)sender {
    NSString *mode = [segment titleForSegmentAtIndex: [segment selectedSegmentIndex]];
    [self setLabel];
    [saved setObject:mode forKey:@"option"];
}

- (void)selectSegment {
    
    NSString *mode = [saved objectForKey:@"option"];
    
    if ([mode isEqualToString:@"Tourney"]) {
        segment.selectedSegmentIndex = 0;
    }else if ([mode isEqualToString:@"Normal"]) {
        segment.selectedSegmentIndex = 1;
    }else {
        segment.selectedSegmentIndex = 2;
    }
}

- (void)setLabel {
    
    int index = segment.selectedSegmentIndex;
    
    if (index == 0) {
        [lblDelay setText:@"5s delay"];
    }else if (index == 1) {
        [lblDelay setText:@"30s - 120s delay"];
    }else {
        [lblDelay setText:@"30m - 45m delay"];
    }
}

- (void)resignAll {
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}

#pragma mark - Notification actions

- (void) gameVersionSuccess :(NSNotification *)anote {
    
    NSDictionary *response = [anote userInfo];
    NSString *gameVersion = [response objectForKey:@"game_version"];
    
    [saved setObject:gameVersion forKey:@"game_version"];
    
    [[ApiCalls sharedClient]login:txtUsername.text:txtPassword.text];
}

- (void) gameVersionFail :(NSNotification *)anote {
    NSLog(@"fail");
    //TODO
}

- (void)loginSuccess :(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    
    NSString *loginToken = [response objectForKey:@"login_token"];
    
    [saved setObject:loginToken forKey:@"login_token"];
    [saved setObject:@"true" forKey:@"isLogged"];
    [lblLog setText:@"You are logged in,minimize the app and let the hunt begin"];
}

- (void)loginFail:(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    NSString *jsonResponse = [response objectForKey:@"NSLocalizedRecoverySuggestion"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [jsonResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    NSDictionary *errors = [json objectForKey:@"error"];
    NSString *errorMessage = [errors objectForKey:@"message"];

    [lblLog setText:errorMessage];    
}

- (void)huntSuccess :(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    NSDictionary *jsonResponse = [response objectForKey:@"user"];
    NSArray *journal = [jsonResponse objectForKey:@"journals"];
    
    [saved setObject:@"900" forKey:@"timeRemining"];
    [saved synchronize];
    
    NSLog(@"hunted");
    //NSLog(@"%@",journal);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"prepareToHunt" object: nil userInfo:nil];
}

- (void)huntFail :(NSNotification *)anote {
    
    NSDictionary *response = [anote userInfo];
    
    NSString *connectionAvailable = [response objectForKey:@"NSLocalizedDescription"];
    
    if ([connectionAvailable isEqualToString:@"The Internet connection appears to be offline."]) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"sessionExpired" object:nil userInfo:nil];
        
    }else {
        
        NSString *jsonResponse = [response objectForKey:@"NSLocalizedRecoverySuggestion"];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [jsonResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                             options: NSJSONReadingMutableContainers
                                                               error: nil];
        NSDictionary *errors = [json objectForKey:@"error"];
        NSString *errorMessage = [errors objectForKey:@"message"];
        
        
        NSDictionary *user = [json objectForKey:@"user"];
        NSString *timeRemining = [user objectForKey:@"next_activeturn_seconds"];
        
        [saved setObject:timeRemining forKey:@"timeRemining"];        
        
        if ([errorMessage isEqualToString:@"An active session is required."]) {
            [saved setObject:@"false" forKey:@"isLogged"];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"sessionExpired" object: errorMessage userInfo:nil];
        }
        if ([errorMessage isEqualToString:@"You are out of bait."]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"sessionExpired" object: errorMessage userInfo:nil];
        }else {
            [saved synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName: @"prepareToHunt" object: nil userInfo:nil];
        }
        NSLog(@"%@",errorMessage);
       }
       //Possible errors :
    //You are out of bait.
    //You have recently been on a hunt.
    //An active session is required.
}

@end

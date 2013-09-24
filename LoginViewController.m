#import "LoginViewController.h"
#import "MainMenuViewController.h"
#import "ECSlidingViewController.h"
#import "ApiCalls.h"

@interface LoginViewController () {
    
    __weak IBOutlet UITextField *txtPassword;
    __weak IBOutlet UITextField *txtUsername;
    __weak NSUserDefaults *saved;
}
- (IBAction)btnMenuClicked:(id)sender;
- (IBAction)btnLoginClicked:(id)sender;

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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(session_taken:)
                                                 name: @"getGameVersionSuccess"
                                               object: nil];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failLogApiCall)
                                                 name:@"bg.BlackBear.8tracks.login_Fail"
                                               object:nil];*/
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginSuccess:)
                                                 name: @"loginSuccess"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginFail:)
                                                 name: @"loginFail"
                                               object: nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)btnLoginClicked:(id)sender {
    [[ApiCalls sharedClient]getGameVersion];
}

- (void) session_taken:(NSNotification *)anote {
    
    NSDictionary *response = [anote userInfo];
    
    NSString *gameVersion = [response objectForKey:@"game_version"];
    //[saved setObject:gameVersion forKey:@"game_version"];
    [[ApiCalls sharedClient]hunt:gameVersion];
    //[[ApiCalls sharedClient]login:txtUsername.text:txtPassword.text:gameVersion];
}

- (void)loginSuccess:(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    
    NSString *loginToken = [response objectForKey:@"login_token"];
    
    [saved setObject:loginToken forKey:@"login_token"];
    [saved setObject:@"true" forKey:@"isLogged"];
}

- (void)loginFail:(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    NSString *errors = [response objectForKey:@"NSLocalizedRecoverySuggestion"];

    NSLog(@"%@",errors);
}

- (void)huntFail:(NSNotification *)anote {
    NSDictionary *response = [anote userInfo];
    NSString *errors = [response objectForKey:@"NSLocalizedRecoverySuggestion"];
    
    NSLog(@"%@",errors);
}

@end

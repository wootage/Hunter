#import "Alert.h"

@implementation Alert

+ (void) showAlert:(NSString*)title :(NSString*)message {
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title message:message delegate: nil cancelButtonTitle: NSLocalizedString(@"ok", nil) otherButtonTitles: nil, nil];
    [alert show];
}

@end

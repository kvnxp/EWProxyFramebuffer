#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSString *imgState;
    NSString *driverState;
    NSMutableArray *Profiles;
    NSMutableArray *ProfileNames;
    io_service_t service;
    io_connect_t connect;
    int profileCount;
    int selectedMode;
}

@property (nonatomic,retain) NSMutableArray *ProfileNames;
@property (nonatomic,retain) NSIndexSet *selectedProfile;

@property (assign) IBOutlet NSWindow *window;

@property (readwrite, retain) IBOutlet NSMenu *menu;
@property (readwrite, retain) IBOutlet NSStatusItem *statusItem;

- (IBAction)menuAction:(id)sender;

- (IBAction) SwitchDriver:(id)sender;
- (IBAction) SwitchDriver1:(id)sender;
- (IBAction) SwitchDriver2:(id)sender;
- (IBAction) SwitchDriver3:(id)sender;
- (IBAction) SwitchDriverOff:(id)sender;
- (IBAction) SwitchDriverRes:(id)sender;


- (int) getIntForkey:(NSString *)key;
@end

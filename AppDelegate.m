#import "AppDelegate.h"

#include <IOKit/IOKitLib.h>
#include <EWProxyFrameBufferConnection/EWProxyFrameBuffer.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <netdb.h>
#include <IOKit/IOKitLib.h>
#include <mach/mach_time.h>

@implementation AppDelegate

- (void)awakeFromNib {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem retain];
    
    NSImage *menuIcon       = [NSImage imageNamed:@"Menu Icon"];
    NSImage *highlightIcon  = [NSImage imageNamed:@"Menu Icon"]; // Yes, we're using the exact same image asset.
    [highlightIcon setTemplate:YES]; // Allows the correct highlighting of the icon when the menu is clicked.
    
    [self statusItem].button.image = menuIcon;
    [self statusItem].button.alternateImage = highlightIcon;
    
//    [[self statusItem] setImage:menuIcon];
//    [[self statusItem] setAlternateImage:highlightIcon];
//    [[self statusItem] setHighlightMode:YES];
    [[self statusItem] setMenu:[self menu]];
    
    //check for driver. if found, set everything up.
    service=FindEWProxyFramebufferDriver();
    if(service==IO_OBJECT_NULL)
    {
//        self.driverState=@"Nicht geladen.";
    }
    else
    {
        //establish connection.
        //this call instantiates our user client class in kernel code and attaches it to
        //the IOService in question
        if(IOServiceOpen(service, mach_task_self(), 0, &connect)==kIOReturnSuccess)
        {
            //read the driver configuration and set up internal classes
            profileCount=EWProxyFramebufferDriverGetModeCount(connect);
            ProfileNames=[[NSMutableArray alloc] init];
            Profiles=[[NSMutableArray alloc] init];
            [self willChangeValueForKey:@"ProfileNames"];
            EWProxyFramebufferModeInfo data;
            for(int i=1;i<=profileCount;i++)
            {
                EWProxyFramebufferDriverGetModeInfo(connect, i, &data);
                [ProfileNames addObject:[NSString stringWithCString:data.name encoding:NSASCIIStringEncoding]];
                [Profiles addObject:[NSData dataWithBytes:&data length:sizeof(data)]];
            }
        
            NSInteger val = 0;
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if (standardUserDefaults) val = [standardUserDefaults integerForKey: @"selected-profile"];
            selectedMode = (int)val;
            
            [self updateProfiles];
            [self didChangeValueForKey:@"ProfileNames"];
            
            if (selectedMode > 0) {
                [self SwitchDriver: NULL];
            }
            
//            int state=EWProxyFramebufferDriverCheckFramebufferState(connect);
            //create a notification port and register it in our runloop.
            //this is nessecary for the cursor change events.
            //we can ask the notificationport for a mach_port which is then used in registerEvent functions
            //however we're not implementing them yet.
            //TODO
            IONotificationPortRef notifyPort=IONotificationPortCreate(kIOMasterPortDefault);
            CFRunLoopSourceRef rlsource=IONotificationPortGetRunLoopSource(notifyPort);
            CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], rlsource, kCFRunLoopDefaultMode);
        }
    }
}

- (void) updateProfiles {
    if (selectedMode<1 || selectedMode>profileCount) {
        selectedMode = 0;
    }
    for(int i=0;i<profileCount && i<3;i++)
    {
        NSMenuItem *menuItem = [[self menu] itemAtIndex: i];
        menuItem.title = [ProfileNames objectAtIndex: i];
        menuItem.state = (i == selectedMode-1) ? NSControlStateValueOn : NSControlStateValueOff;
    }

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults)
    {
        [standardUserDefaults setInteger:selectedMode forKey: @"selected-profile"];
        [standardUserDefaults synchronize];
    }
}

- (IBAction)menuAction:(id)sender {
    NSLog(@"menuAction:");
}

- (EWProxyFramebufferModeInfo*) getCurrentModeInfo
{
    NSData *data=[Profiles objectAtIndex:[self.selectedProfile firstIndex]];
    return (EWProxyFramebufferModeInfo*)[data bytes];
}

- (IBAction) SwitchDriver1:(id)sender {
    if (selectedMode == 1) {
        selectedMode = 0;
        [self SwitchDriverOff: sender];
        return;
    }
    selectedMode = 1;
    [self SwitchDriver: sender];
}

- (IBAction) SwitchDriver2:(id)sender {
    if (selectedMode == 2) {
        selectedMode = 0;
        [self SwitchDriverOff: sender];
        return;
    }
    selectedMode = 2;
    [self SwitchDriver: sender];
}

- (IBAction) SwitchDriver3:(id)sender {
    if (selectedMode == 3) {
        selectedMode = 0;
        [self SwitchDriverOff: sender];
        return;
    }
    selectedMode = 3;
    [self SwitchDriver: sender];
}

- (IBAction) SwitchDriverOff:(id)sender {
    int state=EWProxyFramebufferDriverCheckFramebufferState(connect);
    if(state!=0)
    {
        EWProxyFramebufferDriverDisableFramebuffer(connect);
    }
    [self updateProfiles];
}

- (IBAction) SwitchDriver:(id)sender
{
    [self SwitchDriverOff: sender];
    EWProxyFramebufferDriverEnableFramebuffer(connect, selectedMode);
}

//-(CGImageRef)getCursor
//{
//    unsigned int size;
//    int width, height;
//    //map the hardwarecursor memory into user space
//    unsigned char *buf=EWProxyFramebufferDriverMapCursor(connect, &size, &width, &height);
//    //same procedure: pointer->nsdata->cgadatprovider->cgimage
//    NSData *image=[NSData dataWithBytes:buf length:size];
//    CGDataProviderRef provider=CGDataProviderCreateWithCFData((CFDataRef)image);
//    CGImageRef cgimg=CGImageCreate(width, height, 8, 32, width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaLast, provider, NULL, NO, kCGRenderingIntentDefault);
//    //unmap the memory again.
//    EWProxyFramebufferDriverUnmapCursor(connect, buf);
//    CFRelease(provider);
//    return cgimg;
//}

@end

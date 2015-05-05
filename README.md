# ObjectiveLibModbus

This is an Objective-C wrapper class for the [*libmodbus library*](http://libmodbus.org). The wrapper is free to use for anyone (GNU Lesser Public License).

The wrapper only supports TCP for now. It does not wrap all of the libmodbus functions. I recommend reading the libmodbus documentation if you are missing some features. Chances are libmodbus already supports it! If you modify or extend the code, please contribute back!

## How To Get Started

The easiest way to get this working is to use [*CocoaPods*](http://cocoapods.org/)

If you dont use CocoaPods do this:

- Drag all the .c and .h files from the Vendor/libmodbus folder into you're project.
- Drag ObjectiveLibModbus.h and ObjectiveLibModbus.m into you're project from ObjectiveLibModbus folder.

Now that you're set up, do the following to make modbus calls

- Import ObjectiveLibModus where you will be using it:
``` objective-c
#import "ObjectiveLibModbus.h"
```

- Now make a new instance of ObjectiveLibModbus and connect:
``` objective-c
//Allocate a new ObjectiveLibModbus instance
objLibModbus = [[ObjectiveLibModbus alloc] initWithTCP:@"192.168.2.10" port:502 device:1];
[objLibModbus connect:^{
    //connected and ready to do modbus calls
} failure:^(NSError *error) {
    //Handle error
    NSLog(@"Error: %@", error.localizedDescription);
}];
```

- Make a modbus call:
``` objective-c
[objLibModbus readRegistersFrom:1000 count:5 success:^(NSArray *array) {
//Do something with the returned data (NSArray of NSNumber)..
NSLog(@"Array: %@", array);
} failure:^(NSError *error) {
//Handle error
NSLog(@"Error: %@", error.localizedDescription);
}];
```

- Disconnect when you are finished with you’re modbus calls:
``` objective-c
[objLibModbus disconnect];
```

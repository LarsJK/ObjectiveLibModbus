# SwiftLibModbus

This is a Swift port of Lars-Jørgen Kristiansen's ObjectiveLibModbus. For those who are not familiar with his work, it is a wrapper class for the [*libmodbus library*](http://libmodbus.org).

Currently, this project is a direct port of ObjectiveLibModbus. I tried to stay true to his code as much as can, but moving forward, my plan is to extend this to include more of the features available in libmodbus and also adding 32-bit data support. I'm also planning on adding other features like reading data from non-consecutive addresses (i.e. address 1, 10, and 20). I will try to port back some of those features to ObjectiveLibModbus as time permits.

## Just in case if you were wondering...

I started this project for few reasons. I originally used ObjectiveLibModbus in my modbus communication app and it worked amazingly, but it was a unwrapping nightmare for success/failure closures. I also noticed that many people were looking for a Swift Modbus Lirary (ok, it's not truly Swift library but one step closer). And through this project, I'm learning the differences between Swift and Objective-C.

## Oh, and one more thing...

Please feel free to add, modify, suggest, comment or whatever.

## How To Get Started

- Drag all the .c and .h files from the Vendor/libmodbus folder into you're project.
- Drag SwiftLibModbus.swift and SwiftLibModbus-Bridging-Header.h into you're project from SwiftLibModbus folder.
- Make sure to add SwiftLibModbus-Bridging-Header.h to the project's Build Setting. If you already have a Bridging Header, include copy and paste the content of SwiftLibModbus-Bridging-Header.h to your Bridging Header.

Now that you're set up, do the following to make modbus calls

- Now make a new instance of ObjectiveLibModbus and connect:
``` swift
let swiftLibModbus = SwiftLibModbus(ipAddress: "192.168.2.10", port: 502, device: 1)
swiftLibModbus.connect(
    { () -> Void in
        //connected and ready to do modbus calls
    },
    failure: { (error: NSError) -> Void in
        //Handle error
        print("error")
})
```

- Make a modbus call:
``` swift
swiftLibModbus.readBitsFrom(1000, count: 5,
    success: { (array: [AnyObject]) -> Void in
        //Do something with the returned data (NSArray of NSNumber)..
        print("success: \(array)")
    },
    failure:  { (error: NSError) -> Void in
        //Handle error
        print("error")
})
```

- Disconnect when you are finished with you’re modbus calls:
``` swift
swiftLibModbus.disconnect()
```

# Snake Metal Demo

A simple Snake game implemented in Swift using Cocoa, Metal, and MetalKit.

## Requirements

- macOS 10.15 or later
- Xcode Command Line Tools

## Building

Use the following command to compile the project:

```bash
swiftc -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
  -framework Cocoa \
  -framework Metal \
  -framework MetalKit \
  main.swift -o SnakeMetalDemo
```

## Running

After building, run the executable:

```bash
./SnakeMetalDemo
```

## Controls

- Arrow keys: Move the snake in the corresponding direction

## License

This project is licensed under the MIT License.

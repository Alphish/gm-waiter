# GM Waiter library

**Waiter** is a GameMaker library for handling long-running tasks and background processing. It features:
- **a base constructor for the long-running tasks** with methods for running processing steps in batches and tracking their status and progress
- **a task queue structure** for running multiple tasks according to their priorities on demand
- **a task processor service** for running multiple tasks according to their priorities based on the time left between frames
- **a task orders system** for further handling of received task results

You can also check out the [itch.io page](https://alphish-creature.itch.io/gm-waiter).

## Installation

- download the latest package version: [Alphish.Waiter.0.3.0.yymps](/Release/Alphish.Waiter.0.3.0.yymps?raw=1)
- open your GameMaker project
- open the package importing window via **Tools >> Import Local Package**
- add all assets to import and proceed

## Documentation

The following pages describe the package functionality in more detail:
- [Tasks module](/Docs/Overview/01%20-%20Tasks%20module.md)
- [Processing module](/Docs/Overview/02%20-%20Processing%20module.md)
- [Orders module](/Docs/Overview/03%20-%20Orders%20module.md)

## Demonstration

You can check out the demonstration of the package functionality.

Just download [Waiter Demo.yyz](/Release/Waiter%20Demo.yyz?raw=1), then open GameMaker and import the file via **File >> Import project**. After that, you can run the project to see how the system works in practice, and check out assets in the Demo group to see how specific tasks were implemented.

Alternatively, you can download the demo executable from the [itch.io page](https://alphish-creature.itch.io/gm-waiter). However, you won't be able to check the source code as easily.

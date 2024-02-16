[<< Back to home](/README.md)

[<< 02 - Processing module](/Docs/Overview/02%20-%20Processing%20module.md) | **03 - Orders module**

-----

# Orders module

The orders module provides a functionality for **executing custom logic upon the task completion**, whether a success or a failure. It allows the Waiter task to focus on producing its result, leaving subsequent handling to the orders.

The module consists of the following assets (placed in the **Orders** folder within the package):
- **struct_WaiterOrder** script, which contains the `WaiterOrder` constructor
- **struct_WaiterOrderBuilder** script, which contains the `WaiterOrderBuilder` constructor
- **ctrl_WaiterOrderManager** persistent object
- **spr_WaiterTaskProcessor** sprite for the Waiter order manager object, so that it can be recognised in the Room Editor more easily

To use Waiter task orders, **the order manager instance must be available**, and only one such instance can be created at the time. It's recommended to put it in the very first room of the game, so that it's available from the start.

## Task outcomes handling

Each Waiter order is associated with one task. It uses the following functions to handle task outcomes:
- the **success handler**, executed with the following arguments: *the task result, the task, the order*
- the **failure handler**, executed with the following arguments: *the task failure object, the task, the order*
- the **completion handler**, executed with the following arguments: *the task, the order*

Depending on how the task concludes, different functions are executed:
- when the task completes successfully, the **success handler** is executed followed by the **completion handler**
- when the task fails, the **failure handler** is executed followed by the **completion handler**
- when the task is aborted, all its orders are canceled and no order-specific logic is executed

If a task result handler is a bound method, it remains bound to the original context. If it's an unbound function, it's wrapped in a method bound to the `WaiterOrder` instance.

## Placing orders

The most straightforward way to make an order is to use `WaiterOrder` constructor, accepting the following arguments:
- `task` - the task whose outcome is to be handled by the order
- `onsuccess` - the success handler
- `onfailure` - the failure handler
- `oncompletion` - the completion handler

Creating a new `WaiterOrder` with the constructor will automatically add the order to the order manager, making it ready to be fulfilled once the task completes.

-----

An alternative is to use the order builder, which allows chaining setup methods. The building can be started with `WaiterOrder.for_task(task)` static method or `task.begin_order()` task method. Then, the following methods can be chained to setup the handlers:
- `on_success(handler)` - adds a success handler to the newly built order
- `on_failure(handler)` - adds a failure handler to the newly built order
- `on_completion(handler)` - adds a completion handler to the newly built order

Finally, the new order is created by calling the `place()` method at the end of the order builder chain.

Preparing an example order with all three handlers:
```gml
debug_order = task.begin_order()
    .on_success(function(_result) { show_debug_message($"Task succeeded! Received: {_result}"); })
    .on_failure(function(_failure) { show_debug_message($"Oh no! Task failed because: {_failure}"); })
    .on_completion(function(_result) { show_debug_message($"Either way, at least the task wasn't aborted."); })
    .place();
```

*Note: If the order is placed after the task already concluded, the success/failure/completion handling will execute immediately according to whichever way the task concluded.*

## Cancelling orders

To cancel a single order, just call its `cancel()` method.

To cancel all orders associated with a task, call the `cancel_orders()` method of the task or the `cancel_task_orders(task)` method of the Waiter order manager.

To cancel all pending orders in existence, call the `cancel_all_orders()` method of the Waiter order manager.

## Checking order status

You can check whether the order has been cancelled or fulfilled with its `is_concluded()` method, similar to same-named method of the task. Just like the task won't perform any subsequent processing once concluded, so the order won't perform any additional handling.

## Other remarks

Since the orders execute immediately upon the task completion, they shouldn't perform any time-consuming logic or they might overextend the task run (admittedly, it's an oversight on my part).

Depending on your use-case, you may consider other alternatives, such as having a task instance stored by a struct or an object instance and reacting to the task state every frame. It might turn out your project wouldn't really benefit from task order mechanics and thus not use task orders at all, saving you the setup of the Waiter order manager. At the end of the day, it's the developer who knows their project best and decides which of the tools available should be used.

-----

[<< 02 - Processing module](/Docs/Overview/02%20-%20Processing%20module.md) | **03 - Orders module**
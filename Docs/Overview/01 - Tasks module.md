[<< Back to home](/)

**01 - Tasks module** | [02 - Processing module >>](/Docs/Overview/02%20-%20Processing%20module.md)

-----

# Tasks module

The tasks module provides the base for long-running tasks, which allows:
- **dividing a time-consuming logic into smaller chunks** that can be processed across multiple frames
- **running processing steps in batches** of specific duration or until the given time
- tracking the task **status and progress**

The module consists of the following assets (placed in the **Tasks** folder within the package):
- **enum_WaiterTaskStatus** script, which contains `WaiterTaskStatus` enumeration
- **struct_WaiterTask** script, which contains `WaiterTask` base constructor 

Aside from implementing custom tasks inheriting from the `WaiterTask` constructor, there is no particular setup required to make the tasks usable.

## Implementing a task

To create a custom long-running task, define a constructor inheriting from the `WaiterTask` base. It provides several common variables and methods for processing, managing and retrieving results of the task.

**The custom task must define its own `process()` method**, which performs a single processing step of the task core logic.

On top of that, the following methods can be overriden:
- `setup()` - a method that performs necessary initialisations before the first run of the task
- `cleanup(status)` - a method for cleaning up the temporary task data etc.; the cleanup process might be fine-tuned with the *status* argument, containing the status the task is about to conclude with
- `get_status_description()` - a method that returns a string description of the current task status
- `get_progress_description()` - a method that returns a string description of the task progress; used by the default `get_status_description()` implementation when the task is in progress

### Implementing `process()`

As mentioned earlier, the `process()` method performs a single processing step of the task core logic. In particular, it indicates whether the task has ended - if it returns **true**, the task has concluded; if it returns **false**, there is still more processing to be done.

However, there is a variety of frequent outcomes that are more fine-grained than returning **true** or **false**. To handle these, there are special methods returning the appropriate **true** or **false** result while also updating the task state accordingly.

The following process outcome methods are available:
- `proceed()` - indicates the task is still in progress and can continue the current run
- `proceed_later()` - indicates the task is still in progress, but it should wait for another run; for example, if the task needs a result of HTTP request to proceed, continuing the run before receiving the response would be a waste of processing resources
- `progress_to(value)` - indicates the task is still in progress and sets the current progress to the given value
- `progress_by(value)` - indicates the task is still in progress and increases the current progress by the given value
- `succeed_with(result)` - concludes the task as successful with the given result value
- `fail_with(failure)` - concludes the task as a failure with the given failure details value

Generally, it's recommended to return the results of the process outcomes methods described above, as opposed to the raw **true** or **false** values. Not only they take care of some common operations (e.g. updating progress value, updating the task status, setting the task result), their names should also make the intent clearer.

### Implementing `setup()` and `cleanup(status)`

Aside from the core processing logic, `WaiterTask` also allows handling initialisation and cleanup of the task via `setup()` and `cleanup(status)` methods.

The `setup()` method typically contains a general initialisation logic. One of the common tasks would be creating manually managed resources (such as surfaces, DS data structures, buffers etc.), as opposed to garbage-collected resources (like arrays and structs). The setup method may also prepare the data to process. Generally speaking, custom Waiter tasks should avoid putting complex initialisation logic in the constructor, instead putting it in the `setup()` method instead.

The `cleanup(status)` method would usually free any resources that `setup()` reserved, especially the manually managed resources. It can use the *status* argument to adapt its cleanup logic for the task outcome. E.g. if the task was filling up a DS grid with procedurally generated data, then it could store grid itself as the result upon success and destroy the grid in case of a failure or aborting.

The `setup()` and `cleanup(status)` methods are direct counterparts. The `setup()` method is executed on the first task. Conversely, if no task runs are performed - e.g. because the task was aborted before getting its turn or because it was created in a concluded state in the first place - then `setup()` method won't be executed, either. Likewise, the `cleanup(status)` method will execute only when the task has run at least once, thus executing its `setup()` logic. Thus, any resources to be freed by the `cleanup(status)` method should be defined in the `setup()` method, rather than the task constructor.

### Customising status description

Aside from `process()`, `setup()` and `cleanup(status)` the developer may also choose to override `get_status_description()` and/or `get_progress_description()`. These may be used for debugging or for showing the user a human-readable information about the task state.

By default, `get_status_description()` will return the following strings:
- *"Pending..."* - when the task has been created but haven't had its first run yet
- *"In progress..."* - when the task has started and is still ongoing, but doesn't track progress
- the result of `get_progress_description()` - when the task has started and keeps track of the progress
- *Aborted!"* - when the task has been aborted before it could finish with a result or failure
- *"Failed!"* - when the task has finished with a failure
- *"Done!"* - when the task has finished with a success

If someone needs a completely different set of status descriptions, they may override `get_status_description()` altogether.

On the other hand, if someone is fine with the default selection of status descriptions but wants to tweak the displayed progress, they can override `get_progress_description()` instead. The default format of the progress description messages is *"current/target"* (e.g. "123/456"), where "current" is the current progress and "target" is the goal to reach in order to complete the task.

## Task management

### Running the task

To perform the task processing, the following methods are available:
- `run_once()` - performs a single processing step of the task
- `run_batch(duration,[repeats])` - runs a batch of processing steps for a given duration (in milliseconds); a minimum number of steps in the batch can be additionally specified
- `run_batch_until(time,[repeats])` - runs a batch of processing steps until reaching a given time, as returned by the [get_timer()](https://manual.gamemaker.io/monthly/en/#t=GameMaker_Language%2FGML_Reference%2FMaths_And_Numbers%2FDate_And_Time%2Fget_timer.htm) built-in function; a minimum number of steps in the batch can be additionally specified
- `run_to_end()` - runs the task until it concludes or the run is delayed

**For most intents and purposes one should use `run_batch` and `run_batch_until` functions.**

Executing `run_once()` once per frame could lead to the task taking too much time, and executing it repeatedly according to the game timer is just more overhead-burdened version of running batches. It may be useful for testing (making sure the task has the correct state after the Nth step) and for cases when task progress running uniformly would be nice visually (e.g. a floodfill pathfinding algorithm gradually revealing reachable cells).

Executing `run_to_end()` can be fine for general debugging and prototyping, as well as for tests that only check the final result (even more so if tested data is smaller than actual in-game data).

In some cases, a task may be required to finish before progressing with the in-game action; for example, the player could initiate dialogue with an NPC before that NPC's dialogue data was loaded. In such a scenario one may be tempted to execute `run_to_end()` to get the needed result immediately. However, this may result in temporary game freezes as the game tries finishes a potentially large task. Instead, it's recommended to setup some kind of loading object that will process the task without freezing the game and potentially show a non-intrusive loading indicator.

### Aborting the task

Sometimes it turns out the result of the given task is no longer needed; for example, the task was loading data specific to a certain area that player immediately left. In such cases, the task can be concluded with the `abort()` method. It will perform any necessary cleanup (assuming the task was ever run in the first place) and it will prevent any further processing.

### Checking task status

The `WaiterTask` base provides a number of methods for checking the task status. One of these is already described `get_status_description()` which roughly describes the current task state.

Aside from that, the following methods are available:
- `is_pending()` - checks whether the task is waiting for its first run
- `is_running()` - checks whether the task is in progress (after at least one run) and wasn't delayed in its last run
- `is_delayed()` - checks whether the task was delayed in its last run
- `is_concluded()` - checks whether the task reached one of its end states (successful, failed, aborted)
- `is_succesful()` - checks whether the task finished successfully
- `is_failed()` - checks whether the task finished with a failure
- `is_aborted()` - checks whether the task was aborted before it could finish

### Tracking progress

One of the `WaiterTask` features includes progress tracking through variables **progress_current** and **progress_total**. It's nowhere near smart enough to estimate the progress on its own, but it provides several methods to incorporate progress tracking into task processing, as well as different ways to show progress data.

*Note: The Waiter implementation reasonably assumes that the target progress is larger than 0 and the current progress must be somewhere between 0 and the target progress. Also, whenever the Waiter task completes successfully, the progress value is automatically set to the target.*

By default, progress variables are undefined, and thus don't provide any progress tracking information. Progress tracking can be enabled with `begin_progress_toward(total)` method - it sets the target progress to the given total and the current progress to zero. Usually this method would be called somewhere in the `setup()` function.

Moreover, the current progress value can be updated with `progress_to(value)` and `progress_by(value)` returns of the `process()` function.

Aside from that, the following functions are available to retrieve progress information:
- `get_progress_amount()` - gets the amount of progress normalised to 0-1 range (i.e. 0 corresponds to no progress, 1 corresponds to the target)
- `get_progress_out_of_total()` - gets a string describing the progress as a *"current/total"* string; it also serves as the default implementation of `get_progress_description()`
- `get_progress_percentage([precision])` - gets a string with the progress percentage (0% corresponds to no progress, 100% corresponds to the target)

## Limitations and caveats

GameMaker in its current form doesn't expose any built-in multithreading or asynchronous processing functionality, not for arbitrary GML. Instead, Waiter tasks are executed within the main game loop, alongside the core mechanics and drawing. Thus, it's the developer's responsibility to ensure that the long-running tasks don't go on for too long and don't cause framerate drops.

In particular, the batch running functions are designed in a way that the processing stops *just after* exceeding the target time, rather than *just before* it. In a large part, that's because estimating whether the given processing would go over the planned time or not would overcomplicate things for little benefit - for the most part, a batch of 5.008ms isn't all that worse than a batch of 4.995ms.

Still, the longer the individual processing steps are, the greater room for imprecision. For example, if a processing step can get 1.500ms long, a batch planned for 5.000ms run would stretch to 6.500ms. Thus, to prevent random framerate drops, it's worth aiming for processing steps no longer than hundreds of microseconds (i.e. tenths of milliseconds) or so.

A custom Waiter task may run for a given duration or until a specific time when told to, but it won't figure out the optimal time to run for on its own. That's where the [Waiter task processor](/Docs/Overview/02%20-%20Processing%20module.md) comes in, though it has some caveats of its own.

-----

**01 - Tasks module** | [02 - Processing module >>](/Docs/Overview/02%20-%20Processing%20module.md)
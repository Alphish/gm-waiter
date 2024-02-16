[<< Home](/README.md)
[<< 01 - Tasks module](/Docs/Overview/01%20-%20Tasks%20module.md) | **02 - Processing module** | [03 - Orders module >>](/Docs/Overview/03%20-%20Orders%20module.md)

-----

# Processing module

The processing module provides utilities for higher-level task processing. In particular:
- it defines **Waiter task queues processing many tasks at once**, according to their priorities
- it defines **the Waiter task processor which runs its tasks in the background**, trying to make the most of the free time between frames

The module consists of the following assets (placed in the **Processing** folder within the package):
- **struct_WaiterTaskQueue** script, which contains the `WaiterTaskQueue` constructor
- **struct_WaiterTaskQueueNode** script, which contains the `WaiterTaskQueueNode` constructor (as an internal constructor it shouldn't be used by developer's own code)
- **ctrl_WaiterTaskProcessor** persistent object
- **spr_WaiterTaskProcessor** sprite for the Waiter task processor object, so that it can be recognised in the Room Editor more easily

Waiter task queues can be freely instantiated and used without any additional setup.

**The Waiter task processor instance needs to be placed/created somewhere in order to work.** It's recommended to put it in the very first room of the game, so that it's available from the start. You may want to tweak the task processor's Object Variables to whatever works best; read the section about Waiter task processor setup for more details.

## Using task queues

*Note: While Waiter task queue concepts are useful to know, using Waiter task processor - with its own task queue under the hood - will be often preferred to creating and managing the task queues manually.*

A Waiter task queue allows organising many Waiter tasks together and processing them according to their priorites. To create one, just call its constructor.


### Managing tasks

The Waiter task queue provides the following methods for managing the tasks in the queue:
- `enqueue(task,[priority])` - adds the task to the queue with the given priority (0 by default)
- `dequeue(task)` - remove the task from the queue
- `change_priority(task,priority)` - changes the priority of the given task to the new value
- `has_task(task)` - checks whether the given task is in the queue or not

### Running tasks

The Waiter task queue provides the following methods for running its tasks:
- `run_once()` - performs a single processing step of the upcoming task
- `run_batch(duration,[repeats])` - runs a batch of processing steps for a given duration (in milliseconds) and with a given minimum number of processing steps
- `run_batch_until(time,[repeats])` - runs a batch of processing steps until reaching a given time, as returned by the [get_timer()](https://manual.gamemaker.io/monthly/en/#t=GameMaker_Language%2FGML_Reference%2FMaths_And_Numbers%2FDate_And_Time%2Fget_timer.htm) built-in function and with a given minimum number of processing steps

If the task queue finishes a task before running out of batch time, it will proceed to the next available task, until no more tasks are left. However, the **repeats** argument applies only to the first task picked by the queue, even if it ultimately runs for fewer steps before finishing. That's because tracking the actual number of processed steps would mostly add some hassle and processing overhead for next to no benefit.

Among tasks of the same priority, the queue will cycle through them across runs, spreading the processing powers roughly evenly. E.g. if the queue has tasks A/B/C at the top priority, it will run task A batch in the first frame, then it'll run task B batch in the second frame, then it'll run task C batch in the third frame and in the fourth frame it'll be back to task A. That way if it turns out one of the tasks must be urgently finished, it will have a significant portion already done regardless of its position within the same priority. Also, shorter tasks will be completed sooner without waiting for the longer ones to finish.

A task will be automatically removed from the queue once concluded, whether through the queue processing or from elsewhere (e.g. it was aborted). It keeps the queue clutter-free and also makes it poor as a general tasks storage structure (it doesn't need to be such a structure, anyway). 

### Cleanup

Since the Waiter task queue uses some DS map structures under the hood, it needs to be cleaned up when it's no longer used. For this purpose, `cleanup()` method should be used.

## Using task processor

The Waiter task processor accepts tasks to process (the name sort of gives it away) and tries to process them in an efficient yet non-intrusive way. Similarly to task queues it has methods for adding and removing tasks as well as changing their priorities - in fact, it uses its own task queue under the hood. However, it doesn't expose methods for running the tasks in the batches. Instead, it plans batches on its own, trying to make the most of the idle time between game frames.

From this, the following hierarchy of responsbilities emerges:
- the Waiter task **gradually performs its complex processing**, within whichever timeframe it's given
- the Waiter task queue **chooses the tasks to process** and processes as much of them as possible, within whichever timeframe it's given
- the Waiter task processor estimates how much time can be safely spent on processing without adversely affecting the framerate, and then makes its inner queue **process pending tasks in its calculated timeframe**

The key takeaway is: for the most hassle-free experience with background processing setup, Waiter task processor is strongly recommended.

### Setup

It's recommended to put a single instance of the Waiter task processor in the very first room and let it do its thing; no destroying, no additional instances. As a persistent instance, Waiter task processor will carry over between rooms, and if only one instance is present its methods can be accessed via `ctrl_WaiterTaskProcessor.<some_method>` notation.

The Waiter task processor has the following Object Variables to fine-tune its behaviour:
- `automatic_processing_enabled` - determines whether the task processor will perform tasks processing on its own or the processing will be managed externally
- `min_duration` - the minimum duration of the given frame's processing batch
- `max_duration` - the maximum duration of the given frame's processing batch
- `frame_margin` - the amount of between-frame time to leave for potential adjacent processing
- `min_repeats` - the minimum number of processing steps to execute each frame

### Managing tasks

The Waiter task processor provides the following methods for managing the tasks in its queue, much like Waiter task queues methods:
- `enqueue(task,[priority])`
- `dequeue(task)`
- `change_priority(task,priority)`
- `has_task(task)`

### Processing details

GameMaker doesn't have built-in multithreading or asynchronous processing features for arbitrary GML. To work around that, Waiter task processor tries to squeeze out the most of the free time left between processing core gameplay mechanics and the drawing.

A frame in a typical gameplay loop can be summarised like this:
- update the gameplay state (Step events and Step-adjacent logic, e.g. time sources)
- draw the game graphics
- pad the rest of the frame time to maintain the target framerate

The expected frame time can be retrieved via `game_get_speed(gamespeed_microseconds)` - this returns the number of microseconds allocated per frame. Thus, the general algorithm would be:
- measure the time at the very start of the update phase
- estimate the time the next frame is expected to start (by adding microseconds allocated per frame)
- measure the time at the very end of the drawing phase (just before frame padding would usually start)
- estimate the remaining time to the expected next frame (adjusted by the frame margin)
- run a task processing batch for the remaining time (clamped between the minimum and maximum duration)

That way instead of wasting time on between-frames padding, this time is used for whichever long-running tasks need it. At least that's the ideal situation.

The Waiter task processor uses the **Begin Step** event - the earliest event in the update phase - to measure the current frame time and estimate the next frame time. Then it uses the **Draw GUI End** event - the latest event in the drawing phase - to calculate remaining time and use it for background processing. There is likely a small game loop management overhead between the very last **Draw GUI End** event of the previous frame and the very first **Begin Step** event of the next frame (other than frame padding). However, a modest frame margin should leave enough room for that.

That's how Waiter task processor operates by default, with `automatic_processing_enabled` flag set to **true**. However, in some cases a tweaking may be required...

### Mitigating the conflicts

The process described above - estimating the next frame time in the **Begin Step** event and running background processing for the remaining frame time in the **Draw GUI End** event - relies on:
- no other objects running their **Begin Step** event before the Waiter task processor (or else the next frame time the processor aims for is delayed)
- no other objects running their **Draw GUI End** event after the Waiter task processor (or else the background processing is followed by additional drawing logic, instead of expected padding and game loop overhead)
- alternatively, the adjacent **Begin Step** and **Draw GUI End** events involve so little processing that they fit in the frame margin, together with the game loop overhead

However, sometimes the adjacent processing might get so significant that the usual automatic execution with default settings won't cut it.

###### Adding the margin

One relatively simple option is to account for the adjacent processing by *increasing the frame margin*. This can leave some room for the extra processing, but is likely to result in suboptimal use of the remaining frame time. Even more so if one wants to account for the worst case scenario, where the task processor is the last to execute its **Begin Step** event and the first to execute its **Draw GUI End** event. Using the frame margin for the worst case scenario means the task processor won't benefit from more favourable ones, leading to less efficient use of game resources and slower tasks processing.

###### Central controller object

An alternative is to have a special controller object - the only one allowed to define its **Begin Step** event and **Draw GUI End** event at the time. Such an object would make the task processor measure the next frame time at the start of its **Begin Step** event and to perform background processing with the remaining frame time at the end of its **Draw GUI End** event. All the other objects' **Begin Step** and **Draw GUI End** events would be replaced with user events or methods to be executed by the special controller object.

In order to execute this approach, the following would need to be done:
- the task processor's own processing would be disabled by setting the `automatic-processing_enabled` flag to **false**
- the special controller object would call the `estimate_next_frame_time()` method of the Waiter task processor at the start of **Begin Step** event
- the special controller object would call the `process_ongoing_tasks()` method of the Waiter task processor at the end of **Draw GUI End** event

###### Tweaking the task processor

An approach similar in spirit, but simpler in execution, would be to reserve some User Defined event numbers as counterparts for the **Begin Step** event and **Draw GUI End** event (e.g. 14 and 15). Then a custom task processor inheriting from the `ctrl_WaiterTaskProcessor` would put the following in its **Begin Step** event:

```gml
estimate_next_frame_time();
with (all) event_user(14);
```

And the following would be put in the **End Step** event:
```gml
with (all) event_user(15);
process_ongoing_tasks();
```

This approach is somewhat rigid, with certain User Event numbers becoming unusable, but it's simpler than creating a completely separate controller object.

-----

Currently, in the native GML, there seem to be no better solution to estimating remaining frame time than using **Begin Step** event and **Draw GUI End** event for time measurement. There may still be workarounds - e.g. instead of having the background processing compete with the core gameplay time, complete all the tasks beforehand in a less time-critical part of the game such as between levels. In the end, it's up to developer to figure out what works for their project.

-----

[<< 01 - Tasks module](/Docs/Overview/01%20-%20Tasks%20module.md) | **02 - Processing module** | [03 - Orders module >>](/Docs/Overview/03%20-%20-Orders%20module.md)
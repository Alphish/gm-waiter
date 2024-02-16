/// @desc Variables and methods setup

// underlying tasks processing queue
queue = new WaiterTaskQueue();

// estimated next frame time in microseconds, adjusted with frame margin
// the task processor will aim to finish a batch before then
next_frame_time = get_timer();

// --------------
// Managing tasks
// --------------

// adds a task to the processing queue
enqueue = function(_task, _priority = 0) {
    queue.enqueue(_task, _priority);
}

// changes a priority for the given task
change_priority = function(_task, _priority) {
    queue.change_priority(_task, _priority);
}

// removes the given task from the processing queue
dequeue = function(_task) {
    queue.dequeue(_task);
}

// checks whether the given task is in the processing queue
has_task = function(_task) {
    return queue.has_task(_task);
}

// ----------
// Processing
// ----------

// estimates the time the next frame should be beginning
// it adjusts the time by frame margin to leave some leeway
// and prevent framerate inconsistencies
estimate_next_frame_time = function() {
    var _current_frame_time = get_timer();
    var _frame_duration = game_get_speed(gamespeed_microseconds);
    next_frame_time = _current_frame_time + _frame_duration;
}

// runs the ongoing tasks in the queue, if any
// it aims to perform as much processing as possible until the next frame time
// while not running for so long to adversely affect the framerate
process_ongoing_tasks = function() {
    var _frame_margin_us = round(1000 * frame_margin);
    var _min_duration_us = round(1000 * min_duration);
    var _max_duration_us = round(1000 * max_duration);
    
    var _current_time = get_timer();
    var _remaining_time = next_frame_time - _frame_margin_us - _current_time;
    var _target_time = _current_time + clamp(_remaining_time, _min_duration_us, _max_duration_us);
    queue.run_batch_until(_target_time, min_repeats);
}

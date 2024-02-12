/// @func WaiterUsageException(task,message)
/// @desc An exception to be thrown when Waiter is improperly used because of dev error.
/// @arg {Struct.WaiterTask,Undefined} task     The task the exception originated from.
/// @arg {String} message                       A message describing the problem.
function WaiterUsageException(_task, _message) constructor {
    if (is_undefined(_message))
        return;
    
    task = _task;
    message = !is_undefined(_task)
        ? $"Error with handling of '{_task.name}': {_message}"
        : $"Error with usage of Waiter library: {_message}";
    
    // ---------------
    // Task exceptions
    // ---------------
    
    static method_not_implemented = function(_task, _method) {
        return new WaiterUsageException(_task, $"{instanceof(_task)}.{_method} is not implemented.");
    }
    
    // ----------------
    // Queue exceptions
    // ----------------
    
    static task_queue_added_task_already_queued = function(_task) {
        return new WaiterUsageException(_task, $"Attempting to queue the task when it's already in the queue.");
    }
    
    static task_queue_changed_task_not_in_queue = function(_task) {
        return new WaiterUsageException(_task, $"Attempting to change the priority of the task when it's not in the queue.");
    }
    
    static task_queue_removed_task_not_in_queue = function(_task) {
        return new WaiterUsageException(_task, $"Attempting to dequeue a task when it's not in the queue.");
    }
    
    static task_queue_removed_node_still_has_tasks = function() {
        return new WaiterUsageException(undefined, $"Attempting to remove a task queue priority node when it still has ongoing tasks.");
    }
}

// statics initialisation
// feather ignore GM1041
WaiterUsageException(undefined, undefined);

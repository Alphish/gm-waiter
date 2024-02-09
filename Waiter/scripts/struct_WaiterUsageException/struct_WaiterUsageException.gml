/// @func WaiterUsageException(task,message)
/// @desc An exception to be thrown when Waiter is improperly used because of dev error.
/// @arg {Struct.WaiterTask} task       The task the exception originated from.
/// @arg {String} message               A message describing the problem.
function WaiterUsageException(_task, _message) constructor {
    if (is_undefined(_message))
        return;
    
    task = _task;
    message = !is_undefined(_task)
        ? $"Error with handling of '{_task.name}': {_message}"
        : $"Error with usage of Waiter library: {_message}";
    
    static method_not_implemented = function(_task, _method) {
        return new WaiterUsageException(_task, $"{instanceof(_task)}.{_method} is not implemented.");
    }
}

// statics initialisation
// feather ignore GM1041
WaiterUsageException(undefined, undefined);

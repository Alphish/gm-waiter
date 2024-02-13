/// @func WaiterOrderBuilder(task)
/// @desc A builder for preparing a task order.
/// @arg {Struct.WaiterTask} task       The task to prepare the order for.
function WaiterOrderBuilder(_task) constructor {
    task = _task;
    
    success_handler = undefined;
    failure_handler = undefined;
    completion_handler = undefined;
    
    /// @func on_success(handler)
    /// @desc Sets up the logic to execute when the task finishes successfully.
    /// @arg {Function} handler         The function handling the task result.
    /// @returns {Struct.WaiterOrderBuilder}
    static on_success = function(_handler) {
        ensure_handler_is_callable(_handler, "success");
        success_handler = _handler;
        return self;
    }
    
    /// @func on_failure(handler)
    /// @desc Sets up the fallback logic to execute when the task fail.
    /// @arg {Function} handler         The function handling the task failure.
    /// @returns {Struct.WaiterOrderBuilder}
    static on_failure = function(_handler) {
        ensure_handler_is_callable(_handler, "failure");
        failure_handler = _handler;
        return self;
    }
    
    /// @func on_completion(handler)
    /// @desc Sets up the logic to execute when the task runs to completion, successful or otherwise.
    /// @arg {Function} handler         The function handling the task completion.
    /// @returns {Struct.WaiterOrderBuilder}
    static on_completion = function(_handler) {
        ensure_handler_is_callable(_handler, "completion");
        completion_handler = _handler;
        return self;
    }
    
    /// @func place()
    /// @desc Creates and returns the new task order.
    /// @returns {Struct.WaiterOrder}
    static place = function() {
        return new WaiterOrder(task, success_handler, failure_handler, completion_handler); 
    }
    
    /// @ignore
    static ensure_handler_is_callable = function(_handler, _type) {
        if (!is_callable(_handler))
            throw WaiterUsageException.order_handler_not_callable(task, _type);
    }
}

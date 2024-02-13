/// @func WaiterOrder(task,onsuccess,[onfailure],[oncompletion])
/// @desc A structure keeping track of a task order, executing a specific logic when finished.
///       Note: An instance of ctrl_WaiterOrderManager must be available for orders to be placed.
/// @arg {Struct.WaiterTask} task       The task for which the order is made.
/// @arg {Function} onsuccess           A callback to execute when the task finishes successfully.
/// @arg {Function} onfailure           A callback to execute when the task finishes with a failure.
/// @arg {Function} oncompletion        A callback to execute when the task runs to completion, successful or otherwise.
function WaiterOrder(_task, _onsuccess, _onfailure = undefined, _oncompletion = undefined) constructor {
    if (is_undefined(_task))
        return;
    
    if (!instance_exists(ctrl_WaiterOrderManager))
        throw WaiterUsageException.order_manager_missing();
    
    task = _task;
    success_handler = (is_undefined(_onsuccess) || is_method(_onsuccess)) ? _onsuccess : method(self, _onsuccess);
    failure_handler = (is_undefined(_onfailure) || is_method(_onfailure)) ? _onfailure : method(self, _onfailure);
    completion_handler = (is_undefined(_oncompletion) || is_method(_oncompletion)) ? _oncompletion : method(self, _oncompletion);
    
    is_canceled = false;
    is_fulfilled = false;
    
    ctrl_WaiterOrderManager.place_order(self);
    
    /// @func cancel()
    /// @desc Cancels the given order.
    static cancel = function() {
        ctrl_WaiterOrderManager.cancel_order(self);
    }
    
    /// @ignore Internal function for marking an order as cancelled.
    static mark_cancelled = function() {
        if (!is_canceled && !is_fulfilled)
            is_canceled = true;
    }
    
    /// @ignore Internal function to execute when the task finishes successfully.
    static resolve = function(_result, _task) {
        if (is_canceled || is_fulfilled)
            return;
        
        is_fulfilled = true;
        if (!is_undefined(success_handler))
            success_handler(_result, _task, self);
        if (!is_undefined(completion_handler))
            completion_handler(_task, self);
    }
    
    /// @ignore Internal function to execute when the task finishes with a failure.
    static reject = function(_failure, _task) {
        if (is_canceled || is_fulfilled)
            return;
        
        is_fulfilled = true;
        if (!is_undefined(failure_handler))
            failure_handler(_failure, _task, self);
        if (!is_undefined(completion_handler))
            completion_handler(_task, self);
    }
    
    /// @func is_finished()
    /// @desc Checks whether the order has been finished (fulfilled or cancelled).
    static is_finished = function() {
        return is_canceled || is_fulfilled;
    }
}

// static initialisation
WaiterOrder(undefined, undefined, undefined, undefined);

/// @func WaiterTask([name])
/// @desc A base constructor for long running tasks.
///       Note: Any derived constructor must implement process() method for multi-step processing to work.
/// @arg {String} [name]        The name of the task, if any.
function WaiterTask(_name = "Waiter Task") constructor {
    if (!is_instanceof(self, WaiterTask))
        return;
    
    name = _name;
    
    // keeps track of the task status
    // it may be retrieved for checks, but usually shouldn't be changed outside the Waiter internal logic
    status = WaiterTaskStatus.Pending;
    
    // stores the result of a successful task, if any
    result = undefined;
    
    // stores the cause of a task failure, if any
    failure = undefined;
    
    // keeps track of the current task progress; can be used for progress bars and the like
    progress_current = undefined;
    
    // keeps track of the target task progress; can be used for progress bars and the like
    progress_total = undefined;
    
    /// @func from_result(result,[name])
    /// @desc Creates a successfully completed task with a given result.
    /// @arg {Any} result       The result of the task.
    /// @arg {String} [name]    The name of the task, if any.
    /// @returns {Struct.WaiterTask}
    static from_result = function(_result, _name = undefined) {
        var _task = new WaiterTask(_name);
        _task.succeed_with(_result);
        return _task;
    }
    
    /// @func from_failure(failure,[name])
    /// @desc Creates a failed task with a given result.
    /// @arg {Any} failure      The given failure cause.
    /// @arg {String} [name]    The name of the task, if any.
    /// @returns {Struct.WaiterTask}
    static from_failure = function(_failure, _name = undefined) {
        var _task = new WaiterTask(_name);
        _task.fail_with(_failure);
        return _task;
    }
    
    // --------------
    // Task own logic
    // --------------
    
    // there functions can be overriden by the user as needed
    // in particular, "process" function *must* be overriden
    // for the task to be functional at all
    
    // called when the task logic is run for the first time
    static setup = function() {
        // no setup logic by default
    }
    
    // called before each run, as started via run_once/run_batch/run_batch_until/run_to_end
    static prepare_run = function() {
        // no run preparation logic by default
    }
    
    // executes a single "step" of the task logic
    static process = function() {
        throw WaiterUsageException.method_not_implemented(self, "process()");
    }
    
    // cleans up whatever was created in the "setup" call, unless the task was never setup in the first place
    // it receives the completion status as a parameter to better choose its cleanup logic
    // (e.g. a gradually built ds_grid would be kept on success, but destroyed on failure)
    static cleanup = function(_status) {
        // no cleanup logic by default
    }
    
    // ----------------
    // Process outcomes
    // ----------------
    
    // these functions can be used as returns in the "process" function
    // to signal the whether the task is concluded or not
    // and update the progress/success/failure status accordingly
    
    /// @func proceed()
    /// @desc Indicates that the task should proceed to the next step as soon as permitted.
    /// @returns {Bool}
    static proceed = function() {
        return false;
    }
    
    /// @func proceed_later()
    /// @desc Indicates that the task should continue during the next run.
    /// @returns {Bool}
    static proceed_later = function() {
        status = WaiterTaskStatus.Delayed;
        return false;
    }
    
    /// @func progress_to(value)
    /// @desc Indicates that the task should proceed and also sets the current progress to the given value.
    /// @arg {Real} value       The new progress value to set.
    /// @returns {Bool}
    static progress_to = function(_value) {
        progress_current = _value;
        return false;
    }
    
    /// @func progress_by(value)
    /// @desc Indicates that the task should proceed and also increases the progress by the given value.
    /// @arg {Real} value       The value to increase the progress by.
    /// @returns {Bool}
    static progress_by = function(_value) {
        progress_current += _value;
        return false
    }
    
    /// @func succeed_with(result)
    /// @desc Finishes a task successfully with the given result.
    /// @arg {Any} result       The final result of the task.
    /// @returns {Bool}
    static succeed_with = function(_result) {
        if (status > WaiterTaskStatus.Concluded)
            return true;
        
        if (status != WaiterTaskStatus.Pending)
            cleanup(WaiterTaskStatus.Successful);
        
        result = _result;
        status = WaiterTaskStatus.Successful;
        progress_current = progress_total;
        
        var _task = self;
        with (ctrl_WaiterOrderManager) {
            resolve_task(_task);
        }
        return true;
    }
    
    /// @func fail_with(result)
    /// @desc Fails a task with the given failure cause.
    /// @arg {Any} failure      The entity to indicate the cause of the failure.
    /// @returns {Bool}
    static fail_with = function(_failure) {
        if (status > WaiterTaskStatus.Concluded)
            return true;
        
        if (status != WaiterTaskStatus.Pending)
            cleanup(WaiterTaskStatus.Failed);
        
        failure = _failure;
        status = WaiterTaskStatus.Failed;
        
        var _task = self;
        with (ctrl_WaiterOrderManager) {
            reject_task(_task);
        }
        return true;
    }
    
    // -----------
    // Task status
    // -----------
    
    /// @func get_status_description()
    /// @desc Gets a text describing the current task status/progress. Can be overriden.
    /// @returns {String}
    static get_status_description = function() {
        switch (status) {
            case WaiterTaskStatus.Pending:
                return "Pending...";
            
            case WaiterTaskStatus.Running:
            case WaiterTaskStatus.Delayed:
                return get_progress_description();
            
            case WaiterTaskStatus.Successful:
                return "Done!";
            
            case WaiterTaskStatus.Failed:
                return "Failed!";
            
            case WaiterTaskStatus.Aborted:
                return "Aborted!";
        }
    }
    
    /// @func get_progress_description()
    /// @desc Gets a string describing the current task progress. Can be overriden.
    /// @returns {String}
    static get_progress_description = function() {
        return get_progress_out_of_total() ?? "In progress...";
    }
    
    /// @func is_pending()
    /// @desc Checks whether the task is pending, i.e. was neither run nor immediately concluded.
    /// @returns {Bool}
    static is_pending = function() {
        return status == WaiterTaskStatus.Pending;
    }
    
    /// @func is_running()
    /// @desc Checks whether the task is in the running state.
    /// @returns {Bool}
    static is_running = function() {
        return status == WaiterTaskStatus.Running;
    }
    
    /// @func is_delayed()
    /// @desc Checks whether the task is in the delayed state (waiting for another run).
    /// @returns {Bool}
    static is_delayed = function() {
        return status == WaiterTaskStatus.Delayed;
    }
    
    /// @func is_concluded()
    /// @desc Checks whether the task is in one of concluded states.
    /// @returns {Bool}
    static is_concluded = function() {
        return status > WaiterTaskStatus.Concluded;
    }
    
    /// @func is_successful()
    /// @desc Checks whether the task has completed successfully.
    /// @returns {Bool}
    static is_successful = function() {
        return status == WaiterTaskStatus.Successful;
    }
    
    /// @func is_failed()
    /// @desc Checks whether the task has failed.
    /// @returns {Bool}
    static is_failed = function() {
        return status == WaiterTaskStatus.Failed;
    }
    
    /// @func is_aborted()
    /// @desc Checks whether the task has been aborted.
    /// @returns {Bool}
    static is_aborted = function() {
        return status == WaiterTaskStatus.Aborted;
    }
    
    // --------
    // Progress
    // --------
    
    /// @func begin_progress_toward(total)
    /// @desc Sets up the task for progress tracking, with the given value as the total value to reach.
    /// @arg {Real} total           The total progress value to reach.
    static begin_progress_toward = function(_total) {
        progress_current = 0;
        progress_total = _total;
    }
    
    /// @func get_progress_amount()
    /// @desc Returns the fraction of the progress in relation to the total, or undefined if no progress total was specified.
    /// @returns {Real,Undefined}
    static get_progress_amount = function() {
        if (is_undefined(progress_total))
            return undefined;
        
        return progress_current / progress_total;
    }
    
    /// @func get_progress_out_of_total()
    /// @desc Returns a string representing the progress in the "current/total" format, or undefined if no progress total was specified.
    /// @returns {String,Undefined}
    static get_progress_out_of_total = function() {
        if (is_undefined(progress_total))
            return undefined;
        
        return $"{progress_current}/{progress_total}";
    }
    
    /// @func get_progress_percentage([precision])
    /// @desc Returns a string representing the progress as a percentage, or undefined if no progress total was specified.
    /// @arg {Real} precision       The number of decimal points shown.
    /// @returns {String,Undefined}
    static get_progress_percentage = function(_precision = 0) {
        if (is_undefined(progress_total))
            return undefined;
        
        return string_format(100 * progress_current / progress_total, 0, _precision) + "%";
    }
    
    // ------------
    // Running task
    // ------------
    
    /// @ignore
    static init_run = function() {
        if (status == WaiterTaskStatus.Pending)
            setup();
        
        status = WaiterTaskStatus.Running;
        prepare_run();
    }
    
    /// @func run_once()
    /// @desc Runs a single processing step of the task and returns whether the task has concluded or not.
    /// @returns {Bool}
    static run_once = function() {
        if (status > WaiterTaskStatus.Concluded)
            return true;
        
        init_run();
        
        return process();
    }
    
    /// @func run_batch(duration,[repeats])
    /// @desc Runs a batch of processing steps for the given duration.
    /// @arg {Real} duration        The intended batch duration (in milliseconds).
    /// @arg {Real} [repeats]       The minimum number of processing steps to perform.
    /// @returns {Bool}
    static run_batch = function(_duration, _repeats = 1) {
        if (status > WaiterTaskStatus.Concluded)
            return true;
        
        var _target_time = get_timer() + round(_duration * 1000);
        return run_batch_until(_target_time, _repeats);
    }
    
    /// @func run_batch_until(time,[repeats])
    /// @desc Runs a batch of processing steps lasting until the given time.
    /// @arg {Real} time            The time to run the batch until, as compared to get_timer().
    /// @arg {Real} [repeats]       The minimum number of processing steps to perform.
    /// @returns {Bool}
    static run_batch_until = function(_time, _repeats = 1) {
        if (status > WaiterTaskStatus.Concluded)
            return true;
        
        init_run();
        
        repeat (max(1, _repeats)) {
            process();
            
            if (status != WaiterTaskStatus.Running)
                return status > WaiterTaskStatus.Concluded;
        }
        
        while (get_timer() <= _time && status == WaiterTaskStatus.Running) {
            process();
        }
        return status > WaiterTaskStatus.Concluded;
    }
    
    /// @func run_to_end()
    /// @desc Runs the given task until it finishes or ends up in a delayed state.
    /// @returns {Bool}
    static run_to_end = function() {
        if (status > WaiterTaskStatus.Concluded)
            return true;
        
        init_run();
        
        while (status == WaiterTaskStatus.Running) {
            process();
        }
        return status > WaiterTaskStatus.Concluded;
    }
    
    /// @func abort()
    /// @desc Aborts the task so that it's not executed anymore.
    /// @returns {Bool}
    static abort = function() {
        if (status > WaiterTaskStatus.Concluded)
            return true;
        
        if (status != WaiterTaskStatus.Pending)
            cleanup(WaiterTaskStatus.Aborted);
        
        status = WaiterTaskStatus.Aborted;
        
        var _task = self;
        with (ctrl_WaiterOrderManager) {
            cancel_task_orders(_task);
        }
    }
    
    // ------
    // Orders
    // ------
    
    /// @func begin_order()
    /// @desc Begins preparing an order for the task.
    /// @returns {Struct.WaiterOrderBuilder}
    static begin_order = function() {
        if (!instance_exists(ctrl_WaiterOrderManager))
            throw WaiterUsageException.order_manager_missing();
        
        return new WaiterOrderBuilder(self);
    }
    
    /// @func cancel_orders()
    /// @desc Cancels all orders waiting for the task completion.
    static cancel_orders = function() {
        if (!instance_exists(ctrl_WaiterOrderManager))
            throw WaiterUsageException.order_manager_missing();
        
        ctrl_WaiterOrderManager.cancel_task_orders(self);
    }
}

// static initialisation
with ({}) WaiterTask();
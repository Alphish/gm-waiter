/// @desc An enumeration of possible Waiter Task statuses.
enum WaiterTaskStatus {
    /// @desc The task hasn't been run yet.
    Pending = 1,
    /// @desc The task has started executing and is ready to continue.
    Running = 2,
    /// @desc The task can't continue its processing just yet and is delayed until the next run.
    Delayed = 3,
    
    // a threshold value for finished statuses
    // don't use it as an actual task status!
    /// @ignore
    Finished = 10,
    
    /// @desc The task has been aborted before it could result in a success or a failure.
    Aborted = 11,
    /// @desc The task failed to produce its intended result.
    Failed = 12,
    /// @desc The task successfully produced its intended result.
    Successful = 13,
}

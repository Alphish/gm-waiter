/// @func WaiterTaskQueue()
/// @desc A queue for processing tasks according to their priorities.
function WaiterTaskQueue() constructor {
    head_node = undefined;
    task_nodes = ds_map_create();
    priority_nodes = ds_map_create();
    
    // ----------------
    // Tasks management
    // ----------------
    
    /// @func enqueue(task,[priority])
    /// @desc Adds a task to the task processing queue with the given priority.
    /// @arg {Struct.WaiterTask} task       The task to enqueue.
    /// @arg {Real} [priority]              The priority assigned to the task (0 by default).
    static enqueue = function(_task, _priority = 0) {
        if (_task.status > WaiterTaskStatus.Finished)
            return; // no point in adding an already completed task
        
        if (ds_map_exists(task_nodes, _task))
            throw WaiterUsageException.task_queue_added_task_already_queued(_task);
        
        var _node = get_priority_node(_priority);
        task_nodes[? _task] = _node;
        _node.add_task(_task);
    }
    
    /// @func change_priority(task,priority)
    /// @desc Changes priority of the given task to the given value.
    /// @arg {Struct.WaiterTask} task       The task to change the priority of.
    /// @arg {Real} priority                The new priority assigned to the task.
    static change_priority = function(_task, _priority) {
        var _node = task_nodes[? _task];
        if (is_undefined(_node))
            throw WaiterUsageException.task_queue_changed_task_not_in_queue(_task);
        
        if (_node.priority == _priority)
            return; // keep things the same if the new priority is same as old
        
        // it just removes and re-adds the task
        // so that all the priority node creating and removal is handled properly, too
        dequeue(_task);
        enqueue(_task, _priority);
    }
    
    /// @func dequeue(task)
    /// @desc Removes the given task from the task processing queue.
    /// @arg {Struct.WaiterTask} task       The task to dequeue.
    static dequeue = function(_task) {
        var _node = task_nodes[? _task];
        if (is_undefined(_node))
            throw WaiterUsageException.task_queue_removed_task_not_in_queue(_task);
        
        ds_map_delete(task_nodes, _task);
        _node.remove_task(_task);
        
        if (!_node.has_tasks())
            remove_priority_node(_node);
    }
    
    /// @func has_task(task)
    /// @desc Checks whether the given task is in the processing queue.
    /// @arg {Struct.WaiterTask} task       The task to check.
    static has_task = function(_task) {
        return ds_map_exists(task_nodes, _task);
    }
    
    /// @ignore Internal function for removing finished tasks within priority node.
    static unregister_task = function(_task, _node) {
        ds_map_delete(task_nodes, _task);
        if (!_node.has_tasks())
            remove_priority_node(_node);
    }
    
    // ----------------
    // Nodes management
    // ----------------
    
    /// @ignore Internal function for retrieving or creating a tasks priority node.
    static get_priority_node = function(_priority) {
        var _existing_node = priority_nodes[? _priority];
        if (!is_undefined(_existing_node))
            return _existing_node;
        
        var _new_node = create_priority_node(_priority);
        priority_nodes[? _priority] = _new_node;
        return _new_node;
    }
    
    /// @ignore Internal function for creating a tasks priority node.
    static create_priority_node = function(_priority) {
        var _new_node = new WaiterTaskQueueNode(self, _priority);
        if (is_undefined(head_node) || head_node.priority < _priority) {
            head_node = _new_node.linked_before(head_node);
            return head_node;
        }
        
        var _insert_node = head_node;
        while (!is_undefined(_insert_node.next_node) && _insert_node.next_node.priority > _priority) {
            _insert_node = _insert_node.next_node;
        }
        
        return _new_node.linked_after(_insert_node);
    }
    
    /// @ignore Internal function for removing a tasks priority node.
    static remove_priority_node = function(_node) {
        if (_node.has_tasks())
            throw WaiterUsageException.task_queue_removed_node_still_has_tasks();
        
        if (_node == head_node)
            head_node = _node.next_node;
        
        ds_map_delete(priority_nodes, _node.priority);
        _node.unlink();
    }
    
    ///@ignore Internal function for finding the next node with ongoing tasks.
    static prepare_next_node = function(_node) {
        while (!is_undefined(_node) && !_node.has_tasks()) {
            remove_priority_node(_node);
            _node = _node.next_node;
        }
        return _node;
    }
    
    // -------------
    // Running tasks
    // -------------
    
    /// @func run_once()
    /// @desc Runs a single processing step of the upcoming task.
    static run_once = function() {
        var _current_node = prepare_next_node(head_node);
        if (is_undefined(_current_node))
            return;
        
        _current_node.run_once();
    }
    
    /// @func run_batch(duration,[repeats])
    /// @desc Runs a batch of processing steps for the given durartion.
    ///       If the first task ends its run before the time runs out, the remaining time is spent on subsequent tasks.
    /// @arg {Real} duration        The intended batch duration (in milliseconds).
    /// @arg {Real} [repeats]       The minimum number of upcoming task processing steps to perform.
    static run_batch = function(_duration, _repeats = 1) {
        var _target_time = get_timer() + round(_duration * 1000);
        run_batch_until(_target_time, _repeats);
    }
    
    /// @func run_batch_until(time,[repeats])
    /// @desc Runs a batch of processing steps lasting until the given time.
    ///       If the first task ends its run before the time runs out, the remaining time is spent on subsequent tasks.
    /// @arg {Real} time            The time to run the batch until, as compared to get_timer().
    /// @arg {Real} [repeats]       The minimum number of upcoming task processing steps to perform.
    static run_batch_until = function(_time, _repeats = 1) {
        var _current_node = prepare_next_node(head_node);
        if (is_undefined(_current_node))
            return;
        
        _current_node.run_batch_until(_time, _repeats);
        
        while (get_timer() <= _time) {
            _current_node = prepare_next_node(_current_node.next_node);
            if (is_undefined(_current_node))
                return;
            
            _current_node.run_batch_until(_time, 1);
        }
    }
    
    // -------
    // Cleanup
    // -------
    
    /// @func cleanup()
    /// @desc Cleans up data structures associated with the task queue.
    static cleanup = function() {
        ds_map_destroy(task_nodes);
        ds_map_destroy(priority_nodes);
    }
}

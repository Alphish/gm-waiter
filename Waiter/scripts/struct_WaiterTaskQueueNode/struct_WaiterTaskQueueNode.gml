/// @ignore Internal constructor for task queue priority nodes.
function WaiterTaskQueueNode(_queue, _priority) constructor {
    queue = _queue;
    priority = _priority;
    previous_node = undefined;
    next_node = undefined;
    
    ready_tasks = [];
    delayed_tasks = [];
    
    /// inserts the node before the given node (if any)
    /// and returns the newly inserted node
    static linked_before = function(_node) {
        if (is_undefined(_node))
            return linked_between(undefined, undefined);
        
        return linked_between(_node.previous_node, _node);
    }
    
    /// inserts the node after the given node (if any)
    /// and returns the newly inserted node
    static linked_after = function(_node) {
        if (is_undefined(_node))
            return linked_between(undefined, undefined);
        
        return linked_between(_node, _node.next_node);
    }
    
    /// inserts the node between the two given nodes
    /// and returns the newly inserted node
    static linked_between = function(_previous, _next) {
        previous_node = _previous;
        if (!is_undefined(_previous))
            _previous.next_node = self;
        
        next_node = _next;
        if (!is_undefined(_next))
            _next.previous_node = self;
        
        return self;
    }
    
    /// removes the node from the queue
    /// and links together its previous and next node
    static unlink = function() {
        if (!is_undefined(previous_node))
            previous_node.next_node = next_node;
        
        if (!is_undefined(next_node))
            next_node.previous_node = previous_node;
    }
    
    // --------------
    // Managing tasks
    // --------------
    
    /// adds a task to process within the priority node
    static add_task = function(_task) {
        array_push(ready_tasks, _task);
    }
    
    /// removes a task from the priority node
    static remove_task = function(_task) {
        var _ready_index = array_get_index(ready_tasks, _task);
        if (_ready_index >= 0)
            array_delete(ready_tasks, _ready_index, 1);
        
        var _delayed_index = array_get_index(delayed_tasks, _task);
        if (_delayed_index >= 0)
            array_delete(delayed_tasks, _delayed_index, 1);
    }
    
    /// checks if the priority node has ongoing tasks
    static has_tasks = function() {
        return array_length(ready_tasks) > 0 || array_length(delayed_tasks) > 0;
    }
    
    // -------------
    // Running tasks
    // -------------
    
    /// moves any previously delayed tasks back to the ready tasks array
    static prepare_run = function() {
        repeat (array_length(delayed_tasks)) {
            array_push(ready_tasks, array_shift(delayed_tasks));
        }
    }
    
    /// runs the upcoming task once
    static run_once = function() {
        prepare_run();
        
        // the first task in the run is guaranteed to exist
        // because the queue struct checks for the node's tasks first
        var _task = array_shift(ready_tasks);
        _task.run_once();
        replace_task(_task);
    }
    
    /// runs the upcoming tasks for the given number of repetitions and until the given time
    static run_batch_until = function(_time, _repeats) {
        prepare_run();
        
        // the first task in the run is guaranteed to exist
        // because the queue struct checks for the node's tasks first
        var _task = array_shift(ready_tasks);
        _task.run_batch_until(_time, _repeats);
        replace_task(_task);
        
        while (get_timer() <= _time) {
            _task = array_shift(ready_tasks);
            if (is_undefined(_task))
                return;
            
            _task.run_batch_until(_time, _repeats);
            replace_task(_task);
        }
    }
    
    /// re-adds or unregisters a processed task based on its status
    static replace_task = function(_task) {
        switch (_task.status) {
            case WaiterTaskStatus.Pending:
            case WaiterTaskStatus.Running:
                array_push(ready_tasks, _task);
                break;
            
            case WaiterTaskStatus.Delayed:
                array_push(delayed_tasks, _task);
                break;
            
            case WaiterTaskStatus.Aborted:
            case WaiterTaskStatus.Failed:
            case WaiterTaskStatus.Successful:
                queue.unregister_task(_task, self);
                break;
        }
    }
}

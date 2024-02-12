width = 256;
inner_width = 192;
height = 120;

current_task = undefined;
current_priority = undefined;

// -------
// Buttons
// -------

var _priorities_x = (inner_width div 2) - 12;
var _priorities_y = 72;
for (var i = -2; i <= 2; i++) {
    instance_create_depth(x + _priorities_x + i * 30, y + _priorities_y, depth - 1, ui_PrioritySelector, {
        task_slot: id,
        priority: i,
    });
}

var _cancel_x = inner_width + 8;
var _cancel_y = (height div 2) - 12;
instance_create_depth(x + _cancel_x, y + _cancel_y, depth - 1, ui_TaskCancel, { task_slot: id });

// -------
// Methods
// -------

track_task = function(_task) {
    current_task = _task;
    current_priority = 0;
    ctrl_WaiterTaskProcessor.enqueue(_task, current_priority);
}

abandon_task = function() {
    if (is_undefined(current_task))
        return;
    
    if (ctrl_WaiterTaskProcessor.has_task(current_task))
        ctrl_WaiterTaskProcessor.dequeue(current_task);
    
    current_task.abort();
    
    current_task = undefined;
    current_priority = undefined;
}

set_priority = function(_priority) {
    if (is_undefined(current_task))
        return;
    
    current_priority = _priority;
    if (!current_task.is_finished())
        ctrl_WaiterTaskProcessor.change_priority(current_task, current_priority);
}


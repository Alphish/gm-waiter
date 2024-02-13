width = 256;
inner_width = 192;
height = 120;

current_task = undefined;
current_priority = undefined;

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

create_fireworks_order = function() {
    if (is_undefined(current_task))
        return undefined;
    
    return current_task.begin_order()
        .on_success(method(self, function() {
            var _color = make_color_hsv(irandom(255), 255, 255);
            effect_create_depth(depth - 10, ef_firework, x + inner_width div 2, y + height div 2, 1, _color);
        })).place();
}

create_sfx_order = function() {
    if (is_undefined(current_task))
        return undefined;
    
    return current_task.begin_order()
        .on_success(function() { audio_play_sound(sfx_TaskDone, 0, false); })
        .on_failure(function() { audio_play_sound(sfx_TaskFailed, 0, false); })
        .place();
}

// -------
// Buttons
// -------

// buttons are setup below methods
// because objects have no static initialisation
// and I need some method variables to exist for buttons assignment

var _priorities_x = (inner_width div 2) - 12;
var _priorities_y = 80;
for (var i = -2; i <= 2; i++) {
    instance_create_depth(x + _priorities_x + i * 30, y + _priorities_y, depth - 1, ui_PrioritySelector, {
        task_slot: id,
        priority: i,
    });
}

var _order_x = inner_width + 8;
var _order_y = 16;
instance_create_depth(x + _order_x, y + _order_y, depth - 1, ui_TaskOrder, {
    task_slot: id,
    create_method: create_fireworks_order,
    image_index: 0,
    image_speed: 0,
    });
instance_create_depth(x + _order_x, y + _order_y + 30, depth - 1, ui_TaskOrder, {
    task_slot: id,
    create_method: create_sfx_order,
    image_index: 1,
    image_speed: 0,
    });

var _cancel_x = inner_width + 8;
var _cancel_y = 80;
instance_create_depth(x + _cancel_x, y + _cancel_y, depth - 1, ui_TaskCancel, { task_slot: id });

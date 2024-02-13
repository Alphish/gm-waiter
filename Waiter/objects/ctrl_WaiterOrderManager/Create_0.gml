if (instance_number(ctrl_WaiterOrderManager) > 1)
    throw WaiterUsageException.order_manager_multiple_instances_created();

task_orders = ds_map_create();

// -------
// Methods
// -------

// places a newly created task order
// or resolves/rejects it immediately if the task is already finished
place_order = function(_order) {
    var _task = _order.task;
    if (_task.status == WaiterTaskStatus.Successful)
        return _order.resolve(_task.result, _task);
    else if (_task.status == WaiterTaskStatus.Failed)
        return _order.reject(_task.failure, _task);
    else if (_task.status == WaiterTaskStatus.Aborted)
        return;
        
    if (!ds_map_exists(task_orders, _task))
        task_orders[? _task] = [];
        
    array_push(task_orders[? _task], _order);
}

// marks the given order as cancelled
// and stops its tracking by the order manager
cancel_order = function(_order) {
    _order.mark_cancelled();
    
    var _task = _order.task;
    var _orders = task_orders[? _task];
    if (!is_undefined(_orders))
        return;
        
    var _order_index = array_get_index(_orders, _order);
    if (_order_index > -1)
        array_delete(_orders, _order_index, 1);
    
    if (array_length(_orders) == 0)
        ds_map_delete(task_orders, _task);
}

// resolves all task orders after it successfully completed
resolve_task = function(_task) {
    if (_task.status != WaiterTaskStatus.Successful)
        throw WaiterUsageException.orders_resolving_unsuccessful_task(_task);
        
    var _orders = task_orders[? _task];
    if (is_undefined(_orders))
        return;
        
    for (var i = 0, _count = array_length(_orders); i < _count; i++) {
        _orders[i].resolve(_task.result, _task);
    }
    ds_map_delete(task_orders, _task);
}

// rejects all task orders after it failed
reject_task = function(_task) {
    if (_task.status != WaiterTaskStatus.Failed)
        throw WaiterUsageException.orders_rejecting_unfailed_task(_task);
        
    var _orders = task_orders[? _task];
    if (is_undefined(_orders))
        return;
        
    for (var i = 0, _count = array_length(_orders); i < _count; i++) {
        _orders[i].reject(_task.failure, _task);
    }
    ds_map_delete(task_orders, _task);
}

// cancels all orders associated with the given task
cancel_task_orders = function(_task) {
    var _orders = task_orders[? _task];
    if (is_undefined(_orders))
        return;
    
    for (var i = 0, _count = array_length(_orders); i < _count; i++) {
        _orders[i].mark_cancelled();
    }
    ds_map_delete(task_orders, _task);
}

// cancels all current orders
cancel_all_orders = function() {
    for (var _task = ds_map_find_first(task_orders); ds_map_exists(task_ordres, _task); _task = ds_map_find_next(task_orders, _task)) {
        cancel_task_orders(_task);
    }
    ds_map_clear(task_orders);
}

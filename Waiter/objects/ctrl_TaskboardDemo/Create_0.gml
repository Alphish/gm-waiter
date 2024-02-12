task_idx = 1;

// ----------------
// Task slots setup
// ----------------

task_slots = [];
var _slot_rows = 6;
var _slot_columns = 4;
for (var i = 0; i < _slot_rows; i++)
for (var j = 0; j < _slot_columns; j++) {
    array_push(task_slots, instance_create_layer(256 * j, 120 * i, "Instances", ui_TaskSlot));
}

// -------
// Methods
// -------

make_counter_task = function(_target) {
    var _free_slot_index = array_find_index(task_slots, function(_slot) { return is_undefined(_slot.current_task); });
    if (_free_slot_index < 0)
        return;
    
    var _slot = task_slots[_free_slot_index];
    var _task = new DemoCounterTask(_target, generate_task_name(_target));
    _slot.track_task(_task);
}

generate_task_name = function(_target) {
    var _idx = task_idx++;
    return $"WTR-{_idx++}: {_target div 1_000_000}M";
}

make_1m_counter_task = function() {
    make_counter_task(1_000_000);
}

make_3m_counter_task = function() {
    make_counter_task(3_000_000);
}

make_10m_counter_task = function() {
    make_counter_task(10_000_000);
}

make_30m_counter_task = function() {
    make_counter_task(30_000_000);
}

make_100m_counter_task = function() {
    make_counter_task(100_000_000);
}

// a silly simple task that counts up for each processing step
function DemoCounterTask(_target, _name = undefined) : WaiterTask(_name) constructor {
    count_target = _target;
    count_current = 0;
    point_of_failure = irandom_range(0, _target * 3);
    
    static setup = function() {
        progress_target = count_target;
        progress_amount = count_current;
    }
    
    static process = function() {
        count_current++;
        
        if (count_current == point_of_failure)
            return fail_with("Oh no!");
        
        if (count_current < count_target)
            return progress_to(count_current);
        else
            return succeed_with(count_current);
    }
    
    static get_progress_description = function() {
        return string_format(100 * count_current / count_target, 0, 2) + "%";
    }
}

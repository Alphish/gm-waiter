is_hovered = position_meeting(window_mouse_get_x(), window_mouse_get_y(), id);

if (is_hovered && mouse_check_button_pressed(mb_left))
    task_slot.abandon_task();

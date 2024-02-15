is_hovered = position_meeting(window_mouse_get_x(), window_mouse_get_y(), id);

if (is_hovered && mouse_check_button_pressed(mb_left)) {
    if (is_undefined(current_order)) {
        current_order = create_method();
    } else {
        current_order.cancel();
        current_order = undefined;
    }
}

if (is_undefined(current_order) || current_order.is_concluded())
    current_order = undefined;

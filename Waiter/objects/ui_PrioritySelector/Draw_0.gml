var _is_selected = priority == task_slot.current_priority;

if (is_hovered) {
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    draw_rectangle(x, y, x + sprite_width - 1, y + sprite_height - 1, true);
}

if (_is_selected) {
    draw_set_color(c_white);
    draw_set_alpha(0.15);
    draw_rectangle(x, y, x + sprite_width - 1, y + sprite_height - 1, false);
}

draw_set_color(c_white);
draw_set_alpha(1);

draw_sprite_ext(sprite_index, priority + 2, x, y, 1, 1, 0, (is_hovered || _is_selected) ? c_white : c_gray, 1);

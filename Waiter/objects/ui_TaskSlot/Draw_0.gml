draw_sprite_stretched(sprite_index, 0, x, y, width, height);

var _has_task = !is_undefined(current_task);

draw_set_font(fnt_WaiterDemo);
draw_set_color(_has_task ? c_silver : c_gray);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(x + inner_width div 2, y + 16, _has_task ? current_task.name : "<no task>");

if (_has_task) {
    if (!current_task.is_concluded())
        draw_set_color(c_silver);
    else
        draw_set_color(current_task.is_successful() ? c_lime : c_orange);

    draw_text(x + inner_width div 2, y + 40, current_task.get_status_description());
}

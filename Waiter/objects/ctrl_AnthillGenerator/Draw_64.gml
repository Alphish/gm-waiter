/// @description Draw progress

// draw overlay rectangle
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);

// draw progress information
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt_WaiterDemo);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(room_width div 2, room_height div 2, "Generating progress:\n" + generator_task.get_status_description());

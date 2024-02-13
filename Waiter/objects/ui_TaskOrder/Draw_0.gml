var _is_active = !is_undefined(current_order);

if (is_hovered) {
    draw_set_color(c_white);
    draw_set_alpha(0.5);
    draw_rectangle(x, y, x + sprite_width - 1, y + sprite_height - 1, true);
}

draw_set_color(c_white);
draw_set_alpha(1);

draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, _is_active || is_hovered ? c_white : c_gray, 1);

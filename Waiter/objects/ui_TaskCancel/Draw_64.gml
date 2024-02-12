if (is_hovered) {
    draw_set_color(c_red);
    draw_set_alpha(0.5);
    draw_rectangle(x, y, x + sprite_width - 1, y + sprite_height - 1, true);
}

draw_set_color(c_white);
draw_set_alpha(1);

draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, is_hovered ? c_white : c_gray, 1);

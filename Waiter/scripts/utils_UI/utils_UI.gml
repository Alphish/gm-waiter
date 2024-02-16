function ui_draw_tooltip(_text) {
    draw_set_font(fnt_WaiterTooltip);
    
    var _width = string_width(_text) + 10;
    var _height = string_height(_text) + 6;
    
    var _tooltip_center = x + sprite_width div 2;
    var _tooltip_left = _tooltip_center - _width div 2;
    var _tooltip_right = _tooltip_left + _width;
    
    var _tooltip_bottom = y;
    var _tooltip_top = _tooltip_bottom - _height;
    var _tooltip_middle = _tooltip_top + _height div 2;
    
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(_tooltip_left, _tooltip_top, _tooltip_right - 1, _tooltip_bottom - 1, false);
    draw_set_color(c_white);
    draw_rectangle(_tooltip_left, _tooltip_top, _tooltip_right - 1, _tooltip_bottom - 1, true);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_tooltip_center, _tooltip_middle, _text);
}

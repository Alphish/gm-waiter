/// @description Tooltip

if (is_hovered)
    ui_draw_tooltip(!is_undefined(current_order) ? cancel_tooltip : order_tooltip);

instance_create_layer(0, 0, layer, ctrl_AnthillGenerator);

regenerate = function() {
    instance_destroy(ctrl_AnthillGenerator);
    instance_destroy(obj_AnthillTile);
    
    instance_create_layer(0, 0, layer, ctrl_AnthillGenerator);
}

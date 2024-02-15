function AnthillGeneratorTask(_width, _height, _subsize, _name = "Anthill Generator Task") : WaiterTask(_name) constructor {
    width = _width;
    height = _height;
    sector_size = _subsize;
    
    mp_grid = undefined;
    test_path = path_add();
    cells = [];
    reserved_cells = [];
    
    // ------------
    // Preparations
    // ------------
    
    static setup = function() {
        mp_grid = mp_grid_create(0, 0, width, height, 16, 16);
        
        // I don't know how precise these rectangles are
        // so I'm using coordinates like 1 : size-1 rather than 0 : size
        mp_grid_add_rectangle(mp_grid, 1, 1, 15, 16 * height - 1);
        mp_grid_add_rectangle(mp_grid, width * 16 - 15, 1, width * 16 - 1, 16 * height - 1);
        mp_grid_add_rectangle(mp_grid, 1, 1, width * 16 - 1, 15);
        mp_grid_add_rectangle(mp_grid, 1, 16 * height - 15, width * 16 - 1, 16 * height - 1);
        
        cells = array_create_ext(width * height, function(i) { return i; });
        reserve_sector_cells();
        array_shuffle_ext(cells);
        
        begin_progress_toward(width * height);
    }
    
    static reserve_sector_cells = function() {
        var _inner_width = width - 2;
        var _inner_height = height - 2;
        var _sectors_per_row = ceil(_inner_width / sector_size);
        var _sectors_per_column = ceil(_inner_height / sector_size);
        for (var i = 0; i < _sectors_per_column; i++)
        for (var j = 0; j < _sectors_per_row; j++) {
            var _sector_left = round(j * _inner_width / _sectors_per_row);
            var _sector_right = round((j + 1) * _inner_width / _sectors_per_row);
            var _sector_top = round(i * _inner_height / _sectors_per_column);
            var _sector_bottom = round((i + 1) * _inner_height / _sectors_per_column);
            var _column = 1 + irandom_range(_sector_left, _sector_right - 1);
            var _row = 1 + irandom_range(_sector_top, _sector_bottom - 1);
            array_push(reserved_cells, _row * width + _column);
        }
        
        // removing reserved cells numbers starting from the latest
        // that's because at this point, for each index cells[i] = i
        // so reserved values can be deleted by deleting items at the corresponding index
        // in a non-descending order, array shift would break that logic
        array_sort(reserved_cells, false);
        array_foreach(reserved_cells, function(i) {
            array_delete(cells, i, 1);
        });
    }
    
    // ----------
    // Generating
    // ----------
    
    static process = function() {
        var _is_next_reserved = array_length(reserved_cells) > 0;
        var _next_cell = array_shift(reserved_cells) ?? array_shift(cells);
        if (is_undefined(_next_cell))
            return succeed_with(mp_grid);
        
        var _column = _next_cell mod width;
        var _row = _next_cell div width;
        
        var _image = _is_next_reserved ? 2 : (try_occupy_cell(_column, _row) ? 1 : 0);
        instance_create_layer(16 * _column, 16 * _row, "Instances", obj_AnthillTile, { image_index: _image, image_speed: 0 });
        
        return progress_by(1);
    }
    
    static try_occupy_cell = function(_column, _row) {
        if (mp_grid_get_cell(mp_grid, _column, _row) != 0)
            return true; // the cell has been already occupied as a part of the outer wall
        
        mp_grid_add_cell(mp_grid, _column, _row);
        
        if (cell_path_broken(_column, _row)) {
            mp_grid_clear_cell(mp_grid, _column, _row);
            return false;
        } else {
            return true;
        }
    }
    
    static cell_path_broken = function(_column, _row) {
        static dir_xoffset = [1, 0, -1, 0];
        static dir_yoffset = [0, -1, 0, 1];
        
        var _neighbors = [];
        for (var i = 0; i < 4; i++) {
            if (mp_grid_get_cell(mp_grid, _column + dir_xoffset[i], _row + dir_yoffset[i]) == 0)
                array_push(_neighbors, i);
        }
        
        for (var i = 1, _count = array_length(_neighbors); i < _count; i++) {
            var _dirfrom = _neighbors[i - 1];
            var _xfrom = 16 * (_column + dir_xoffset[_dirfrom]) + 8;
            var _yfrom = 16 * (_row + dir_yoffset[_dirfrom]) + 8;
            
            var _dirto = _neighbors[i];
            var _xto = 16 * (_column + dir_xoffset[_dirto]) + 8;
            var _yto = 16 * (_row + dir_yoffset[_dirto]) + 8;
            
            if (!mp_grid_path(mp_grid, test_path, _xfrom, _yfrom, _xto, _yto, false))
                return true;
        }
        return false;
    }
    
    // -------
    // Cleanup
    // -------
    
    static cleanup = function() {
        path_delete(test_path);
        mp_grid_destroy(mp_grid);
    }
}

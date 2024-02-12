/// @desc Automatic frame time measurement

// it's performed in Begin Step event
// because it's the earliest event in the frame
// thus, it should give a good idea of when the next frame should start

if (automatic_execution_enabled)
    estimate_next_frame_time();

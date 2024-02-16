/// @desc Automatic task processing

// it's performed in Draw GUI End event
// because it's the latest event in the frame
// thus, what comes after should be mostly padding the frame with idleness

if (automatic_processing_enabled)
    process_ongoing_tasks();

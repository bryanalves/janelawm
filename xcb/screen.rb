module XCB
  class Screen < FFI::Struct
    layout :root, :window,
           :default_colormap, :colormap,
           :white_pixel, :uint32,
           :black_pixel, :uint32,
           :current_input_masks, :uint32,
           :width_in_pixels, :uint16,
           :height_in_pixels, :uint16,
           :width_in_millimeters, :uint16,
           :height_in_millimeters, :uint16,
           :min_installed_maps, :uint16,
           :max_installed_maps, :uint16,
           :root_visual, :visualid,
           :backing_stores, :uint8,
           :save_unders, :uint8,
           :root_depth, :uint8,
           :allowed_depths_len, :uint8
  end
end

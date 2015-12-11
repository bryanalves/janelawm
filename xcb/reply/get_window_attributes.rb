module XCB
  class Reply::GetWindowAttributes < FFI::Struct
    layout :response_type, :uint8,
           :backing_store, :uint8,
           :sequence, :uint16,
           :length, :uint32,
           :visual, :visualid,
           :_class, :uint16,
           :bit_gravity, :uint8,
           :win_gravity, :uint8,
           :backing_planes, :uint32,
           :backing_pixel, :uint32,
           :save_under, :uint8,
           :map_is_installed, :uint8,
           :map_state, :uint8,
           :override_redirect, :uint8,
           :colormap, :colormap,
           :all_event_masks, :uint32,
           :your_event_mask, :uint32,
           :do_not_propogate_mask, :uint16,
           :pad0, [:uint8, 2]
  end
end

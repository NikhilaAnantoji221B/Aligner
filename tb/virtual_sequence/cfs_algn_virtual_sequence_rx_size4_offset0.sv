//Valid RX data size 4,offset 1
`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_RX_SIZE4_OFFSET0_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_RX_SIZE4_OFFSET0_SV

class cfs_algn_virtual_sequence_rx_size4_offset0 extends cfs_algn_virtual_sequence_rx;

  // Aligner data width for validation
  local int unsigned algn_data_width;

  // Constraints to force size = 4 and offset = 0
  constraint fixed_size_offset {
    seq.item.data.size() == 4;
    seq.item.offset == 0;
    // Optional legality constraint (safety)
    (seq.item.data.size() + seq.item.offset) <= (algn_data_width / 8);
  }

  `uvm_object_utils(cfs_algn_virtual_sequence_rx_size4_offset0)

  function new(string name = "");
    super.new(name);
  endfunction

  function void pre_randomize();
    super.pre_randomize();
    algn_data_width = p_sequencer.model.env_config.get_algn_data_width();
  endfunction

endclass

`endif

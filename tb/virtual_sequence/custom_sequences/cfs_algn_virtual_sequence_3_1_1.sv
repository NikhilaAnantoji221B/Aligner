`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_3_1_1_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_3_1_1_SV

class cfs_algn_virtual_sequence_3_1_1 extends cfs_algn_virtual_sequence_base;

  `uvm_object_utils(cfs_algn_virtual_sequence_3_1_1)

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    uvm_reg registers[$];
    uvm_status_e status;

    // Fetch all registers
    p_sequencer.model.reg_block.get_registers(registers);

    // Filter out read-only registers
    for (int reg_idx = registers.size() - 1; reg_idx >= 0; reg_idx--) begin
      if (!(registers[reg_idx].get_rights() inside {"RW", "WO"})) begin
        registers.delete(reg_idx);
      end
    end

    // Randomize order of register writes
    registers.shuffle();

    foreach (registers[reg_idx]) begin
      uvm_reg current_reg = registers[reg_idx];

      // Check if it's the IRQEN register
      if (current_reg.get_name() == "IRQEN") begin
        // Manually set MAX_DROP field to 1
        current_reg.get_field_by_name("MAX_DROP").set(1);
        current_reg.update(status);
      end else begin
        void'(current_reg.randomize());
        current_reg.update(status);
      end
    end
  endtask

endclass

`endif

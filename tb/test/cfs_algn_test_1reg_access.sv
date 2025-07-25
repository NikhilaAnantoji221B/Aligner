//Test to verify the access types of all four registers
`ifndef CFS_ALGN_TEST_1REG_ACCESS_SV
`define CFS_ALGN_TEST_1REG_ACCESS_SV

class cfs_algn_test_1reg_access extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_test_1reg_access)
  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t ctrl_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irq_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    //Fork SLAVE_RESPONSE_FOREVER
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    //Enable all Registers
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.write(status, 32'h0000001f, UVM_FRONTDOOR);  //enable all interupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);  //read value 1f
    //1.Control Register 
    env.model.reg_block.CTRL.write(status, 32'h00000202,
                                   UVM_FRONTDOOR);  //CONFIGURING WITH OFFSET 2 SIZE 2
    env.model.reg_block.CTRL.read(status, ctrl_val, UVM_FRONTDOOR);
    //2.Status Register
    env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.write(status, 32'h0000f0ff,
                                     UVM_FRONTDOOR);  //writing all ones to this field error case
    `uvm_info("1REG_ACCESS", $sformatf("STATUS register value: 0x%0h ", status_val), UVM_MEDIUM)
    //3.Interrupt Register
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQ.write(status, 32'h0000001f, UVM_FRONTDOOR);  //enable all interupts
    env.model.reg_block.IRQ.read(status, irq_val, UVM_FRONTDOOR);  //read value 1f
    //RO Fields in IRQEN
    //4.IRQEN REG
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    env.model.reg_block.IRQEN.write(status, 32'hffffff1f, UVM_FRONTDOOR);  //enable all interupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);  //read value 1f

    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif



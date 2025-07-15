`ifndef CFS_ALGN_VIRTUAL_SEQUENCE_RX_COMB_SV
`define CFS_ALGN_VIRTUAL_SEQUENCE_RX_COMB_SV

class cfs_algn_virtual_sequence_rx_comb extends cfs_algn_virtual_sequence_base;

  //Sequence for sending one MD RX transaction
  rand cfs_md_sequence_simple_master seq;

  `uvm_object_utils(cfs_algn_virtual_sequence_rx_comb)

  function new(string name = "");
    super.new(name);
  endfunction


  virtual task body();
    cfs_md_sequence_simple_master rx_sequence;


    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 0;
                        item.offset==0;
          })
    end

    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 1;
                        item.offset==0;
          })
    end

    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 1;
                        item.offset==1;
          })
    end

    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 1;
                        item.offset==2;
          })
    end

    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 1;
                        item.offset==3;
          })
    end
    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 2;
                        item.offset==0;
          })
    end
    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 2;
                        item.offset==2;
          })
    end
    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 3;
                        item.offset==0;
          })
    end
    begin
      `uvm_do_on_with(rx_sequence, p_sequencer.md_rx_sequencer,
                      {
                        item.data.size() == 4;
                        item.offset==0;
          })
    end

  endtask

endclass

`endif


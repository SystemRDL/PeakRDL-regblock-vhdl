Customizing the CPU interface
=============================

Use your own existing VHDL record definition
--------------------------------------------------------

This exporter comes pre-bundled with its own VHDL record interface declarations.
What if you already have your own VHDL record declaration that you prefer?

Not a problem! As long as your interface definition is similar enough, it is easy
to customize an existing CPUIF definition.


As an example, let's use the VHDL record definition for
:ref:`cpuif_axi4lite` that is bundled with this project. This interface uses
the following style and naming conventions:

* VHDL input record type name is ``axi4lite_slave_in_intf``
* VHDL output record type name is ``axi4lite_slave_out_intf``
* Record signals are all upper-case: ``AWREADY``, ``AWVALID``, etc...

Lets assume your preferred VHDL record definition uses a slightly different naming convention:

* VHDL input record type name is ``axi4_lite_interface_in``
* VHDL output record type name is ``axi4_lite_interface_out``
* Interface signals are all lower-case: ``awready``, ``awvalid``, etc...

Rather than rewriting a new CPU interface definition, you can extend and adjust the existing one:

.. code-block:: python

    from peakrdl_regblock_vhdl.cpuif.axi4lite import AXI4Lite_Cpuif

    class My_AXI4Lite(AXI4Lite_Cpuif):

        @property
        def port_declaration(self) -> str:
            # Override the port declaration text to use the alternate record name and case
            return "\n".join([
                "s_axil_i : in axi4_lite_interface_in(",
               f"    awaddr({self.addr_width-1} downto 0),",
               f"    wdata({self.data_width-1} downto 0),",
               f"    wstrb({self.data_width_bytes-1} downto 0),",
               f"    araddr({self.addr_width-1} downto 0)",
                ");",
                "s_axil_o : out axi4_lite_interface_out(",
               f"    rdata({self.data_width-1} downto 0)",
                ")",
            ])


        def signal(self, name:str) -> str:
            # Override the signal names to be lowercase instead
            return super().signal(name).lower()

Then use your custom CPUIF during export:

.. code-block:: python

   exporter = RegblockExporter()
   exporter.export(
      root, "path/to/output_dir",
      cpuif_cls=My_AXI4Lite
   )



Custom CPU Interface Protocol
-----------------------------

If you require a CPU interface protocol that is not included in this project,
you can define your own.

1. Create a VHDL CPUIF implementation template file.

    This contains the VHDL implementation of the bus protocol. The logic
    in this shall implement a translation between your custom protocol and the
    :ref:`cpuif_protocol`.

    Reminder that this template will be preprocessed using
    `Jinja <https://jinja.palletsprojects.com>`_, so you can use
    some templating tags to dynamically render content. See the implementations of
    existing CPU interfaces as an example.

2. Create a Python class that defines your CPUIF

    Extend your class from :class:`peakrdl_regblock_vhdl.cpuif.CpuifBase`.
    Define the port declaration string, and provide a reference to your template file.

3. Use your new CPUIF definition when exporting.
4. If you think the CPUIF protocol is something others might find useful, let me
   know and I can add it to PeakRDL!


Loading into the PeakRDL command line tool
------------------------------------------
There are two ways to make your custom CPUIF class visible to the
`PeakRDL command-line tool <https://peakrdl.readthedocs.io>`_.

Via the PeakRDL TOML
^^^^^^^^^^^^^^^^^^^^
The easiest way to add your cpuif is via the TOML config file. See the
:ref:`peakrdl_cfg` section for more details.

Via a package's entry point definition
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If you are publishing a collection of PeakRDL plugins as an installable Python
package, you can advertise them to PeakRDL using an entry point.
This advertises your custom CPUIF class to the PeakRDL-regblock-vhdl tool as a plugin
that should be loaded, and made available as a command-line option in PeakRDL.

.. code-block:: toml

    [project.entry-points."peakrdl_regblock_vhdl.cpuif"]
    my-cpuif = "my_package.my_module:MyCPUIF"


*   ``my_package``: The name of your installable Python module
*   ``peakrdl-regblock-vhdl.cpuif``: This is the namespace that PeakRDL-regblock-vhdl will
    search. Any cpuif plugins you create must be enclosed in this namespace in
    order to be discovered.
*   ``my_package.my_module:MyCPUIF``: This is the import path that
    points to your CPUIF class definition.
*   ``my-cpuif``: The lefthand side of the assignment is your cpuif's name. This
    text is what the end-user uses in the command line interface to select your
    CPUIF implementation.

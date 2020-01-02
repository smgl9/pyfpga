"""PyFPGA Multi Vendor VHDL example.

The main idea of a multi-vendor project is to implements the same HDL code
with different tools, to make comparisons. The project name is not important
and the default devices could be used.
"""

from fpga.project import Project, TOOLS

for tool in TOOLS:
    PRJ = Project(tool)
    PRJ.set_outdir('../build/multi-tool-vhdl/%s' % tool)
    PRJ.add_files('hdl/blinking.vhdl', 'examples')
    PRJ.add_files('hdl/examples_pkg.vhdl', 'examples')
    PRJ.add_files('hdl/top.vhdl')
    PRJ.set_top('Top')
    try:
        PRJ.generate(to_task='syn')
    except Exception as e:
        print('There was an error running %s' % tool)
        print('{} ({})'.format(type(e).__name__, e))
"""S6micro generate example project."""

import logging

from fpga.project import Project

logging.basicConfig()
logging.getLogger('fpga.project').level = logging.DEBUG

prj = Project('ise', 's6micro')
prj.set_part('XC6SLX9-2-CSG324')

prj.set_outdir('../../build/s6micro')

prj.add_files('../hdl/blinking.vhdl', 'examples')
prj.add_files('../hdl/examples_pkg.vhdl', 'examples')
prj.add_files('../hdl/top.vhdl')
prj.set_top('Top')
prj.add_files('s6micro.xcf')
prj.add_files('s6micro.ucf')

try:
    prj.generate()
except Exception as e:
    logging.warning('{} ({})'.format(type(e).__name__, e))
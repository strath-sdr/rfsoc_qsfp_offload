import os
import shutil
from distutils.dir_util import copy_tree
from setuptools import find_packages, setup

# globals
package_name = 'rfsoc_qsfp_offload'
board = os.environ['BOARD']
repo_board_dir = f'boards/{board}/{package_name}'
board_notebooks_dir = os.environ['PYNQ_JUPYTER_NOTEBOOKS']
board_project_dir = os.path.join(board_notebooks_dir, 'rfsoc-offload')

data_files = ['network_layer.json']

# check whether board is supported
def check_env():
    if not os.path.isdir(repo_board_dir):
        raise ValueError("Board {} is not supported.".format(board))
    if not os.path.isdir(board_notebooks_dir):
        raise ValueError(
                "Directory {} does not exist.".format(board_notebooks_dir))

# check if the path already exists, delete if so
def check_path():
    if os.path.exists(board_project_dir):
        shutil.rmtree(board_project_dir)

# copy bitstream to python package
def copy_bitstream():
    src_dir = os.path.join(repo_board_dir, 'bitstream')
    dst_dir = os.path.join(package_name, 'bitstream')
    copy_tree(src_dir, dst_dir)
    data_files.extend(
        [os.path.join("..", dst_dir, f) for f in os.listdir(dst_dir)])

# copy assets to python package
def copy_assets():
    src_dir = os.path.join(f'assets')
    dst_dir = os.path.join(package_name, 'assets')
    copy_tree(src_dir, dst_dir)
    data_files.extend(
        [os.path.join("..", dst_dir, f) for f in os.listdir(dst_dir)])

# copy board specific drivers
def copy_drivers():
    src_dir = os.path.join(repo_board_dir, 'drivers')
    dst_dir = os.path.join(package_name)
    copy_tree(src_dir, dst_dir)
    data_files.extend(
        [os.path.join("..", dst_dir, f) for f in os.listdir(dst_dir)])

# copy notebooks to jupyter home
def copy_notebooks():
    src_nb_dir = os.path.join((repo_board_dir), 'notebooks')
    dst_nb_dir = os.path.join(board_project_dir)
    if os.path.exists(dst_nb_dir):
        shutil.rmtree(dst_nb_dir)
    copy_tree(src_nb_dir, dst_nb_dir)

check_env()
check_path()
copy_bitstream()
copy_assets()
copy_drivers()
copy_notebooks()

setup(
        name="rfsoc_qsfp_offload",
        version='0.0.3',
        install_requires=[
            'pynq>=2.7',
            ],
        url='https://github.com/',
        license='BSD 3-Clause License',
        author='Josh Goldsmith',
        author_email='joshua.goldsmith@strath.ac.uk',
        packages=find_packages(),
        package_data={
            '': data_files,
            },
        description="QSFP offload for RFSoC"
)

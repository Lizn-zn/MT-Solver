from setuptools import setup

setup(
    name='your_tool',
    version='0.1',
    py_modules=['your_script'],
    install_requires=[
        'Click',
    ],
    entry_points='''
        [console_scripts]
        your-tool=your_script:hello
    ''',
)

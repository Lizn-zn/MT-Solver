from setuptools import setup, find_packages

setup(
    name='MT-Solver',  
    version='0.1',  
    
    description='An integration of model theory solvers',  
    
    long_description=open('README.md').read(),  
    long_description_content_type='text/markdown',  
    
    url='',      
    author='',
    author_email='',
    
    license='MIT',  
        
    install_requires=[
        "sympy",
        "z3-solver",
        "cvc5"
    ],
    
    packages=find_packages(where='.'),  
    
    include_package_data=True,
    
    entry_points={  
        'console_scripts': [
            'mtsolve=mtsolver.foo:solve_main',
            'mtprove=mtsolver.foo:prove_main',
        ],
    },
)
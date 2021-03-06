import os, sys

def paths( *args ):
    "Returns normalized paths"
    return os.path.abspath( os.path.join( *args) )


_CURR_DIR = paths( os.path.dirname(__file__) )

DEPLOYED = not os.path.exists(paths(_CURR_DIR, 'develop.txt'))


CURR_DIR = _CURR_DIR

STATIC_DIR = paths( _CURR_DIR, 'static' )

APP_DIR = paths( _CURR_DIR, 'events')

DOCS_DIR = paths( _CURR_DIR, 'docs')

TEMPLATE_DIR = paths( _CURR_DIR, 'templates' )

DATABASE_FILE = paths( _CURR_DIR, 'db-tsa.db' )

LIB_DIR = paths( _CURR_DIR, 'lib')

sys.path.append(LIB_DIR)


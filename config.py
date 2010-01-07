import os 

def paths( *args ):
    "Returns normalized paths"
    return os.path.abspath( os.path.join( *args) )

if os.name == 'posix':
    DEPLOYED = True
else:
    DEPLOYED = False


_CURR_DIR = paths( os.path.dirname(__file__) )

CURR_DIR = _CURR_DIR

STATIC_DIR = paths( _CURR_DIR, 'static' )

APP_DIR = paths( _CURR_DIR, 'events')

TEMPLATE_DIR = paths( _CURR_DIR, 'templates' )

DATABASE_FILE = paths( _CURR_DIR, 'db-tsa.db' )


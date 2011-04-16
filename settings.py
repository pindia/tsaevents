import config
# Django settings for tsa project.

MODE = 'nation'

MODE_ABBR =dict(
    region='Reg',
    state='Sta',
    nation='Nat'
)




DEBUG = not config.DEPLOYED
TEMPLATE_DEBUG = DEBUG

PREPEND_WWW = config.DEPLOYED

ADMINS = (
    ('Pindi Albert', 'pindi.albert@gmail.com'),
    # ('Your Name', 'your_email@domain.com'),
)

SERVER_EMAIL = 'system@tsaevents.com'

MANAGERS = ADMINS
'''
DATABASE_ENGINE = 'sqlite3'           # 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
DATABASE_NAME = config.DATABASE_FILE             # Or path to database file if using sqlite3.
DATABASE_USER = ''             # Not used with sqlite3.
DATABASE_PASSWORD = ''         # Not used with sqlite3.
DATABASE_HOST = ''             # Set to empty string for localhost. Not used with sqlite3.
DATABASE_PORT = ''             # Set to empty string for default. Not used with sqlite3.
'''

DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.sqlite3',
		'NAME': config.DATABASE_FILE
	}
}

if DEBUG:
    EMAIL_HOST = 'localhost'
    EMAIL_PORT = '1025'
else:
    EMAIL_HOST = 'smtp.webfaction.com'
    EMAIL_PORT = 25
    EMAIL_HOST_USER = 'pindi'
    EMAIL_HOST_PASSWORD = open(config.paths(config.CURR_DIR,'password.txt'),'rt').read().strip()

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'America/Chicago'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# Absolute path to the directory that holds media.
# Example: "/home/media/media.lawrence.com/"
MEDIA_ROOT = config.paths(config.STATIC_DIR, 'uploads')

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash if there is a path component (optional in other cases).
# Examples: "http://media.lawrence.com", "http://example.com/media/"
MEDIA_URL = '/static/tsa/uploads/'

FILE_UPLOAD_PERMISSIONS = 0664

# URL prefix for admin media -- CSS, JavaScript and images. Make sure to use a
# trailing slash.
# Examples: "http://foo.com/media/", "/media/".
ADMIN_MEDIA_PREFIX = '/static/admin_media/'

# Make this unique, and don't share it with anybody.
SECRET_KEY = '__+4i=^h3icf6_=m6houa$&h(t2#yunsj9&b@t7e!^-6*u!!-d'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.load_template_source',
    'django.template.loaders.app_directories.load_template_source',
#     'django.template.loaders.eggs.load_template_source',
)

class ChapterMiddleware(object):
    def process_request(self, request):
        try:
            if request.user.is_authenticated():
                user = request.user
                if 'CURRENT_CHAPTER' in request.session:
                    target_chapter = user.profile.chapter.__class__.objects.get(id=int(request.session['CURRENT_CHAPTER']))
                    if target_chapter != user.profile.chapter:
                        user.profile.is_member = False
                        user.profile.chapter = target_chapter
                if 'SWITCH_CHAPTER' in request.GET:
                    chapter = user.profile.chapter
                    if chapter and (chapter.link or chapter.reverselink) and user.profile.is_admin:
                        target_chapter = chapter.link or chapter.reverselink
                        request.session['CURRENT_CHAPTER'] = target_chapter.id
                        from django.http import HttpResponseRedirect
                        return HttpResponseRedirect(request.path)
                request.chapter = user.profile.chapter
    
            else:
                request.chapter = None
        except Exception, e:
            print 'EXCEPTION: %s' % e
            request.chapter = None


MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.middleware.transaction.TransactionMiddleware',
    'tsa.settings.ChapterMiddleware',
    #'johnny.middleware.QueryCacheMiddleware',
    #'johnny.middleware.LocalStoreClearMiddleware',
)

#CACHE_BACKEND = 'johnny.backends.locmem://'
#JOHNNY_MIDDLEWARE_KEY_PREFIX='jc_myproj'


ROOT_URLCONF = 'tsa.urls'

TEMPLATE_DIRS = (
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    config.TEMPLATE_DIR
)

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.admin',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    #'django.contrib.sites',
    'tsa.events',
)

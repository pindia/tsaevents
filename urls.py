from django.conf.urls.defaults import *
from django.contrib.auth.views import login, logout, password_reset
import config

# Uncomment the next two lines to enable the admin:

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('tsa.events.views',

    # Account/Event Management Views
    (r'^$', 'index'),
    (r'^quick_login$', 'quick_login'),
    (r'^update_indi$', 'update_indi'),
    (r'^settings$', 'settings'),
    
    # List Views
    (r'^event_list$', 'event_list'),
    (r'^member_list$', 'member_list'),
    (r'^team_list$', 'team_list'),
    
    # Team Views
    (r'^join_team$', 'join_team'),
    (r'^teams/(\d+)/$', 'view_team'),
    (r'^teams/(\d+)/update/$', 'update_team'),
    
    # Chapter Admin
    (r'^event_log$', 'system_log'),
    (r'^edit_chapter$', 'edit_chapter'),
    (r'^member_fields/(\w+)?$', 'member_fields'),
    
    # System Admin
    (r'^config/chapter_list$', 'chapter_list'),
    (r'^config/eventsets/$', 'eventset_list'),
    (r'^config/eventsets/(\d+)/$', 'edit_eventset')
)

urlpatterns += patterns('',
    (r'^accounts/login/$',  login),
    (r'^accounts/logout/$', logout, {'template_name':'registration/login.html'}),
    (r'^accounts/create/$', 'tsa.events.views.create_account'),
)

urlpatterns += patterns('',
    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    (r'^admin/(.*)', admin.site.root),
)

if not config.DEPLOYED:
    urlpatterns += patterns('',
    (r'^static/tsa/(.*)$', 'django.views.static.serve', {'document_root': config.STATIC_DIR }),
    )